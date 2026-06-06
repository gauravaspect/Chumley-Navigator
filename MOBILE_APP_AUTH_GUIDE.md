# Engineer Mobile App — Azure AD Login Guide

**Audience:** Flutter mobile dev building the engineer portal app
**Prepared by:** Dashboard team (ankit.dash@aspect.co.uk)
**Date:** 2026-05-26
**Companion doc:** [MOBILE_APP_HANDOFF.md](MOBILE_APP_HANDOFF.md)

---

## 1. TL;DR — What you actually need to build

You are building login for the **engineer portal**, not a generic Microsoft login. The end goal is:

1. Engineer taps "Sign in with Microsoft" in the Flutter app.
2. MSAL (or `aad_oauth`) opens the system browser / a webview to log into our Aspect Azure tenant — using PKCE, **no client secret**.
3. You get back an **`id_token`** (a JWT) from Microsoft.
4. You **POST that `id_token` to our backend** at a new endpoint (Section 6 — we're adding it for you).
5. Backend verifies the token, looks the user up in Salesforce, decides if they're an engineer, and returns either:
   - A **session token** + a `user` object → log them in, drop them on the engineer dashboard.
   - **403 `not_an_engineer`** → show "this app is for field engineers only" and bounce them out.
6. You store that session token securely (`flutter_secure_storage`) and attach it as a `Bearer` token on every subsequent API call.

That's the whole flow. Everything below is detail.

### What we're reusing vs adding

| Thing | Status |
|---|---|
| Existing Azure app registration (the one the web dashboard uses) | ✅ **Reuse as-is** — we'll just add a mobile platform to it |
| `client_id`, `tenant_id` | ✅ **Reuse** — same values for web and mobile |
| `client_secret` | ❌ **Not used on mobile** — stays exclusive to the web flow |
| Backend role-resolution + Salesforce lookup | ✅ **Reuse** — same engineer-detection logic |
| `POST /api/auth/mobile/exchange` endpoint | 🚧 **New** — I'll build this; spec is in Section 6 |

The only new things are: a couple of mobile redirect URIs added to the existing Azure registration, and one new backend endpoint. No second app registration, no separate client_id.

---

## 2. How the web login currently works (for context only)

Don't copy this for mobile. Just understand it so my explanations make sense.

| Step | What happens | File |
|---|---|---|
| 1 | User clicks "Sign in" — frontend redirects to `/api/auth/signin/microsoft-entra-id` | [LoginPage.tsx:11-13](../frontend/src/app/LoginPage.tsx#L11-L13) |
| 2 | Backend builds a Microsoft auth URL with `client_id`, `tenant_id`, `redirect_uri`, scopes, and 302-redirects the browser to `login.microsoftonline.com` | [auth.py:40-54](../backend/blueprints/auth.py#L40-L54) |
| 3 | User logs into Microsoft. Microsoft redirects back to `/api/auth/callback/microsoft-entra-id?code=...` | [auth.py:57](../backend/blueprints/auth.py#L57) |
| 4 | Backend exchanges the `code` for an `access_token` + `id_token` using **`client_id + client_secret`** (confidential client flow) | [auth.py:77-100](../backend/blueprints/auth.py#L77-L100) |
| 5 | Backend calls Microsoft Graph `/me` to get email + display name | [auth.py:106-113](../backend/blueprints/auth.py#L106-L113) |
| 6 | Backend decodes the `id_token` to pull Azure `oid`, `roles`, `groups` claims | [access_control.py:179-190](../backend/access_control.py#L179-L190) |
| 7 | Backend resolves the user's role (admin / trade_manager / engineer / etc.) by checking Azure group membership + Salesforce | [access_control.py:210-267](../backend/access_control.py#L210-L267) |
| 8 | Backend writes the user into a Starlette session, encrypts it into the `__session` HTTP-only cookie, redirects browser back to `/` | [auth.py:125-138](../backend/blueprints/auth.py#L125-L138) |
| 9 | Frontend hits `/api/auth/session`, gets the `user` object, decides whether to show engineer portal or office portal based on `user.role` | [App.tsx:52-71](../frontend/src/App.tsx#L52-L71) |

The web app uses **cookies, not bearer tokens**. There's no `Authorization` header on API calls — the browser just sends the `__session` cookie automatically.

For mobile, **the OAuth front-half changes** (PKCE on-device, no secret) and **the session back-half changes** (Bearer token in a header instead of a cookie), but **the middle — role resolution + Salesforce lookup — stays identical**. Once you call our `/api/auth/mobile/exchange`, you end up with the same `user` object the web flow produces.

---

## 3. Why the web flow can't be reused as-is on mobile

Two reasons:

1. **The web flow uses a confidential client.** Step 4 above needs `MICROSOFT_CLIENT_SECRET`. Putting that in a mobile app means anyone who decompiles the APK can extract it. Azure explicitly forbids this — mobile/SPA apps must use **PKCE** instead of a client secret. PKCE is what proves to Microsoft that the same device that started the login is the one finishing it, without needing a shared secret.

2. **The web flow ends with a cookie.** Cookies are awkward on mobile (no shared cookie jar between the system browser and your native HTTP client). Easier to have the backend hand you a session token in a JSON response and you attach it as a `Bearer` header.

The good news: solving both of these does **not** require a separate Azure app registration. We just add a mobile platform to the existing one.

---

## 4. Azure app registration changes — what I'll do on our existing registration

I'll go into the Azure portal and modify the existing app registration that the web dashboard already uses. **Same `client_id`, same tenant.** Adding a mobile platform alongside the existing web platform.

### Existing registration (for your reference)

| Setting | Value |
|---|---|
| **Tenant ID** | `93ce9c27-3bb2-4ef2-b686-1829de4f2584` (non-secret, fine to embed) |
| **Application (client) ID** | Will share via Slack — same one the web app uses (non-secret) |
| **Account types** | Single tenant (Aspect only) |
| **Existing platform** | Web (with redirect URI for the dashboard backend) |

### What I'll add to it for mobile

| Change | Value |
|---|---|
| **New platform** | "Mobile and desktop applications" |
| **iOS redirect URI** | `msauth.uk.co.aspect.engineerapp://auth` *(adjust to your final bundle id)* |
| **Android redirect URI** | `msauth://uk.co.aspect.engineerapp/<base64-encoded-signing-hash>` *(need your keystore SHA-1)* |
| **"Allow public client flows"** | **Enabled** (this is what lets PKCE work without a secret) |
| **API permissions** | No changes — `openid profile email User.Read` already granted, mobile inherits |

### What this means for you

- Use the **same `client_id` and `tenant_id`** as the web app.
- Do **not** use the `client_secret` — it exists for the web flow only, and trying to use it from mobile will fail (and would be a security hole).
- Configure your Flutter MSAL library with the mobile redirect URI above.

### What I'll send via Slack (not committed)

- The `client_id` (it's not really secret but no need to publish it in the repo)
- The final Android redirect URI once you give me your keystore SHA-1
- A long-lived dev session token for testing protected endpoints before the mobile exchange endpoint is live

### Why this is fine to share with the web app

The web and mobile flows hit Microsoft with the **same** `client_id` but **different mechanisms** (web sends a secret, mobile sends a PKCE verifier). Azure treats them as the same client identity, which is what we want — they're both "the Aspect Engineer Portal", just two surfaces. The backend will verify the `id_token`'s `aud` claim matches this one `client_id` regardless of which platform produced it.

---

## 5. Engineer vs everyone else — how the backend decides

This is the most important business-logic bit. The web dashboard supports **seven roles**:

```
admin > senior_stakeholder > operations_manager > ooh_manager > tgm > trade_manager > engineer
```

**Only `engineer` should be allowed into the mobile app.** Everyone else (managers, admins) gets bounced. The backend will do this check for you and return 403 if the user isn't an engineer — you just need to handle that response and show a friendly error.

### How the backend decides someone is an engineer

It runs through this gauntlet on every login ([auth.py:154-257](../backend/blueprints/auth.py#L154-L257)):

1. **Azure group check.** If the user is in any of these Azure security groups (mapped via `AZURE_GROUP_MAP_JSON` env var), they get that role and are **not** an engineer:
   - admin, senior_stakeholder, trade_manager, tgm, ooh_manager, operations_manager

2. **Salesforce ServiceResource lookup.** Otherwise, backend queries Salesforce:
   ```sql
   SELECT Id, Name, Email__c
   FROM ServiceResource
   WHERE Email__c = '{user_email}' AND Is_User_Active__c = TRUE
   ```
   - If no row → **not an engineer** → access denied.
   - If row exists → check the `FSM__c` flag.

3. **FSM flag.** `FSM__c` = Field Service Manager (office staff who happen to have a ServiceResource record).
   - If `FSM__c = true` → office staff, **not an engineer**.
   - If `FSM__c = false` or absent → ✅ **`engineer` role**, with `engineerId = ServiceResource.Id`.

So the rule is roughly:
> **"You are an engineer if you have an active Salesforce ServiceResource record tied to your work email and you're not flagged as an FSM."**

The mobile app should treat `role !== "engineer"` as a hard block. The same logic powers the web flow — once we wire the mobile exchange endpoint, both surfaces use the exact same code path.

---

## 6. The new backend endpoint we're adding for you

I haven't built this yet — it's on the dashboard team's pre-handoff list. Spec'ing it here so you can plan against it and stub it in dev.

### `POST /api/auth/mobile/exchange`

Swap a Microsoft `id_token` for an Aspect session token.

**Request:**
```json
{
  "id_token": "eyJ0eXAi…"   // The id_token from MSAL / aad_oauth
}
```

**Success response (200):**
```json
{
  "session_token": "aspect_sess_…",   // Opaque token, attach as Bearer on subsequent calls
  "expires_at": "2026-06-02T10:30:00Z",
  "user": {
    "id": "ankit_dash_aspect_co_uk",
    "email": "ankit.dash@aspect.co.uk",
    "name": "Ankit Dash",
    "role": "engineer",
    "azureOid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "engineerId": "0HnWS000000APMv0AO",  // Salesforce ServiceResource.Id
    "tradeGroups": ["Plumbing", "Drainage"]
  }
}
```

**Error responses:**

| Status | Body | Meaning |
|---|---|---|
| 400 | `{"error": "invalid_token"}` | id_token couldn't be parsed/verified |
| 401 | `{"error": "expired_token"}` | id_token has expired, redo MSAL flow |
| 403 | `{"error": "not_an_engineer", "detected_role": "trade_manager"}` | Valid login, but user isn't an engineer — bounce them |
| 403 | `{"error": "user_not_found"}` | Valid Microsoft login, but no matching Salesforce ServiceResource — bounce them |

**Backend will do:**
1. Verify the `id_token`'s signature against Microsoft's public JWKS (`https://login.microsoftonline.com/{tenant}/discovery/v2.0/keys`).
2. Verify `aud` claim matches our `MICROSOFT_CLIENT_ID` (same one the web flow uses).
3. Verify `iss` and `exp`.
4. Pull `email`, `oid`, `roles`, `groups` from the verified claims.
5. Run the same role-resolution + Salesforce lookup as the web flow (literal shared function).
6. If `role !== "engineer"` → 403.
7. Otherwise mint a session token (likely a signed JWT or an opaque token stored in Firestore), return it + the user object.

### Attaching the token to subsequent API calls

```
Authorization: Bearer aspect_sess_…
```

All existing engineer-facing API routes (`/api/engineers/...`, `/api/absences/...`, `/api/enquiries/...`, etc.) will accept this header. The backend middleware will resolve it back to the same session shape the cookie produces today, so route handlers don't need changes.

### Refresh / expiry

- Session token TTL: **7 days, sliding** (refreshed on each authenticated request, same as web).
- No separate refresh token. When you get a 401 on any API call, kick the user back to the MSAL flow.
- Mobile app should **not** store the Microsoft `id_token` or `access_token` long-term — just exchange and forget. Only persist the Aspect session token.

### Sign out

`POST /api/auth/signout` with the Bearer token. Backend invalidates the session. Locally, clear `flutter_secure_storage` and drop back to the login screen.

---

## 7. Flutter implementation notes

### Recommended packages

- [`aad_oauth`](https://pub.dev/packages/aad_oauth) — easiest for Azure AD, handles PKCE for you.
- Or [`msal_flutter`](https://pub.dev/packages/msal_flutter) if you want Microsoft's official SDK (more setup, better long-term).
- [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) — for the session token. **Don't use `shared_preferences`** for the token; it's unencrypted on Android.
- [`dio`](https://pub.dev/packages/dio) — interceptor pattern makes the "attach Bearer + retry on 401" loop clean.

### Sketch of the login flow

```dart
// 1. Trigger Microsoft login via aad_oauth (PKCE, no secret)
final config = Config(
  tenant: '93ce9c27-3bb2-4ef2-b686-1829de4f2584',
  clientId: '<SAME_CLIENT_ID_AS_WEB>',   // I'll send you this
  scope: 'openid profile email User.Read',
  redirectUri: 'msauth.uk.co.aspect.engineerapp://auth',
);
final oauth = AadOAuth(config);
await oauth.login();
final idToken = await oauth.getIdToken();

// 2. Swap with our backend
final response = await dio.post('/api/auth/mobile/exchange', data: {
  'id_token': idToken,
});

if (response.statusCode == 403) {
  // Not an engineer — show error, log them out of Microsoft too
  await oauth.logout();
  throw NotAnEngineerException();
}

// 3. Persist session token
final sessionToken = response.data['session_token'];
await secureStorage.write(key: 'aspect_session', value: sessionToken);

// 4. Set Dio interceptor to attach it on every call
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await secureStorage.read(key: 'aspect_session');
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  },
  onError: (err, handler) async {
    if (err.response?.statusCode == 401) {
      await secureStorage.delete(key: 'aspect_session');
      // Bounce to login screen
    }
    handler.next(err);
  },
));
```

### What to show the user

- **`role === "engineer"`** → proceed to engineer dashboard, store `user.engineerId` (you'll need it for every Salesforce-backed API call).
- **`error === "not_an_engineer"`** → "This app is for Aspect field engineers. Please use the web dashboard at [URL] to sign in as a manager/admin."
- **`error === "user_not_found"`** → "Your Microsoft account isn't linked to an active engineer record. Contact your manager or IT."
- **`error === "expired_token"` / 401 on any call** → silently redo the MSAL flow.

---

## 8. Testing while the backend endpoint isn't ready yet

I haven't built `/api/auth/mobile/exchange` yet — it's coming. In the meantime:

- **Option A (recommended):** Stub the endpoint locally. Mock a successful response and build the UI flow against the fixture. I'll send you a sample JSON payload matching the spec in Section 6.
- **Option B:** I can give you a long-lived dev session token tied to a test engineer account, so you can hit the existing protected endpoints (`/api/engineers/{id}/...`) as if you were already logged in. Useful for testing API integration without solving auth first.

Once the endpoint is live, swap the stub for the real call — the contract above is what it'll honor.

---

## 9. Open questions for you

Before I touch the Azure registration, I need:

1. **iOS bundle identifier** (e.g., `uk.co.aspect.engineerapp`)
2. **Android package name + signing cert SHA-1 fingerprint** (run `keytool -list -v -keystore <your-keystore>`)
3. **Will you use `aad_oauth` or `msal_flutter`?** (Affects the exact redirect URI format I register.)
4. **Test engineer account** — do you have access to a real engineer's Microsoft login for testing, or do you need me to provision a test ServiceResource in Salesforce sandbox?

Drop the answers in our Slack thread and I'll:
- Add the mobile platform to the existing Azure app registration (5 min)
- Send you the `client_id` + final redirect URIs (1 min)
- Get started on the `/api/auth/mobile/exchange` endpoint

---

## 10. References (for digging deeper)

- Web OAuth flow source: [backend/blueprints/auth.py](../backend/blueprints/auth.py)
- Role resolution logic: [backend/access_control.py](../backend/access_control.py)
- Frontend session check: [frontend/src/shared/contexts/AuthContext.tsx](../frontend/src/shared/contexts/AuthContext.tsx)
- Engineer-vs-office routing: [frontend/src/App.tsx](../frontend/src/App.tsx)
- Microsoft PKCE flow docs: https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow
- Microsoft "add a platform" guide: https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app
