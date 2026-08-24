# Flow verification report — HTML reference vs Flutter engineer app

**Date:** 2026-08-20  
**Method:** Read-only static comparison. No application code edited.  
**Repos verified:**

| Repo | Path | Role |
| --- | --- | --- |
| `navigator-app-workflows` | `/Users/gaurav/Documents/Work/aspect/navigator-app-workflows` | Reference — Firestore-bound HTML + JS runtimes |
| `chumley_navigator` | `/Users/gaurav/Documents/Work/aspect/chumley_navigator` | Subject — Flutter mobile engineer app |

**Prior audit reconciled against:** `navigator-app-workflows/docs/ENGINEER_APP_ALIGNMENT.md` (2026-08-12)

**Phase 4 (live Firestore walk):** Skipped — Flutter has no Firestore client; Python live-data tests failed TLS cert verification in this environment.

---

## A. Executive summary

- **Flutter is not on the Firestore spine.** Zero hits in `lib/` for `FirebaseFirestore`, `cloud_firestore`, `demo_*` collections, or contract enums (`IN_TRANSIT`, `PPM_INTEREST`, etc.). `lib/pillar/` does not exist. `pubspec.yaml` has no `firebase_core` or `cloud_firestore`.
- **Beat counts:** YES **0** · PARTIAL **6** · NO **18** · N/A **4** (VCR, absences, chat, leaderboard/points reads)
- **Top 3 BLOCKER gaps:**
  1. **No shared store writes** — visit status, sign-off, photos, and raises never reach `demo_engineer_jobs` / `demo_reports` / enquiries; Portal, Concierge, Dashboard, and PPM cannot see engineer work.
  2. **Home reads REST, not Firestore** — reactive jobs come from `GET /api/engineer/{id}` by engineer id, not `demo_engineer_jobs` where `engineer_email == navigatorengineer@aspect.co.uk`.
  3. **False-success UX** — status slider, form save snackbars, CP12 “Captured” toggles, and raise-job success dialogs look done with no durable pillar write.
- **What the reference app proves end-to-end today that Flutter cannot:** live job list from Firestore → contract status ladder with timeline → trade-aware form routing → job-id localStorage → Azure photo upload → sign-off batch (`COMPLETE`, `completion_data`, `demo_reports`, `demo_job_photos`, PM project recount) → FP/PPM/PM/RA/Refer raises into pillar collections (plus PPM HTTP forward via `serve.py`).

---

## B. How the reference flow works

**Home:** `live_bind.js` subscribes `demo_engineer_jobs.where("engineer_email", "==", "navigatorengineer@aspect.co.uk")` via `onSnapshot`; PM labels from `demo_pm_projects`; completed jobs stay in backing list (home hides COMPLETE, View All keeps them); refresh via `__REFRESH_JOBS__` → `jobQuery.get()`.

**Visit ladder:** `setStatus()` in `live_bind.js` writes contract enums forward-only using `RANK`; patches `actual_start` on `IN_TRANSIT`, `actual_end` on `COMPLETE`; demotes other in-flight jobs to `DISPATCHED`; appends `demo_job_status_updates` rows.

**Form routing:** `kindOf(job)` routes FP/PM → bathroom works form, leak/gas by trade (not room words in description): `live_bind.js:82-116`.

**Local persistence:** Form answers in `navigator.form.answers` keyed by job id (`form_runtime.js`); progress/resume in `navigator.job.progress` + `__LIVE_JOB_ID__` (`state_runtime.js`); photo upload queue in `navigator.photo.uploads` (`upload_runtime.js`).

**Sign-off:** `signoff_runtime.js` `submit()` batch-updates job to `COMPLETE` with `completion_data` and Azure `photos[]`; sets `demo_reports/{id}__ld|__pm`; `demo_job_status_updates/{id}__complete`; `demo_job_photos/{id}__{slot}` (camelCase); PM branch recounts `demo_pm_projects`.

