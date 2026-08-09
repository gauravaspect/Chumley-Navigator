# Chumley-Navigator — Demo flow audit  
## Engineer app writes + remedial work capture

**Date:** 2026-08-05  
**Scope:** Static code audit of this Flutter repo only. No runtime execution, no live API calls, no Navigator-PPM source in this workspace.  
**Audience:** Investor demo (Tuesday) — refine from fully hardcoded demo toward Ankit demo API writes + raise-recommendation flow.

---

## Executive summary

| Area | Finding |
|------|---------|
| Job completion | Local UI only (`_statusIndex++`, form `pop(true)`). No status POST exists. |
| PPM list | **GET** `/api/demo/ppm-tasks` is wired. **No POST** for status changes in Flutter. |
| Forms / photos | Forms are client-local; photo “capture” is a toggle stub (no camera/upload). |
| Assigned work | Appointments from profile GET (session); PPM tasks in cubit memory only — not Prefs-persisted. |
| Raise recommendation | No product concept. Enquiries tab is UI-only (`onTap: () {}`). Closest cousin: Raise FP (backend) / Raise Reactive (fake dialog). |
| PPM `PENDING_REVIEW` write | **Not present** in this repo. `ppm_visits.py` is not in this workspace — cannot verify lines 780–787 from here. |
| Dual complete write | Client can fire two POSTs on one tap **if** both endpoints + auth are known. Only Ankit GET path is evidenced here. |

---

## 1. Existing engineer flow — screens

Screens an engineer uses (or can reach) to work a job:

| Screen | Path | Purpose |
|--------|------|---------|
| **Dashboard** | `lib/screens/dashboard/dashboard_screen.dart` | Home surface: KPIs, points, calendar of appointments + PPM tasks. |
| **Dashboard calendar** | `lib/components/dashboard/dashboard_calendar.dart` | Day schedule; tap appointment → `JobDetailPage`; tap PPM → `PpmJobDetailPage`. |
| **Job detail (reactive / SF appointment)** | `lib/screens/job_details/job_detail_page.dart` | Full job lifecycle UI: map, status slider, pre-completion forms (LD / Damp / Vent), Raise Jobs (FP / multi-FP / reactive), related docs (dummy). |
| **PPM job detail** | `lib/screens/job_details/ppm_job_detail_page.dart` | PPM shell: task metadata + CP12 / EICR form rows. **No** status slider, **no** mark-complete CTA. |
| **LD / Damp / Vent forms** | `lib/screens/forms/ld_form_page.dart`, `damp_survey_form_page.dart`, `vent_hygiene_form_page.dart` | Opened from `JobDetailPage` when status ≥ “In Progress” (`isOnSite`). Save → `Navigator.pop(true)`. |
| **CP12 / EICR forms** | `lib/screens/forms/cp12_form_page.dart`, `eicr_form_page.dart` | Opened from `PpmJobDetailPage`. Local validation + `pop(true)`. Spec: no API in v1 (`docs/superpowers/specs/2026-08-03-cp12-ppm-form-design.md`). |
| **Fixed price wizard** | `lib/screens/job_details/fixed_price_page.dart` | “Raise FP” from job detail → catalog + `POST /api/work-orders`. **Wired to backend.** |
| **Forms catalog (orphan)** | `lib/screens/forms/forms_screen.dart` | Standalone forms list. **Not** registered in `lib/utils/routes.dart` or `lib/screens/home/home.dart` — no in-app navigation found. |
| **Vehicle check / VCR** | `lib/screens/vehicle_check/*` | Fleet inspection (not job completion). **Wired:** `POST /api/vcr/submit`. |
| **Enquiries** | `lib/screens/enquiries/enquiries_screen.dart` | Internal support-style enquiry form. Submit is a no-op. |

Entry path for demo job work: **Home → Dashboard calendar → JobDetailPage or PpmJobDetailPage**.

---

## 2. Current “completion” mechanism

### Reactive / appointment jobs (`JobDetailPage`)

**Status lifecycle (local only):**

```75:105:lib/screens/job_details/job_detail_page.dart
  static const List<String> _statusLabels = [
    'Scheduled',
    'Dispatched',
    'In Transit',
    'In Progress',
    'Job Completed',
  ];
  // ...
  static const List<String> _actionLabels = [
    'Slide to Dispatch',
    'Slide to Start Transit',
    'Slide to Arrive On Site',
    'Slide to Complete Job',
    '', // terminal state
  ];
```

