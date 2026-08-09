# Flutter Chat Integration Guide

**Audience:** Flutter / mobile engineers integrating Navigator chat into an app whose UI is already built.  
**Scope:** Wire existing Navigator + Chumley Chat backends — **no new UI package required**.  
**Status:** Derived from the live web implementation in `frontend/src/office/chatbot/` (2026-07).  
**Related docs:**
- [CHUMLEY_CHAT_PILLAR_INTEGRATION.md](./CHUMLEY_CHAT_PILLAR_INTEGRATION.md) — JWT / JWKS pillar playbook (React-oriented)
- [NAVIGATOR_INTEGRATION.md](./NAVIGATOR_INTEGRATION.md) — authoritative JWT + JWKS contract
- [MOBILE_APP_HANDOFF.md](../handoffs/MOBILE_APP_HANDOFF.md) — mobile auth exchange / bearer JWT

---

## TL;DR

The Navigator web drawer hosts **two independent systems**. Replicate both (or gate one) in Flutter:

| Feature | Who owns data/realtime | Flutter talks to |
|---|---|---|
| **Chumley Chat** (people DMs / groups) | Orchestrator’s chat service | Chat service REST + WebSocket, after minting a short-lived JWT from Navigator |
| **AI Chat** (Navigator copilot) | Navigator Copilot (proxied) | This app’s `/api/navigator/*` |
| **Insights** (optional KPI cards) | This app’s backend | `GET /api/insights/daily-briefing` |

You do **not** reimplement chat storage, WS routing, or JWKS verification. You:

1. Authenticate to Navigator with your existing Aspect mobile JWT (`Authorization: Bearer …`).
2. Mint a **chat JWT** from Navigator when opening Chumley Chat.
3. Call the chat service + AI endpoints with the contracts below.
4. Drive your existing Flutter widgets from the responses / socket frames.

---

## Architecture

```
┌──────────────────────┐     Authorization: Bearer <aspect_jwt>
│  Flutter app         │ ────────────────────────────────────────┐
│  (UI already built)  │                                          │
└──────────┬───────────┘                                          ▼
           │                                    ┌────────────────────────────────┐
           │  1) GET /api/auth/chat-token       │  Navigator backend             │
           │     (Bearer Aspect JWT)            │  - mobile_auth injects         │
           │  2) GET/POST /api/navigator/*      │    session["auth_user"]         │
           │  3) GET /api/insights/…            │  - signs RS256 chat JWT        │
           │  4) GET /api/permissions/me        │  - proxies /api/navigator/*    │
           │                                    │  - publishes JWKS              │
           │                                    └───────────────┬────────────────┘
           │                                                    │ JWKS verify
           │  Authorization: Bearer <chat_jwt>                  │
           │  wss://…/ws?token=<chat_jwt>                       ▼
           └──────────────────────────────▶ ┌───────────────────────────────┐
                                            │  Chumley Chat service         │
                                            │  (Cloud Run — Orchestrator)   │
                                            └───────────────────────────────┘
```

**Identity rule (Chumley Chat):** the chat service keys humans by JWT `sub` = **lowercased email**.  
Same email across Navigator / Catalyst / Concierge → one shared DM history.

> Note: `CHUMLEY_CHAT_AUTH_INTEGRATION.md` describes an older Orchestrator-issued design.  
> **What is live today** is the pillar-minted RS256 JWT model above. Follow this doc + `CHUMLEY_CHAT_PILLAR_INTEGRATION.md`.

---

## Prerequisites (already true for Navigator)

- Flutter app can call Navigator APIs with `Authorization: Bearer <aspect_access_token>` (see mobile exchange in `MOBILE_APP_HANDOFF.md`).
- Backend `mobile_auth` middleware injects `request.session["auth_user"]` from that bearer token — so `GET /api/auth/chat-token` works the same for Flutter as for the cookie-based web session.
- Navigator issuer + JWKS are registered with the chat service (`CHUMLEY_CHAT_TRUSTED_ISSUERS`).