**Raise flows:** FP estimate → `demo_fp_submissions/fp-{jobId}` + line items + `fp_submission_id` on job (`estimate_runtime.js`); PPM/PM/RA/Refer → `demo_customer_enquiries` with `origin: NAV_APP`, `status: NEW` (`enquiry_runtime.js`); PPM also POSTs `/api/ppm-forward` from server proxy.

**Who reads it:** Customer Portal (reports, photos), Navigator Dashboard (job board, Gantt), Concierge (completion, enquiries), PPM intake (forwarded PPM leads).

---

## C. How the Flutter flow works

**Home:** `DashboardApiService.fetchProfile` → `GET /api/engineer/{engineerId}` for appointments; PPM tasks separately via `GET /api/demo/ppm-tasks?engineer_email=` with `X-Demo-Key`. No Firestore subscription.

**Visit ladder:** `JobDetailPage` holds `_statusIndex` (starts at 1 = Dispatched); slider `onConfirm` only `setState(() => _statusIndex++)` — friendly labels (`In Transit`, `In Progress`), no API/Firestore write. Survives app kill: **no**. Visible to Portal: **no**.

**Forms:** After local “In Progress” (`_statusIndex >= 3`), engineer opens standalone `LdFormPage` / `DampSurveyFormPage` / `VentHygieneFormPage` from the job card — not a unified on-site wizard. Saves show snackbars and `pop(true)`; answers live in widget controllers only. PPM opens `Cp12FormPage` / `EicrFormPage`; completion is two booleans on `PpmJobDetailPage`.

**Sign-off:** Completing all forms + sliding to “Job Completed” is purely local UI (`_statusIndex == 4` shows “All forms submitted. This job is now closed.”). No `completion_data`, reports, timeline, or photos collection.

**Raises:** Job-card “Raise FP” navigates to `FixedPricePage` → real `POST /api/work-orders` (Salesforce-shaped). Follow-on “Multiple FPs” / “Reactive Job” call `_handleRaiseJob` → success dialog only. No PPM/PM lead wizards, no `/api/ppm-forward`, no enquiries.

**Out of pillar but real:** VCR multipart submit, absences GET/POST, auth, chat, points/leaderboard reads.

---

## D. Full gap matrix