Confirm handler only increments local state:

```2207:2217:lib/screens/job_details/job_detail_page.dart
            if (!isCompleted)
              CallStyleActionSlider(
                // ...
                onConfirm: () {
                  setState(() {
                    _statusIndex++;
                  });
                },
              )
```

| Mechanism | Present? | Backend? |
|-----------|----------|----------|
| Mark-complete via action slider | Yes | **UI-only** — no HTTP |
| Form capture (LD / Damp / Vent) | Yes | **UI-only** — `pop(true)` / checkbox; no API imports in `lib/screens/forms/` |
| Photo upload on job forms | Stub UI only | **No** — CP12/EICR toggle `_capturedPhotos` / `_photos` sets; no `ImagePicker` in those form pages |
| Raise Fixed Price | Yes | **Wired** — `POST /api/work-orders` (`ApiEndpoints.submitWorkOrder`) |
| Raise multiple FP / Raise Reactive | Dialog “Success” | **UI-only** — `_handleRaiseJob` (`job_detail_page.dart` ~1616–1663) |
| Related docs / previous history rows | Yes | **Dummy** — `onTap: () {}` |

Forms unlock when `_statusIndex >= 3` (“In Progress”), labeled “Requires On Site” in UI — naming mismatch with calendar’s `"on site"` colour map (`dashboard_calendar.dart` ~530–540).

### PPM jobs (`PpmJobDetailPage`)

| Mechanism | Present? | Backend? |
|-----------|----------|----------|
| Status transitions | No | — |
| CP12 / EICR complete flags | Yes (`_cp12Completed` / `_eicrCompleted`) | **UI-only**, page state |
| Photo on CP12/EICR | Placeholder buttons | **UI-only** (design: “Photo capture = placeholder”) |
| Visit complete / submit group | **Absent** | — |

### Other writes (not job completion, but real POSTs)

| Feature | Endpoint | File |
|---------|----------|------|
| VCR submit | `POST /api/vcr/submit` | `vehicle_check_api_service.dart` |
| Absences | `POST /api/engineer/absences` | absences stack |
| Fixed-price WO | `POST /api/work-orders` | `fixed_price_api_service.dart` |
| Auth | `POST /api/auth/mobile/exchange`, signout | login stack |

---

## 3. Local state for assigned work

| Data | Source | Persistence |
|------|--------|-------------|
| Appointments | `GET /api/engineer/{id}` → `UserModel.dashboard.appointmentsThisMonth` | **Not** in Prefs. `Prefs.saveUser` uses `toCacheJson()` which **strips** dashboard/appointments (`user_model.dart` ~411–420). Same-session (and refresh) only. |
| PPM tasks | `GET /api/demo/ppm-tasks?engineer_email=…` + `X-Demo-Key` | Held in `DashboardCubit` / `DashboardState.ppmTasks`. Spec explicitly out of scope for Prefs cache (`docs/superpowers/specs/2026-08-03-ppm-calendar-design.md`). Lost on process kill; survives only while cubit state retained. |
| Job status / form completion flags | `StatefulWidget` fields on detail pages | **Session / page only** — leave page → reset |
| Auth / profile header / points | Prefs / secure storage | Persisted |
| Hardcoded `lib/demo/*` | Planned in `# Investor Demo — Plan.md` | **Not implemented** — no `lib/demo/` tree, no `kDemoMode` |

**Verdict:** Assigned work is **live (or best-effort) fetch per session**, not a hardcoded demo repository. Completion progress is **ephemeral UI state**.

---

## 4. Writes back to Ankit’s demo API

### What exists today

| Item | Evidence |
|------|----------|
| Base URL | `AppConstants.apiBaseUrl` default `https://navigator.chumley.ai` (`lib/core/app_constants.dart`) |
| GET path in app | `ApiEndpoints.getPpmJobs = '/api/demo/ppm-tasks'` (**plural**) |
| GET client | `DashboardApiService.fetchPpmJobs()` — email query + `X-Demo-Key: AppConstants.demoApiKey` |
| Models | `lib/models/ppm_jobs_models.dart` (`PpmJobTask`, includes `status`, `Id`, etc.) |
| POST status | **None** — no `post`/`put`/`patch` for demo PPM; `ApiClient` has no `patch` helper |
| Path note | Query cited `…/api/demo/ppm-task` (singular). **Code only references plural GET.** POST contract not present in this repo. |

