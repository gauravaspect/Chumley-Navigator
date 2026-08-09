# Investor Demo — Plan



---

## The Story We're Selling

Aspect's operational business runs through Navigator. PPM and PM are two product lines underneath the Navigator umbrella. Office staff schedule all work — reactive, PPM, PM — from the Navigator Dashboard. Engineers execute work through the Navigator App. Customers see outcomes through per-product portals.

That's the single message. Every screen we show serves it.

---

## The Demo — Click Path

Rough sequence, ~10-12 minutes. Numbers are the surface being shown.

1. **[PPM Dashboard]** Office user opens PPM. Show a customer account with a completed survey.
2. **[PPM Dashboard]** Send quote to customer.
3. **[PPM Customer Portal]** Customer receives quote, accepts it. Contract activates.
4. **[PPM Dashboard]** Show generated PPM visit schedule.
5. **[Navigator Dashboard]** Switch to Navigator. Show the office scheduling view — reactive, PPM, and PM work on the same Gantt.
6. **[Navigator Dashboard]** Assign an engineer to a PPM visit.
7. **[Navigator App]** Switch to Flutter app. Engineer sees three items today: reactive, PPM, PM.
8. **[Navigator App]** Engineer taps the PPM visit → completes tasks with form + photo → submits.
9. **[PPM Dashboard]** Trade manager reviews the completed visit and approves.
10. **[PPM Dashboard]** Office sends the completed visit + certificate to customer.
11. **[PPM Customer Portal]** Customer sees the completed visit and downloadable certificate.
12. **[Narration only]** "The same pattern applies for PM work under Navigator-Insurance."

---

## What Each Surface Shows

| Surface | What it demonstrates | Approach |
|---|---|---|
| PPM Dashboard | Contract lifecycle end-to-end, TM approval, send to customer | Real UI, real endpoints, seeded database state |
| PPM Customer Portal | Customer accepting quote, viewing completed visit + certificate | Real UI, real endpoints, seeded database state |
| Navigator Dashboard | Unified scheduling of all work types | Mock injection into Gantt response |
| Navigator App | Engineer's mixed queue and PPM completion flow | Fully hardcoded demo mode |
| PM (narrated) | Same pattern for insurance-led work | No live demo — narrated |

---

## Team Ownership

| Owner | Repo | Scope |
|---|---|---|
| **Danyal** | Navigator-PPM | Seed data, cosmetic cleanups, demo path verification |
| **Nav Team** | agent-performance-dashboard | Mock injection into Gantt, hide non-demo tabs |
| **Nav App dev** | Chumley-Navigator | Demo-mode data + completion flow in existing app |


---

## Shared Dataset — Locked Values

These values must be identical across all three surfaces. Danyal owns them and shares once — everyone else builds against them.