| # | Flow beat | Reference (HTML) | Flutter | Match? | Severity | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Home data source | Firestore `engineer_email == navigatorengineer@aspect.co.uk`, `onSnapshot` | REST `GET /api/engineer/{id}` + PPM demo GET by email | NO | BLOCKER | `live_bind.js:1144`; `dashboard_api_service.dart:37-38`, `:110-112` |
| 2 | PM project labels on home | `demo_pm_projects` subscription, `titleOf`/`subtitleOf` | PPM REST fields on `PpmJobTask` (subject, hours) | PARTIAL | MED | `live_bind.js:221-257`; `ppm_job_detail_page.dart:35-39` |
| 3 | Completed jobs visibility | Kept in list; home filters COMPLETE | Whatever REST returns; no client COMPLETE write | PARTIAL | MED | `live_bind.js:467-476`; `job_detail_page.dart:57` |
| 4 | Status IN_TRANSIT | `setStatus` → `{status:"IN_TRANSIT", actual_start}` + timeline | `_statusIndex++`, label “In Transit” | NO | BLOCKER | `live_bind.js:947-983`; `job_detail_page.dart:2213-2216` |
| 5 | Status ON_SITE | Written on form step entry | `_statusIndex >= 3`, label “In Progress” | NO | BLOCKER | `live_bind.js:997-1007`; `job_detail_page.dart:1591` |
| 6 | Status COMPLETE + actual_end | Job patch + timeline `{id}__complete` | `_statusIndex == 4`, banner text only | NO | BLOCKER | `signoff_runtime.js:144-185`; `job_detail_page.dart:489`, `:2152-2154` |
| 7 | Other in-flight → DISPATCHED | `setStatus` demotes siblings | No in-flight registry | NO | HIGH | `live_bind.js:965-975`; no Flutter equivalent |
| 8 | Forward-only status (no demote) | `RANK` guard in `setStatus` | Can only increment index in session | PARTIAL | MED | `live_bind.js:942-951`; reload resets to Dispatched |
| 9 | Resume after reload | `state_runtime.js` + Firestore status | `_statusIndex = 1` always | NO | HIGH | `state_runtime.js:63-82`; `job_detail_page.dart:57` |
| 10 | Form routing (`kindOf`) | FP/PM → works; leak/gas by trade | Hardcoded LD/Damp/Vent list on job card | NO | HIGH | `live_bind.js:82-116`; `job_detail_page.dart:1979-1989` |
| 11 | Works / bathroom form (FP/PM) | `works_runtime.js` | No BF screens | NO | BLOCKER | `works_runtime.js`; no `works_form_page.dart` |
| 12 | Form answers persistence | `navigator.form.answers[jobId]` | Widget controllers; die with route | NO | MED | `form_runtime.js:29-57`; `ld_form_page.dart:74-79` |
| 13 | Form step / resume | `navigator.job.progress[jobId]` | None | NO | MED | `state_runtime.js:63-82` |
| 14 | Job photos → Azure | `upload_runtime.js` POST middleware `/image-upload` | CP12 toggles title in `Set<String>`; no bytes | NO | BLOCKER | `upload_runtime.js:94-143`; `cp12_form_page.dart:1244-1288` |
| 15 | Sign-off batch write | `demo_engineer_jobs`, `demo_reports`, `demo_job_status_updates`, `demo_job_photos` | Snackbar + `pop(true)` on forms | NO | BLOCKER | `signoff_runtime.js:142-198`; `ld_form_page.dart:401-418` |
| 16 | PM visit project recount | `advanceProject` on `demo_pm_projects` | `_cp12Completed` / `_eicrCompleted` booleans | NO | BLOCKER | `signoff_runtime.js:232-280`; `ppm_job_detail_page.dart:29-74` |
| 17 | FP raise (pillar) | `demo_fp_submissions/fp-{jobId}` + line items + `fp_submission_id` | `POST /api/work-orders` Salesforce JSON | NO | BLOCKER | `estimate_runtime.js:181-255`; `fixed_price_submit_payload.dart:267-291` |
| 18 | FP raise from follow-on | Same estimate path | `_handleRaiseJob` success dialog | NO | BLOCKER | `estimate_runtime.js`; `job_detail_page.dart:1616-1664` |
| 19 | PPM lead | `PPM_INTEREST`, `NAV_APP`, `/api/ppm-forward` | No wizard | NO | BLOCKER | `enquiry_runtime.js:348-391`; no Flutter screen |
| 20 | PM lead | `PM_INTEREST`, `NAV_APP` | No wizard | NO | BLOCKER | `enquiry_runtime.js:249-332` |
| 21 | Reactive attendance | Office enquiry with description | Success dialog; description dropped | NO | BLOCKER | `enquiry_runtime.js`; `job_detail_page.dart:1849` |
| 22 | Refer and earn | Enquiry + unassigned job + buddy FP, `customer_id: null` | Success dialog only | NO | BLOCKER | `enquiry_runtime.js:438-525` |
| 23 | Support Enquiries tab | N/A (separate from pillar leads) | Submit `onTap: () {}` — no write | NO | MED | `enquiries_screen.dart:324` |
| 24 | Transcribe / AI scope | `POST /api/transcribe`, `/api/scope` via `serve.py` | Not implemented | NO | MED | `survey_runtime.js`; no Flutter equivalent |
| 25 | PPM HTTP forward | Server proxy, keys off device | No endpoint in `ApiEndpoints` | NO | HIGH | `serve.py`; `api_endpoints.dart:1-38` |
| 26 | Auth / sign-in | Firebase demo rules + engineer identity | `POST /api/auth/mobile/exchange` | N/A | LOW | Out of visit spine |
| 27 | VCR submit | N/A | `POST /api/vcr/submit` multipart | N/A | — | Fleet API, not pillar |
| 28 | Absences | N/A | GET/POST `/api/engineer/absences` | N/A | — | HR API, not pillar |
| 29 | Reference component wiring | `audit_components.py`: 22 wired, 0 dead | No equivalent audit in Flutter repo | N/A | — | Script output below |