**Env / URLs (make these config in Flutter):**

| Config key | Default / example |
|---|---|
| `NAVIGATOR_API_BASE` | e.g. `https://navigator.chumley.ai` (or staging) |
| `CHUMLEY_CHAT_BASE_URL` | `https://chumley-chat-44vauyd3ma-nw.a.run.app` |

Override chat URL in web via `VITE_CHUMLEY_CHAT_URL`; mirror that for Flutter.

---

## Feature gating

Before showing the Chumley Chat tab/screen:

```http
GET {NAVIGATOR_API_BASE}/api/permissions/me
Authorization: Bearer <aspect_jwt>
```

Response (relevant bit):

```json
{
  "role": "admin",
  "visible_tabs": ["…"],
  "permissions": {
    "chumley_chat.use": true
  }
}
```

- Show Chumley Chat only when `permissions["chumley_chat.use"] == true`.
- AI Chat does not use this flag; it is gated by role + trade-group rules when calling `/api/navigator/query` (see §2).

---

# Part 1 — Chumley Chat (people messaging)

## 1.1 Mint a chat JWT

```http
GET {NAVIGATOR_API_BASE}/api/auth/chat-token
Authorization: Bearer <aspect_jwt>
```

**200:**

```json
{
  "token": "<rs256_jwt>",
  "expires_in": 300
}
```

**401:** Aspect JWT missing/invalid / no `auth_user.email`.

### Token cache (required)

Mirror the web client (`chumleyChatAuth.ts`):

- Cache `token` in memory.
- Treat expiry as `now + expires_in * 1000 - 30_000` (refresh ~30s early).
- Deduplicate concurrent mint calls (list + socket often fire together).
- Re-mint on HTTP 401 from the chat service and before every WS reconnect.

### Flutter sketch

```dart
class ChumleyAuthProvider {
  String? _token;
  DateTime? _expiresAt;
  Future<String>? _inflight;

  Future<String> fetchToken({
    required Uri navigatorBase,
    required String aspectJwt,
    required http.Client client,
  }) async {
    if (_token != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(_expiresAt!)) {
      return _token!;
    }
    _inflight ??= _mint(navigatorBase, aspectJwt, client).whenComplete(() {
      _inflight = null;
    });
    return _inflight!;
  }

  Future<String> _mint(Uri base, String aspectJwt, http.Client client) async {
    final res = await client.get(
      base.replace(path: '/api/auth/chat-token'),
      headers: {'Authorization': 'Bearer $aspectJwt'},
    );
    if (res.statusCode != 200) {
      throw Exception('chat-token ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = body['token'] as String;
    final ttl = (body['expires_in'] as num?)?.toInt() ?? 300;
    _token = token;
    _expiresAt = DateTime.now().add(Duration(seconds: ttl - 30));
    return token;
  }
}
```

**Do not** send Navigator session cookies to the chat service. Chat auth is **only** `Authorization: Bearer <chat_jwt>` (REST) or `?token=` (WebSocket).

---

## 1.2 REST API (chat service)

Base: `{CHUMLEY_CHAT_BASE_URL}`  
Every request:

```
Authorization: Bearer <chat_jwt>
Content-Type: application/json   # except multipart upload
```

| Method | Path | Body / query | Purpose |
|---|---|---|---|
| `GET` | `/me` | — | `{ email, name, pillar? }` |
| `GET` | `/users?q=` | optional search | Directory for “new chat” picker → `{ users: [{email,name}] }` |
| `GET` | `/conversations` | — | Inbox → `{ conversations: Conversation[] }` |
| `POST` | `/conversations` | `{ "peer_email": "…" }` | Start / open DM → `Conversation` |
| `POST` | `/conversations/group` | `{ "name": "…", "member_emails": ["…"] }` | Create group (caller auto-included) |
| `GET` | `/conversations/{id}/messages?limit=50&before=` | cursor pagination | `{ messages, has_more }` |
| `POST` | `/conversations/{id}/messages` | `{ text?, client_id?, context? }` | Send via REST (optional; prefer WS) |
| `POST` | `/conversations/{id}/mark-read` | — | `{ last_read_at }` |
| `GET` | `/conversations/{id}/read-state` | — | `{ read_state: { email: iso } }` |
| `GET` | `/presence?emails=a,b` | comma-separated | `{ online: string[] }` |
| `POST` | `/media/upload` | `multipart/form-data` field `file` | `{ url, kind, label, content_type?, size? }` |