| Field | Value |
|---|---|
| Customer name | *[TBD — Danyal to lock today]* |
| Site address | *[TBD — real-looking London postcode]* |
| Engineer name (primary) | *[TBD — British name]* |
| Engineer name (secondary) | *[TBD]* |
| Demo-day date | *[Tuesday's date]* |
| PPM visit reference format | `SA-YYYYMMDD-NNN` |
| Task type for demo | CP12 (Gas Safety) and EICR — one only |
| Portal login for demo customer | *[TBD — email + fixed OTP]* |

**Cross-repo rule:** if any of these change, all three teams update. Nothing is derived independently.

---

# PPM Side (Danyal)

## What PPM already does well

The PPM codebase carries the heaviest demo load and is genuinely in good shape:

- Staff console (Accounts, Sites, Contacts, Roles, Sectors) — full CRUD, works
- Quote pipeline including "send to customer" — real flow, real button
- Customer accepts quote via portal — real token-based flow
- Contract activation generates PPM visit schedule — reliable
- Visit assignment endpoints — real
- Engineer visit execution with photo upload and certificate capture — real
- TM approval workflow (`approve_visit_group`, `reject_visit_group`) — real, not a stub
- Customer portal viewing certificates — endpoint + page both exist

No new features needed. The gap is seeded data plus cosmetic cleanups.

## What Danyal owns

### 1. Demo seed script

New file, one-shot. Populates the demo customer end-to-end:

- 2 Accounts (primary + one for list texture)
- 3 Sites (2 under primary, 1 under secondary), London addresses
- 2 AccountContacts (portal logins)
- 2 Customer-role Users
- 3 Engineers with names matching Flutter + Dashboard mock
- 1 completed Survey with asset register
- 8–12 Assets
- 1 activated Quote (`APPROVED`, `activated_at`, `contract_start_date` set to demo day)
- 5–8 QuoteLineItems
- 6 PpmVisitGroups spread across contract period:
  - 1 `COMPLETED` (so portal has something to show)
  - 1 `SCHEDULED` on demo day (assigned live during demo)
  - Rest future
- 3–4 PpmVisitTasks per group, at least one CP12 on completed group
- 1–2 CertificateSubmissions on completed group
- Optionally: 1 DRAFT Quote for the "send to customer" live click

Uses the existing `simulate_quote_acceptance` helper (`services/enquiry_service.py:703`) where useful to avoid OTP email round-trips.

### 2. OTP handling for the demo

Live OTP email is the biggest single failure mode. Options:
- Env-gated fixed OTP code
- Script to read the current code from `customer_otps` table
- Start the demo already logged in

Pick one Thursday. Verify Friday.

### 3. Cosmetic cleanups

| Item | File | Action |
|---|---|---|
| Rename "projects" KPI tiles → "Accounts" | `frontend/src/pages/Dashboard.tsx`, `backend/app/schemas/dashboard.py`, `backend/app/routers/dashboard.py:48-55` | Rename tiles and computed field |
| Hide Style Guide | `frontend/src/App.tsx`, `frontend/src/components/layout/navConfig.tsx` | Remove route + nav entry |
| Trim nav to demo path | `navConfig.tsx` | Hide any entry that would show empty tables |
| Pin demo to `dev` OR merge `dev` → `main` | branch/deploy | Customer-portal 500 fix is only on `dev` |

### 4. Demo path verification

Before Monday rehearsal, click through the full PPM story end-to-end against seeded data. Note anything that surprises. Fix.

## Risks specific to PPM



---

# Navigator Dashboard (Agent Performance Portal)

## Approach

Mock injection. Synthetic PPM and PM appointments injected into the Gantt response and rendered on real engineer lanes. No Salesforce sandbox seeding. Real reactive appointments continue to render alongside untouched.

Rationale: cleaner, self-contained, no data risk from a sandbox mistake, avoids the AssignedResource email side effects if anything were pointed at prod.

## What already works

- 14-tab office console
- Scheduling Gantt (one component, three modes: manual, sandbox, sandbox_v2)
- Assign / move / reschedule endpoint (`PATCH /api/scheduling/appointment/{sa_id}` → `backend/scheduling/router.py:2300-2404`)
- Live change stream via SSE + Salesforce CDC
- Availability, suggestions, travel overlay

**Data source:** Salesforce direct, no cache. Every Gantt load is a live SOQL burst. Response shape at `backend/scheduling/queries.py:1297-1303`.

## Work items

### D1 — Inject synthetic appointments into Gantt response

Append PPM and PM synthetic rows into the right engineer's `appointments` array inside `_serve_gantt`. Frontend unchanged. Must mirror the appointment dict shape (`duration_minutes`, `trade_category`, `trade_group`, `matched_group_key`, status).

Files: `backend/scheduling/router.py:626`, `backend/scheduling/queries.py`.

### D2 — Route assignment for synthetic rows

Prefix synthetic IDs (`ppm-`, `pm-`). Branch at top of `update_appointment` (`router.py:2300`) so prefixed IDs update demo state instead of calling Salesforce. Same for `/status` at `:2536`.

### D3 — Mirror demo engineers onto real lanes

Lanes come from live SF `ServiceResource` rows (`queries.py:1235-1253`). Map synthetic rows onto 2–3 real ServiceResource IDs whose display names match the shared dataset engineer names.

### D4 — Verify write-permitting Schedule tab

Permission docs (`backend/permissions/core.py:87-93`) describe `scheduling_manual` as "SF writes not yet enabled" and `scheduling_gantt_v2` as "no action is ever written back." Frontend does not appear to key on `mode` for a write-lock. **Live click-test required Thursday** — verify which tab actually writes so the demo uses only that one.

### D5 — Multi-day rendering check

Gantt handles multi-day *absences* explicitly (`frontend/src/office/lib/ganttUtils.ts:130`). Multi-day *appointments* unverified. If the Gantt clamps to a day, emit a series of daily bars instead. Verification only, code change if needed.

### D6 — PM engineer lane filtering

`queries.py:1243-1248` notes the frontend uses `tgp` to exclude non-dispatchable roles (Key/PM/Utilities) via `DEFAULT_EXCLUDED_GROUP_KEYS`. Put PM work on a normal dispatchable engineer's lane, or relax the filter.

## What needs to be hidden

| Item | File | Action |
|---|---|---|
| Two of three Schedule tabs | `officeTabs.tsx:49-50` and `:62` | Remove non-demo tabs from `MANAGED_OFFICE_TABS`, or revoke permission for the demo user |
| `?as=` engineer preview banner | `frontend/src/app/App.tsx:11-17,68`, `engineer/EngineerApp.tsx:95-120` | Don't use `?as=` on stage |
| Engineer web shell | `frontend/src/engineer/*` | Do not open on stage — engineer surface is Flutter |
| Red Flags, Suspicious Activity tabs | `officeTabs.tsx:43-44` | Keep on demo path only if data reads well; both surface real engineer conduct data |

## Seed data required

No database or Firestore seeding — all fixtures live in Python.

- 4–6 synthetic PPM appointments
- 2–3 synthetic PM appointments (or a daily series if D5 says clamp)
- 2–3 real ServiceResource IDs to alias with demo engineer names
- Assignment state in-memory or small JSON file so live reassignments survive a page refresh

## Risks specific to Dashboard

- **Every Gantt load hits Salesforce live.** Slow or rate-limited SOQL on stage is a visible hang. Load the tab before demo starts. Avoid date-range changes mid-demo.
- **D4 unverified.** The permission text and the code disagree, and the assign click is the whole narrative rest-point. Test it Thursday, not Tuesday.
- **CDC/SSE.** Gantt subscribes to a live change stream. A real production change mid-demo will move a bar unexpectedly.
- **Injected rows must survive frontend filtering.** `DEFAULT_EXCLUDED_GROUP_KEYS` and trade-group matching can silently drop rows with unexpected `trade_category`/`tgp`. Budget debugging time inside D1.
- **Live production data on screen.** Leaderboard, Red Flags, Suspicious Activity show real engineers by name with conduct and theft analytics. Decide deliberately what stays on screen.

---

# Navigator App (Chumley-Navigator, Flutter)

## Approach

Fully hardcoded demo mode. No backend calls, no WebView, no auth. Real Flutter app running against hardcoded data.

## What already works

- State management: `flutter_bloc` / cubit
- Auth library: `aad_oauth` (not MSAL)
- Single DI container: `lib/core/app_dependencies.dart:31-113` — every repository constructed in one static class. This is the ideal seam for demo mode.
- Job detail screen: `lib/screens/job_details/job_detail_page.dart` (~2,500 lines), already backend-free — only outbound calls are TomTom tiles and a Google Maps deep link
- Dashboard calendar rendering appointments: `lib/components/dashboard/dashboard_calendar.dart`
- `image_picker`, `flutter_image_compress`, `path_provider`, `action_slider` all present in `pubspec.yaml`
- Vehicle check flow, forms screens, leaderboard, milestones, points, absences — all built with shimmer loading states

The app already looks finished. The gap is data plus the job-completion actions.

## Work items — to be sized by Nav App dev

The Flutter dev has been in this codebase and knows what already exists. The audit's estimate assumed everything was net-new build; Danyal's read is that many of these already exist in some form.

**Nav App dev to confirm which of the below already exist and which need adding.** Numbers below are audit estimates; treat as ceiling, not commitment.

| Ref | Item | Files | Audit hours |
|---|---|---|---|
| F1 | Demo mode flag + demo repositories in `AppDependencies` | `lib/core/app_dependencies.dart`, `lib/demo/*_demo_repository.dart` | 4–6 |
| F2 | Login bypass; neutralise `DioInterceptor.onUnauthorized` (`app_dependencies.dart:106-111`) | `lib/core/app_dependencies.dart`, `lib/screens/login/*` | 1–2 |
| F3 | Today / job list view (audit says no job list exists — only calendar) | new screen + `lib/utils/routes.dart` | 3–4 |
| F4 | Job detail wired to hardcoded data with completion flow via existing `CallStyleActionSlider` | `lib/screens/job_details/job_detail_page.dart` | 6–8 |
| F5 | Photo capture on completion | `job_detail_page.dart`, new widget | 3–4 |
| F6 | Certificate / form capture (CP12) | `lib/screens/forms/*` | 3–4 |
| F7 | Extend `Appointment` model with address, customer, tasks fields | `lib/models/user_model.dart` | 1–2 |
| F8 | Match hardcoded data to shared dataset | `lib/demo/*` | 1 |

## What needs to be hidden

| Item | File | Action |
|---|---|---|
| Screens whose demo repo isn't written | all cubits | Hide nav entry rather than show empty state |
| Enquiries screen | `lib/screens/enquiries/enquiries_screen.dart` | Hide unless demo repo written |
| Redeem points | `lib/screens/redeemPoints/redeem_points.dart` | Off-narrative; hide |
| `onTap: () {}, // dummy` at `job_detail_page.dart:1525` | same | Remove or wire |
| Real API base URL | `lib/core/app_constants.dart` | Blank in demo builds |
| `.env` committed at repo root | `Chumley-Navigator/.env` | Check no live secrets before screen-share |

## Seed data required

Hardcoded in Dart under `lib/demo/`. No database, no Firestore.

- 1 engineer profile (name matches shared dataset)
- 1 set of KPI / points / earnings — plausible numbers
- 3 appointments for today (1 PPM, 1 PM, 1 reactive) — matches shared dataset
- 5–8 appointments across the week for calendar texture
- 3 job details (address, customer, task list, contact) — matches shared dataset
- 1 certificate/form (CP12) matching PPM
- 8–10 leaderboard rows
- 1 milestones/journey set
- 2 absences

## Risks specific to Nav App

- **Largest single build item across all four repos** — F3 to F6 is the bulk of the work. If any leg slips, this is it.
- **Demo-mode leakage.** If the `kDemoMode` flag isn't clean, a stray real call fires against production. Blanking the base URL is belt-and-braces.
- **`DioInterceptor.onUnauthorized` force-navigates to login.** If any call escapes demo mode, the app bounces to the login screen mid-demo. Must be neutralised (F2).
- **Build/signing.** Confirm which device the demo runs on and that a build installs Friday, not Monday.

---

# Cross-Repo Dependencies

Everything below must be identical across PPM seed, Flutter hardcode, and Dashboard mock.

| # | Dependency | Owner |
|---|---|---|
| X1 | Engineer names across three surfaces | Danyal sets, both teams consume |
| X2 | Customer name across three surfaces | Danyal sets |
| X3 | Site addresses across three surfaces | Danyal sets |
| X4 | Demo-day date across three surfaces | Danyal sets — Tuesday |
| X5 | Job / appointment reference format | Danyal sets |
| X6 | PPM completed visit exists as seeded state | Danyal — the customer portal certificate is seeded, not from live engineer completion |

---


---

# Rehearsal & Freeze Plan



Full end-to-end run in the demo environment on the demo hardware. Every click, every login, every hand-off. Time it. Note every issue.



Second run after Monday morning fixes. If still finding new issues, third rehearsal Monday evening.

## Environment freeze

-  no more code changes across any of the four repos
- No deploys to demo environments after 6pm
- No re-runs of the seed script on the demo DB after 6pm
- Communicate freeze to all involved



Final walkthrough with everything already authenticated. Do not log out. Do not close browser tabs. Do not restart the phone.

---

# Contingencies

**If Flutter completion doesn't work on stage:** the PPM completed visit is already seeded — narrate over the missing step and switch to PPM customer portal to show the outcome.

**If Dashboard assign click fails:** the pre-assigned PPM appointment is already visible on the Gantt — narrate "and here we can see the assignment" without clicking.

**If PPM customer portal fails to load:** show the customer portal via a pre-loaded browser tab that stays open throughout.

**If OTP email fails:** the demo customer is already logged in via a pre-loaded browser tab.

**If Gantt is slow to load:** it's already open before the demo starts. Don't refresh.

**If any auth times out:** all sessions pre-authenticated in browser tabs before the demo. Do not close any tab.

---


---

# What This Plan Is Not

- Not production work — everything can be deleted after Tuesday
- Not a roadmap
- Not architectural refactoring
- Not real integration between the four surfaces

It is the concrete task list per team, over five working days, to make Tuesday's demo work.