---

## E. Prior audit reconciliation

| Prior claim (`ENGINEER_APP_ALIGNMENT.md`) | Still true? | Evidence |
| --- | --- | --- |
| Zero writes to `demo_*` collections | **Confirmed** | Grep `lib/` → zero hits for `demo_`, `Firestore`, `IN_TRANSIT` |
| Home uses REST engineer id, not Firestore email query | **Confirmed** | `dashboard_api_service.dart:26-38` vs `live_bind.js:1144` |
| `_statusIndex` local only; ignores `Appointment.status` | **Confirmed** | `job_detail_page.dart:57`, `:2213-2216` |
| OnSiteWizard drives leak visit | **Wrong / fixed since** | No `OnSiteWizard` in repo; forms are `LdFormPage` et al. opened from job card (`job_detail_page.dart:1979+`). Gap remains (local-only), but prior file name is stale. |
| LD photos “Photo captured (dummy)” | **Partially wrong** | No OnSiteWizard; CP12 uses “+ Capture / upload” toggle without camera (`cp12_form_page.dart:1290-1291`) |
| LD “Draft saved” snackbar | **Partially wrong** | `form_details.dart:220` says “Inspection report draft saved”; `ld_form_page.dart:407` says “LD Form saved.” — same class of false success, different copy |
| FP POST is Salesforce REST, not pillar | **Confirmed** | `fixed_price_submit_payload.dart:257-291` |
| Follow-on raise is fake success | **Confirmed** | `job_detail_page.dart:1616-1664` |
| PPM/PM/RA/Refer wizards missing | **Confirmed** | No screens; grep finds no `PPM_INTEREST` |
| PpmJobDetailPage no complete/recount | **Confirmed** | `ppm_job_detail_page.dart:29-74` |
| Enquiries tab not pillar-shaped | **Confirmed** | Categories like “job Issue”; submit is no-op (`enquiries_screen.dart:324`) |
| No `firebase_core` / `cloud_firestore` | **Confirmed** | `pubspec.yaml:30-62` |
| `MemoryPillarClient` / `lib/pillar/` alignment work | **Not present** | Prior conversation may have targeted this; current tree has no `lib/pillar/` |
| VCR and absences LIVE to REST | **Confirmed** | `api_endpoints.dart:14-16` |
| Bathroom works form missing | **Confirmed** | No BF screens in Flutter |

---

## F. Verification commands run

### `python3 tools/audit_components.py` (reference repo)

```
23 option group(s): 22 wired, 0 dead, 4 multi-select
every option group the app touches is wired
```

### `python3 tools/test_form_routing.py`

**Failed** — `SSL: CERTIFICATE_VERIFY_FAILED` when fetching live `demo_engineer_jobs` (environment TLS trust store).

### `python3 tools/test_pm_progress.py`

**Failed** — same TLS error fetching `demo_pm_projects`.

### Flutter greps (representative)

```
grep -r 'FirebaseFirestore\|cloud_firestore\|demo_\|IN_TRANSIT\|PillarClient' lib/  → 0 hits
grep -r 'firebase' pubspec.yaml  → 0 hits
glob lib/pillar/**  → 0 files
glob on_site_wizard*  → 0 files
```

---

## G. False-success inventory