### Core types

```jsonc
// Conversation
{
  "id": "…",
  "participants": ["a@x.com", "b@x.com"],
  "participant_names": { "a@x.com": "A", "b@x.com": "B" },
  "is_group": false,
  "name": null,
  "last_message_at": "2026-07-19T12:00:00Z",
  "last_message_preview": "…",
  "last_message_author_email": "a@x.com",
  "unread_count": 2
}

// Message
{
  "id": "…",
  "conversation_id": "…",
  "text": "Hello",
  "author_email": "a@x.com",
  "author_name": "A",
  "created_at": "2026-07-19T12:00:00Z",
  "client_id": "uuid-from-client",      // optional idempotency / optimistic UI
  "context": {                           // optional rich link / attachment meta
    "type": "image",                     // free-form string from uploader
    "label": "photo.jpg",
    "url": "https://…",
    "sensitive": false
  }
}
```

### Suggested screen → API mapping

| Your Flutter UI | Calls |
|---|---|
| Conversation list | `GET /conversations`; sum `unread_count` for badge |
| Search / new DM | `GET /users?q=` → `POST /conversations` with `peer_email` |
| New group | `POST /conversations/group` |
| Open thread | `GET …/messages` then `POST …/mark-read` |
| Composer send | WebSocket `send` frame (below); fall back to REST if needed |
| Attach file / voice | `POST /media/upload` → include returned URL in message `context` |

---

## 1.3 WebSocket protocol

```
wss://chumley-chat-44vauyd3ma-nw.a.run.app/ws?token=<url_encoded_chat_jwt>
```

(Derive from base URL: `https` → `wss`, append `/ws?token=…`.)

### Connection lifecycle (match web client)

1. `fetchToken()` → open socket.
2. On open: start heartbeat — send `{ "type": "ping" }` every **30s** (server silence timeout ~60s).
3. On close (if not intentional): reconnect with exponential backoff starting at 1s, cap **30s**.
4. On reconnect: always mint a fresh/cached token first.
5. On dispose / logout: close and stop reconnect.

### Outbound frames (client → server)

```json
{ "type": "ping" }

{ "type": "send",
  "conversation_id": "…",
  "text": "Hello",
  "client_id": "optional-uuid",
  "context": { "type": "…", "label": "…", "url": "…", "sensitive": false } }

{ "type": "typing_start", "conversation_id": "…" }

{ "type": "typing_stop", "conversation_id": "…" }
```

### Inbound frames (server → client)

| `type` | Fields | UI action |
|---|---|---|
| `ready` | `online: string[]` | Initial presence set |
| `pong` | — | Heartbeat ack |
| `ack` | `conversation_id`, `client_id?`, `id` | Confirm optimistic send; replace temp id |
| `message` | full `Message` fields | Append to thread / bump inbox preview |
| `presence` | `email`, `online` | Update online indicators |
| `typing_start` / `typing_stop` | `conversation_id`, `email` | Typing indicator |
| `error` | `reason`, optional ids | Surface error; clear optimistic bubble |

### Unread badge (closed drawer / app background)

Web pattern in `ChatBot.tsx`:

1. Keep a long-lived socket while the user is logged in (or at least while the chat host is mounted).
2. On inbound `message` or `ready`, if the chat UI is **not** focused, re-fetch `GET /conversations` and sum `unread_count`.
3. While the thread list / active conversation UI is open, let that screen own the badge (via mark-read + local state) to avoid flicker.
4. On `AppLifecycleState.resumed`, refresh conversations as a safety net for missed frames.

---

## 1.4 Attachments

```http
POST {CHUMLEY_CHAT_BASE_URL}/media/upload
Authorization: Bearer <chat_jwt>
Content-Type: multipart/form-data

file: <bytes>
```

Response → put `url` / `kind` / `label` into the next `send` frame’s `context` (or message REST body). Host storage is owned by the chat service; Flutter does not need its own bucket for chat media.

---

## 1.5 Verification checklist (Chumley Chat)

- [ ] `GET /api/auth/chat-token` with Aspect bearer → 200 `{ token, expires_in: 300 }`
- [ ] Decode JWT: RS256, `kid` present, claims `iss,sub,name,pillar,iat,exp`, `sub` lowercased email, `pillar == "navigator"`, TTL ≈ 300s
- [ ] `GET {CHAT}/me` with chat bearer → your identity
- [ ] `GET {CHAT}/conversations` → 200
- [ ] WS connects; first frame `type: "ready"`
- [ ] Send DM ends-to-end with another user on the same email identity
- [ ] 401 from chat after issuer/JWKS misconfig → do **not** retry forever; surface “chat unavailable”

Local JWT mint verification (Python) lives in [CHUMLEY_CHAT_PILLAR_INTEGRATION.md §7](./CHUMLEY_CHAT_PILLAR_INTEGRATION.md).

---

# Part 2 — Navigator AI Chat

AI Chat is **not** the Chumley Chat service. It goes through Navigator’s gateway to the Copilot service.

Base path: `{NAVIGATOR_API_BASE}/api/navigator`  
Auth: `Authorization: Bearer <aspect_jwt>` (same as other mobile APIs).

## 2.1 Health

```http
GET /api/navigator/health
```

Use this when opening the AI panel; if not OK, disable send and show “Navigator unavailable”.

## 2.2 Conversations

```http
GET /api/navigator/conversations?user_email=<url_encoded_email>

POST /api/navigator/conversations
Content-Type: application/json
{ "user_email": "user@aspect.co.uk" }

GET /api/navigator/conversations/{id}/messages
```

Web shapes used by `ChatBot.tsx`:

- List item: `{ id, title, created_at, updated_at }`
- Create response: same + empty thread
- Messages: `{ role, content, timestamp, follow_ups?, visualizations? }`

Load messages when the user selects a conversation; keep a local list for the open screen.

## 2.3 Query (send message)

```http
POST /api/navigator/query
Content-Type: application/json
```

```json
{
  "query": "What was yesterday's revenue?",
  "role": "senior_leadership",
  "conversation_id": "<id>",
  "user_email": "user@aspect.co.uk",
  "engineer_id": "",
  "trade_group": "Plumbing",
  "trade_groups": ["Plumbing"],
  "date_range": "all_time"
}
```

### Role mapping (must match web)

Dashboard role → Navigator API `role`:

| App role (`user.role`) | Send as `role` |
|---|---|
| `admin` | `senior_leadership` |
| `rise` | `senior_leadership` |
| `tgm` | `trade_manager` |
| `trade_manager` | `account_manager` |
| others in allow-list | pass through as-is |

Allowed app roles before mapping:  
`admin`, `senior_stakeholder`, `operations_manager`, `ooh_manager`, `rise`, `tgm`, `trade_manager`, `engineer`.

**Guards (fail client-side with a clear error):**

- Role not in allow-list → do not call API.
- Roles `tgm` / `trade_manager` require at least one trade group (`trade_group` = first; `trade_groups` = expanded list if you share web’s `expandTradeGroups` helper).
- Role `engineer` requires non-empty `engineer_id`.

### Response (consume what your UI needs)

Typical fields used by web:

| Field | Use |
|---|---|
| `answer` / `message` | Assistant markdown text |
| `recommendation` | Optional appendix |
| `follow_up_prompts` | Chip buttons → resubmit as next `query` |
| `visualization[]` | Plotly payloads (`plotly_json`); render if you support charts, else ignore |
| `conversation_id` | If differs from request, update your open conversation id |

**UX flow:**

1. Optimistically append user message.
2. `POST /query`.
3. Append assistant message (or error message).
4. If user text matches a UK postcode, optionally call (non-fatal):

```http
GET /api/scheduling/address-visit-summary?postcode=<PC>
```

and attach the summary card model to that assistant turn (same as web).

---

# Part 3 — Insights tab (optional)

```http
GET /api/insights/daily-briefing
Authorization: Bearer <aspect_jwt>
```

Returns KPI blocks (`revenue`, `capacity`, `cash`, `credit_notes`) with summaries. Bind to your existing Insights widgets; no WebSocket.

---

## Recommended Flutter module layout

```
lib/features/chat/
  auth/chumley_auth_provider.dart    # mint + cache chat JWT
  chumley/
    chumley_api.dart                 # REST wrappers
    chumley_socket.dart              # WS + reconnection + ping
    chumley_models.dart              # Conversation, Message, frames
  navigator_ai/
    navigator_ai_api.dart            # health, conversations, query
    role_mapping.dart
  chat_controller.dart               # ties UI callbacks → APIs (no widgets)
```

Keep widgets in your existing UI package; inject `ChatController` / repositories only.

---

## Security & ops notes

| Topic | Guidance |
|---|---|
| Two tokens | Aspect JWT → Navigator APIs; Chat JWT → chat service only. Never send Aspect JWT to the chat service. |
| Logout | Drop both tokens from memory; close WS; stop reconnect. Chat has no server revoke list — short TTL is enough. |
| Certificate pinning | Optional; chat + Navigator are Cloud Run HTTPS. |
| Background | iOS/Android may suspend WS; refresh conversations on resume. |
| Errors | Chat `401` → remint once; if still failing, likely issuer/JWKS trust issue (backend/ops), not a Flutter bug. |

---

## Implementation order (functionality only)

1. **Auth path** — confirm `GET /api/auth/chat-token` works with your mobile Aspect JWT.
2. **Chumley REST** — `/me`, `/conversations`, open DM, list messages, mark-read.
3. **Chumley WS** — connect, ping, send, handle `message`/`ack`.
4. **Unread / presence** — badge + optional typing.
5. **Uploads** — `/media/upload` → `context` on send.
6. **AI Chat** — health → conversations → query + role guards.
7. **Insights** — if product needs the third tab.
8. **Gate** — `chumley_chat.use` from `/api/permissions/me`.

---

## Reference implementation (web)

| Concern | File |
|---|---|
| Drawer host / unread socket / AI query | `frontend/src/office/chatbot/ChatBot.tsx` |
| Chat JWT cache | `frontend/src/office/chatbot/chumleyChatAuth.ts` |
| Thin panel shell | `frontend/src/office/chatbot/ChumleyChatPanel.tsx` |
| Wire client (vendored) | `frontend/vendor/chumley-chat-panel/dist/client.js` + `types.d.ts` |
| Token issuer | `backend/blueprints/chat_token.py` |
| Mobile bearer → `auth_user` | `backend/mobile_auth.py` |
| Permission key | `chumley_chat.use` in `backend/permissions/core.py` |

---

## Contact / ownership

| Layer | Owner |
|---|---|
| Chat service, trusted issuers, CORS origins | Orchestrator / Aman Bisht |
| Navigator `/chat-token`, JWKS, `/api/navigator` proxy | Navigator backend |
| Flutter wiring of this contract | Your mobile team |

If chat REST returns 401 after a correctly minted token, share the exact JWT `iss` claim and JWKS URL with the Orchestrator team — Flutter cannot fix an untrusted issuer.