### What would need adding in Flutter (for Scheduled → Dispatched → On site → Visit Complete)

Assuming Ankit exposes a POST (or PATCH) on the demo task API — **contract must be confirmed with Ankit; not in this codebase**:

1. **Endpoint constant(s)** in `lib/core/network/api_endpoints.dart`  
   e.g. status update path + body shape (task id, status string, engineer email).

2. **Service methods** (extend `DashboardApiService` or small `DemoPpmApiService`):  
   - Keep existing GET (already acts as “poll / load assigned tasks”).  
   - Add POST/PUT with `X-Demo-Key` (+ Bearer if required by server).

3. **Wire status transitions**  
   - **Reactive path:** `CallStyleActionSlider.onConfirm` in `job_detail_page.dart` — today only `_statusIndex++`.  
   - **PPM path:** `PpmJobDetailPage` has **no** slider — must add lifecycle UI **or** reuse `JobDetailPage` patterns.  
   - Map UI labels to Ankit’s status vocabulary (app uses “In Progress” / “Job Completed”; calendar also knows `"on site"`; demo narrative uses “On site” / “Visit Complete” — **align strings**).

4. **Optional refresh**  
   Re-call `fetchPpmJobs` / dashboard `refresh()` after successful POST so calendar status matches.

5. **Not required:** New HTTP stack — reuse `ApiClient` + Dio. New client only if PPM uses a different base URL/auth.

**Effort (Flutter only, after POST contract locked):** ~4–8 h  
**Risk:** Medium — status string mismatch; auth (demo key vs Bearer); singular vs plural path; PPM page missing transition UI.

---

## 5. Write back to Navigator-PPM (`PENDING_REVIEW`)

### Evidence in this repo

| Claim | Status |
|-------|--------|
| Flutter client for Navigator-PPM visits | **None** — no PPM visit base URL, no `ppm_visits` paths in `ApiEndpoints` |
| `ppm_visits.py` lines 780–787 | **Not in workspace** — cannot verify submit-group / `PENDING_REVIEW` from this audit |
| Cross-repo plan mentions | `# Investor Demo — Plan.md`: PPM has real engineer execution + TM `approve_visit_group` / `reject_visit_group`; seed contingency assumes completed visit **seeded**, not live from Flutter (`X6`) |
| Enquiry helper (PPM side, plan only) | Plan cites `services/enquiry_service.py:703` (`simulate_quote_acceptance`) — not Flutter |

### Can Flutter also write PPM?

**In principle:** yes — second `ApiClient`/base URL or same Dio with PPM host, call whatever submit-group endpoint exists, flip visit to `PENDING_REVIEW`.

**From this repo today:** no wiring, no auth story for PPM staff/engineer tokens, no visit/group IDs on `PpmJobTask` beyond Salesforce-shaped demo fields (`Id`, `AppointmentNumber`, etc.). Mapping demo task → PPM visit group ID is **unspecified here**.

**Risk:** High for Tuesday unless PPM owner documents: base URL, auth, exact route, required body, and ID join key to Ankit/demo task.

---

## 6. Dual write on one “complete” tap?

| Option | Feasibility (Flutter) | Demo risk |
|--------|----------------------|-----------|
| **Ankit only** | Straightforward once POST exists; hook one handler | Low–medium |
| **Ankit + PPM** | Two awaits in same `onConfirm` / complete button; show success if both OK (or soft-fail one) | High without PPM contract + seed ID mapping |
| **PPM only** | Possible but unused by current demo calendar GET | Breaks Ankit Gantt/office story if that depends on demo API |

**Recommendation for demo:** Prefer **Ankit write as the live engineer signal**; keep PPM completion **seeded or office-side** unless Danyal delivers a verified mobile-facing submit endpoint and join key this week. Dual-fire is a small Flutter change **after** both contracts exist — not the risky part; **identity/auth/ID mapping** is.

---

## 7. Recommendation / raise-enquiry — keyword search

Searched: `recommendation`, `lead`, `enquiry`, `referral`, `remedial`, `upsell`, `opportunity`, `quote_request`.