| Pattern | Reference | Flutter |
| --- | --- | --- |
| Draft / form saved snackbar, no store | Reference persists to `localStorage` by job id before any “saved” UX | `form_details.dart:216-227` (“Inspection report draft saved” + `pop(true)`); `ld_form_page.dart:404-418` (“LD Form saved.”) |
| Photo captured without upload | Reference queues real URLs via middleware | `cp12_form_page.dart:1280-1291` toggles “Captured” on title string in `_capturedPhotos` |
| Success dialog, no write | Reference writes enquiry doc before “Sent” screen | `job_detail_page.dart:1616-1664` (`_handleRaiseJob` for Multiple FP, Reactive, Refer) |
| Job closed banner, no COMPLETE | Reference batch-writes COMPLETE | `job_detail_page.dart:2152-2154` when `_statusIndex == 4` |
| `pop(true)` treated as submitted | Reference `submit()` awaits Firestore batch | `cp12_form_page.dart:370`, `eicr_form_page.dart:477`, `ld_form_page.dart:418` |
| Submit button no-op | — | `enquiries_screen.dart:324` `onTap: () {}` |
| FP submit silent skip | — | `FixedPriceCubit.submitWorkOrder` returns without throw if state ≠ loaded; page may still `pop(true)` (`fixed_price_cubit.dart:94-107`, `fixed_price_page.dart:394-400`) |

Reference runtimes do **not** grep for “Draft saved” / “Photo captured” strings in `app/*.js` — persistence happens before navigation; Flutter snackbars/dialogs are the demo traps.

---

## H. Recommended fix order (verification only)

1. **Row 1, 4–6, 15** — Add Firestore client (`firebase_core`, `cloud_firestore`, project `flowing-garage-481412-p2`); implement `PillarClient` for status + sign-off batch; swap home read to `demo_engineer_jobs` by `engineer_email`.
2. **Row 14** — Wire `ImagePicker` + middleware upload queue; strip SAS from URLs before Firestore write.
3. **Row 10–11** — Port `kindOf` router; build works form for FP/PM.
4. **Row 12–13, 9** — Job-id-keyed Prefs (mirror `form_runtime.js` / `state_runtime.js`).
5. **Row 7–8** — Forward-only status + sibling demotion in Firestore writes.
6. **Row 17–18** — Unify FP raise paths; add pillar `demo_fp_submissions` write (or formally pick REST spine and stop claiming Firestore).
7. **Row 19–22, 25** — PPM/PM/RA/Refer wizards + server-side PPM forward.
8. **Row 16** — PM visit complete + `demo_pm_projects` recount.
9. **Row 23, false-success table** — Hide or relabel until wired; remove empty submit handlers.

---

## I. Manual demo script (15 minutes)

| Step | Expected in Firestore | Reference app | Flutter app |
| --- | --- | --- | --- |
| 1. Open app as demo engineer | Jobs for `navigatorengineer@aspect.co.uk` | Live list from Firestore | REST appointments by engineer id |
| 2. Open reactive leak job | Job doc unchanged until transit | Opens WO; status readable | Opens `JobDetailPage`; `_statusIndex=1` |
| 3. Slide In Transit | `status: IN_TRANSIT`, `actual_start`, timeline row | Writes via `setStatus` | Local label only — **no Firestore change** |
| 4. Arrive on site / form step 1 | `status: ON_SITE` | Writes on enter | Local “In Progress” only |
| 5. Fill one LD answer | Answer in `localStorage` keyed by job id | Persists | Lost if you leave form |
| 6. Capture photo | URL in upload queue → sign-off batch | Azure upload | CP12 toggle or no photo on LD path |
| 7. Submit report / sign-off | `COMPLETE`, `completion_data`, `demo_reports/{id}__ld`, photos | Batch commit | Snackbar / `pop(true)` — **no Firestore change** |
| 8. Raise FP from job card | `demo_fp_submissions/fp-{jobId}` | Estimate runtime batch | `POST /api/work-orders` only |
| 9. Raise FP from follow-on | Same as above | Same path | Success dialog only — **no write** |
| 10. PPM lead (if UI exists) | `demo_customer_enquiries` + forward | Enquiry runtime | No screen |
| 11. PM gas visit complete | `demo_pm_projects` recount | Sign-off PM branch | `_cp12Completed` local bool |

**Headline for stakeholders:** The HTML reference app is the Firestore engineer client. The Flutter app is a REST + local-state UI replica. Until Firestore integration lands, cross-product demos that depend on Portal/Concierge/Dashboard seeing engineer actions will fail on Flutter.