| Hit | Meaning for demo |
|-----|------------------|
| `EnquiriesScreen` | Support categories (“job Issue”, “Payment Query”, …). Submit **no-op**. Not commercial/remedial lead. |
| Points `lead_conversion` / `referrals` | Scoring categories from points API (`points_model.dart`, redeem breakdown). Display only. |
| Leaderboard `referrals` | Metric field. Not a create-lead flow. |
| EICR “Reasons for the recommendation” | Form field text inside certificate — local. |
| Damp form copy “recommend remediation” | Scope copy in `form_details.dart`. |
| Chumley chat `recommendation` appendix | AI chat payload field — unrelated. |
| Job detail “Raise Reactive” / “Raise FP” | Closest UX pattern; FP is real WO submit; Reactive is fake dialog. |
| `quote_request` / `upsell` / `opportunity` | **No matches** as product features. |

**Verdict:** No “raise recommendation / PPM contract opportunity / remedial project lead” concept in the Flutter app today.

---

## 8. Minimum new UI for “Recommend PPM contract” + “Recommend remedial work”

**Best attach points:**

1. **Reactive completion** — after final slider step / on completed banner in `JobDetailPage` (`_buildCompletedBanner` / `_buildActionsPanel`), or inside “Raise Jobs” card as two new rows (same pattern as Raise FP).  
2. **PPM completion** — only after adding a complete control on `PpmJobDetailPage` (doesn’t exist yet).

**Minimum UI (demo):**

- Two `ListTile` / raise-job style buttons: “Recommend PPM contract”, “Recommend remedial work”.  
- Optional: one-line notes `TextField` + confirm dialog.  
- Snackbar / dialog on success (mirror `_handleRaiseJob`).  
- Do **not** need full enquiry history UI for Tuesday.

**Effort:** ~2–4 h UI-only; +2–4 h if POSTed to a real endpoint.

---

## 9. Where would those buttons POST?

| Target | In Flutter today? | Notes |
|--------|-------------------|-------|
| Navigator engineer enquiry API | **No endpoint** in `ApiEndpoints` | Enquiries screen has no service layer |
| Ankit `/api/demo/*` | Only GET ppm-tasks known here | Could host a demo “recommendation” POST if Ankit adds it |
| PPM enquiry create | Not in Flutter; plan references PPM `enquiry_service.py` | Ideal product target (asset, customer, source job, recommendation type) — **needs PPM API contract** |

**Ideal (product):** PPM endpoint creating enquiry with metadata: asset, customer, source job/appointment id, type (`ppm_contract` | `remedial`).  
**Demo fallback:** POST to Ankit demo API **or** UI-only success dialog while PPM shows a pre-seeded enquiry.

---

## 10. Post-visit reporting surfaces

| Surface | What engineer sees | Job history / submitted reports? |
|---------|-------------------|----------------------------------|
| Dashboard points / earnings cards | Points + earnings aggregates from API | Not per-job reports |
| `EarningsDetailScreen` | Placeholder: “Detailed earnings breakdown will appear here.” | Empty |
| `GoalsTargetsScreen` | KPI pool cards (from user or static) | Not visit reports |
| Leaderboard / Milestones / Redeem points | Performance / badges / points breakdown (includes lead/referral **categories**) | Not submitted job certificates |
| Job detail “Previous Job History” row | Static subtitle | Dummy tap |
| Profile | Cached profile | No visit list |

**No** dedicated post-completion “my submitted visits / certificates / what I earned on this job” screen.

---

## 11. Post-visit reporting — Tuesday scope?

| Choice | Hours | Notes |
|--------|-------|-------|
| **Out of scope** (narrate points/leaderboard) | 0 | Surfaces already exist for “engineer performance” story |
| **Quick fake history screen** | 2–3 h | Hardcoded 1–2 completed rows matching shared dataset |
| **Real history from API** | Not evidenced | No endpoint in app |

**Recommendation:** Keep **out of scope** for Tuesday unless the narrative requires a click into “what I submitted”; use seeded PPM portal + office TM review for the completion outcome.

---

## Concrete task list (effort + risk)

### A. Ankit status writes — **needed for live engineer → office signal**

| # | Task | Hours | Risk |
|---|------|-------|------|
| A1 | Confirm with Ankit: POST/PATCH path (singular `ppm-task` vs plural `ppm-tasks`), body, allowed statuses, auth headers | 1–2 (coord) | — |
| A2 | Add endpoint + `updatePpmTaskStatus` (or equivalent) on dashboard/demo service; reuse `ApiClient` + `X-Demo-Key` | 1–2 | Straightforward |
| A3 | Map slider / new PPM lifecycle to Ankit status strings; call POST on each transition (or only on final complete) | 2–4 | Medium (label mismatch) |
| A4 | Add status slider / Complete CTA on `PpmJobDetailPage` (currently missing) | 2–3 | Straightforward UI |
| A5 | Refresh dashboard PPM list after success | 0.5–1 | Straightforward |
| A6 | Handle errors without bouncing to login (`DioInterceptor.onUnauthorized`) | 1 | Medium if 401 on demo key |

**Subtotal A:** ~7–14 h after contract locked.  
**Straightforward:** A2, A4, A5. **Risky:** A1/A3 string + path alignment; A6 auth.

### B. PPM `PENDING_REVIEW` write — **optional / high risk**

| # | Task | Hours | Risk |
|---|------|-------|------|
| B1 | Obtain PPM submit-group contract + auth + visit group id mapping from demo task | 2–4 (coord + spike) | **Risky** — not in this repo |
| B2 | Second HTTP client / base URL + POST on complete | 2–3 | Medium |
| B3 | Dual-write orchestration + partial-failure UX | 1–2 | Medium |

**Subtotal B:** ~5–9 h **if** contract exists. Without it, defer; seed PPM completed visit (plan X6).

### C. Raise recommendation — **new narrative**

| # | Task | Hours | Risk |
|---|------|-------|------|
| C1 | Two buttons on job completion / Raise Jobs card | 1–2 | Straightforward |
| C2 | Optional notes + success dialog (UI-only demo) | 1 | Straightforward |
| C3 | Wire POST to PPM enquiry or Ankit demo endpoint | 2–4 | **Risky** until endpoint exists |
| C4 | Seed/show enquiry on PPM dashboard for hand-off | PPM owner | Outside Flutter |

**Subtotal C:** 2–3 h UI-only; 4–7 h with real POST.

### D. Post-visit reporting

| # | Task | Hours | Risk |
|---|------|-------|------|
| D0 | Skip for Tuesday; use points / narrate | 0 | — |
| D1 | Optional hardcoded “Recent submissions” screen | 2–3 | Straightforward |

### E. Explicitly do **not** need for Tuesday (unless scope creeps)

- Real photo upload for CP12/EICR (VCR already proves multipart pattern if needed later).  
- Persisting job status in Prefs.  
- Full hardcoded `lib/demo` mode from investor plan (app already hits live demo GET).  
- Wiring `EnquiriesScreen` as-is (wrong category model; submit dead).

---

## Suggested Tuesday cut line

1. **Must:** Ankit GET (done) + **Ankit status POST** on complete (and preferably intermediate slides) — Task **A**.  
2. **Should:** Recommendation buttons as **UI + optional Ankit/PPM POST** — Task **C1–C2** minimum.  
3. **Defer if blocked:** PPM `PENDING_REVIEW` dual write (**B**) — use seed.  
4. **Out of scope:** Post-visit history screen (**D**).

---

## File index (primary)

| Concern | Files |
|---------|--------|
| Demo GET | `api_endpoints.dart`, `app_constants.dart`, `dashboard_api_service.dart`, `ppm_jobs_models.dart`, `dashboard_cubit.dart` |
| Calendar / navigation | `dashboard_calendar.dart`, `dashboard_screen.dart` |
| Reactive completion | `job_detail_page.dart` |
| PPM detail / forms | `ppm_job_detail_page.dart`, `cp12_form_page.dart`, `eicr_form_page.dart` |
| Real WO write | `fixed_price_api_service.dart`, `fixed_price_page.dart` |
| Enquiries (dead submit) | `enquiries_screen.dart` |
| Prefs / no appointment persist | `prefs.dart`, `user_model.dart` `toCacheJson` |
| Specs | `docs/superpowers/specs/2026-08-03-ppm-calendar-design.md`, CP12/EICR form specs |
| Demo plan (context) | `# Investor Demo — Plan.md` |

---

## Gaps this audit cannot close (need owners)

1. Ankit: exact **POST** schema for `/api/demo/ppm-task(s)` status updates.  
2. PPM: confirm `ppm_visits.py` submit-group → `PENDING_REVIEW` path, auth, and ID join to Flutter `PpmJobTask.id`.  
3. Product: which system owns “recommendation” enquiries for the live demo hand-off.
