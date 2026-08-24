# Prompt: verify pillar flow — HTML reference vs Flutter engineer app

Copy everything below the line into an agent chat that can read **both** repos.
Do **not** edit code. Verify only.

| Repo | Role |
| --- | --- |
| `navigator-app-workflows` | **Reference implementation** — Firestore-bound HTML + JS runtimes |
| `chumley_navigator` (Flutter) | **Subject under test** — mobile engineer app |

Attach to the chat:

- `navigator-app-workflows/docs/DATA_FLOW.md`
- `navigator-app-workflows/contract/contract.ts`
- `navigator-app-workflows/docs/ENGINEER_APP_ALIGNMENT.md` (prior audit — re-verify, do not trust blindly)

---

You are performing a **read-only verification** of the Navigator engineer job
flow. Compare what the HTML reference app actually does in code and Firestore
against what the Flutter app does. Produce a gap report. **Do not implement
fixes.**

## What you are comparing

Both apps share the same Figma export (`Navigator-Modern-2026-full-app.html`)
as their visual design. They diverge on **data spine**:

```
REFERENCE (navigator-app-workflows)
  Figma HTML + app/*_runtime.js
  → Firebase Firestore demo_* collections directly from the browser
  → tools/serve.py for Groq, PPM forward (keys off device)
  → aspect-middleware-server for photo upload to Azure

FLUTTER (chumley_navigator)
  Flutter widgets reimplementing the same screens
  → REST https://navigator.chumley.ai for auth, profile, appointments, FP submit, VCR, absences
  → (expected after alignment) Firestore demo_* — verify whether this exists yet
```

The pillar contract: four products (Customer Portal, Navigator Dashboard,
Concierge, Engineer app) read/write **one Firestore** with **no translation
layer**. Field names and enums must match `contract/contract.ts` exactly.

Demo identity:

- Firestore project: `flowing-garage-481412-p2`
- Engineer email query: `navigatorengineer@aspect.co.uk`
- Demo customer: `001Vd00000xXYNZIA4`

---

## Ground rules

1. **Evidence only.** Every row in your report cites: file + function (both
   repos where applicable), or a Firestore document id you read.
2. **Reference wins on shape.** If HTML writes `{ status: "IN_TRANSIT" }` and
   Flutter writes `{ status: "In Transit" }`, that is a **gap**, even if REST
   accepts it.
3. **Silent failure counts.** UI that looks successful (snackbar, Success
   dialog, “Photo captured”, “Draft saved”) with no durable write is **BROKEN**
   or **DRAWN**, not “works locally”.
4. **Designed ≠ wired** in both repos. A screen in the export is not a flow
   until a runtime reads/writes the spine.
5. **Do not edit code.** No commits, no fixes. If you find stale live HTML,
   note it — do not rebuild unless asked.
6. **Re-verify** `ENGINEER_APP_ALIGNMENT.md`. Mark each prior finding
   **confirmed**, **fixed since**, or **wrong**.

---

## Phase 0 — Repo discovery

Before comparing flows, confirm both codebases are present and identify entry
points.

### Reference repo (`navigator-app-workflows`)

| Check | Where to look | Pass if |
| --- | --- | --- |
| Live page built | `app/Navigator-Modern-2026-live.html` exists | file present and includes Firebase SDK + runtimes |
| Runtimes listed | `tools/make_live_app.py` | know which `*_runtime.js` files are stitched |
| Contract | `contract/contract.ts` | COLLECTIONS + enums documented |
| Static audits | `python3 tools/audit_components.py` | run and paste summary (0 dead = pass) |
| Form routing test | `python3 tools/test_form_routing.py` | run and paste result |
| PM progress test | `python3 tools/test_pm_progress.py` | run and paste result |

Reference runtime map (verify each file exists and grep for Firestore writes):

| Runtime | Responsibility |
| --- | --- |
| `app/live_bind.js` | Home query, WO bind, `setStatus`, day strip |
| `app/state_runtime.js` | Current job id, resume by status, local form step |
| `app/form_runtime.js` | LD dropdowns + answers in localStorage by job id |
| `app/photo_runtime.js` | Capture UI |
| `app/upload_runtime.js` | Azure upload queue, `__PHOTO_URLS__` |
| `app/signoff_runtime.js` | Submit report batch write |
| `app/works_runtime.js` | FP line items + PM tasks on works form |
| `app/estimate_runtime.js` | FP raise to `demo_fp_submissions` |
| `app/enquiry_runtime.js` | PPM/PM/RA/Refer enquiries + PPM forward |
| `app/survey_runtime.js` | Dictation + AI scope via `/api/transcribe`, `/api/scope` |
| `tools/serve.py` | Proxy for Groq, PPM, health |

### Flutter repo (`chumley_navigator`)

| Check | Where to look | Pass if |
| --- | --- | --- |
| Firestore deps | `pubspec.yaml` | note `firebase_core` / `cloud_firestore` present or absent |
| Firestore usage | grep `FirebaseFirestore`, `demo_engineer_jobs`, `cloud_firestore` in `lib/` | list every hit or “zero hits” |
| REST spine | grep `navigator.chumley.ai`, `/api/engineer`, `/api/work-orders` | list services |
| Screen entry points | `JobDetailPage`, `OnSiteWizard`, `FixedPricePage`, `PpmJobDetailPage`, `PostSubmitFlow` | files exist |
| Prior audit | `docs/ENGINEER_APP_ALIGNMENT.md` if copied into Flutter repo | optional |

Stop and report if Flutter repo is missing — you can still document the
reference flow only, but the comparison will be incomplete.

---

## Phase 1 — Document the reference flow (HTML)

For each beat below, read the reference code and fill **Reference** columns.
Do not paraphrase from README alone.

### 1.1 Home and job list

| Question | Reference answer must cite |
| --- | --- |
| Query string | `live_bind.js` — `where("engineer_email", "==", …)` |
| Live subscription | `onSnapshot` on `demo_engineer_jobs` |
| PM project labels | `demo_pm_projects` subscription, `titleOf` / `subtitleOf` |
| Completed jobs | kept in list or filtered? (read `applyJobs`) |
| Refresh | `__REFRESH_JOBS__` / `jobQuery.get()` |

### 1.2 Status ladder

| Screen / trigger | Status written | Other fields | Timeline collection |
| --- | --- | --- | --- |
| WO In Transit | | | |
| Form step 1 | | | |
| WO Completed screen | | | |
| Submit report | | | |

Also verify in `live_bind.js` `setStatus`:

- Forward-only rank (`RANK` object)
- Other in-flight jobs → `DISPATCHED`
- `actual_start` on transit, `actual_end` on complete

### 1.3 Form routing (`kindOf`)

| Input job shape | Form opened | Cite `kindOf` / `WO_SCREENS` |
| --- | --- | --- |
| `job_type: REACTIVE`, trade Leak Detection | | |
| `job_type: FP`, `fp_submission_id` set | | |
| `job_type: PM`, `pm_project_id`, empty `work_type` | | |
| Gas / CP12 trade | | |

### 1.4 Local persistence

| Data | Storage | Key pattern | Cite |
| --- | --- | --- | --- |
| Form answers | | | `form_runtime.js` |
| Form step / resume | | | `state_runtime.js` |
| Photo upload queue | | | `upload_runtime.js` |
| Current job id | | | `state_runtime.js` / `__LIVE_JOB_ID__` |

### 1.5 Sign-off write

Read `signoff_runtime.js` `submit()` and list **every** document in the batch:

- Collection, deterministic doc id, required fields, enum values
- PM branch: `advanceProject` on `demo_pm_projects`

### 1.6 Raise flows

For each flow, list collections + fields + HTTP calls:

| Flow | Firestore docs | HTTP (if any) | Deterministic ids |
| --- | --- | --- | --- |
| FP estimate | | | `fp-{jobId}` |
| PPM lead | | `/api/ppm-forward` | |
| PM lead | | | |
| Reactive attendance | | | |
| Refer and earn | | | |

### 1.7 Server dependencies

| Feature | URL | Keys location |
| --- | --- | --- |
| Transcribe | `POST /api/transcribe` | `serve.py` |
| AI scope | `POST /api/scope` | `serve.py` |
| PPM forward | `POST /api/ppm-forward` | `serve.py` → PPM intake |
| Photo upload | `{middleware}/image-upload` | middleware `.env` |

---

## Phase 2 — Document the Flutter flow

Same beats as Phase 1. Fill **Flutter** columns from Dart code only.

For each beat ask:

| Question | Flutter answer must cite |
| --- | --- |
| What is read? | API endpoint or Firestore query |
| What is written? | HTTP body or Firestore patch — paste field names |
| Where is state? | `setState`, Cubit, Prefs, nothing |
| Survives app kill? | yes/no + how |
| Visible to Portal? | yes/no + why |

Pay special attention to:

- `JobDetailPage._statusIndex` vs Firestore `status`
- `OnSiteWizard` vs `signoff_runtime.js`
- `FixedPriceCubit.submitWorkOrder` vs `estimate_runtime.js`
- `_handleRaiseJob` vs `enquiry_runtime.js`
- `EnquiriesScreen` vs pillar enquiries (different shape?)
- `PpmJobDetailPage` vs PM visit + CP12 path in HTML

---

## Phase 3 — Side-by-side gap matrix

Produce one table. **Every row is one verifiable beat.**

| # | Flow beat | Reference (HTML) | Flutter | Match? | Gap severity | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Home data source | Firestore `engineer_email` | REST `GET /api/engineer/{id}` | | BLOCKER / HIGH / MED / LOW / N/A | |
| 2 | Status IN_TRANSIT write | | | | | |
| … | | | | | | |

**Match?** values:

- **YES** — same store, same fields, same enums (or Flutter intentionally adds Firestore where reference has it and shapes match)
- **PARTIAL** — UI exists; wrong store, missing fields, or local only
- **NO** — missing or contradicts reference
- **N/A** — out of pillar scope (VCR, absences) — note separately

**Gap severity:**

- **BLOCKER** — Portal / Concierge / Dashboard cannot see engineer work (no spine write)
- **HIGH** — writes happen but wrong shape (silent break)
- **MED** — local-only; demo misleading
- **LOW** — chrome / labels / non-spine features

---

## Phase 4 — Firestore verification (optional but strong)

If you can read Firestore (reference app running or REST API key from seeds):

**Before:** note job id `demo-job-rx-001` (or current reactive job) field values.

**Walk reference app only** (browser at `http://localhost:8080` after
`python3 tools/serve.py` + `python3 tools/make_live_app.py`):

1. Open reactive job → In Transit → form step 1 → fill one answer → submit report
2. After each step, read Firestore and record `status`, timeline count, report doc

**Walk Flutter app** (same engineer identity if possible):

1. Same steps on the same logical job (or closest appointment)
2. Read Firestore again

| Step | Reference changed Firestore? | Flutter changed Firestore? | Delta |
| --- | --- | --- | --- |
| In Transit | | | |
| On site | | | |
| Sign-off | | | |
| Raise FP | | | |
| Raise PPM | | | |

If Flutter has no Firestore client, Flutter column is always **no change** —
that itself is the headline finding.

---

## Phase 5 — False-success inventory

Grep both repos for user-visible success without spine write:

| Pattern | Reference | Flutter |
| --- | --- | --- |
| `Draft saved` | | |
| `Photo captured` / dummy | | |
| `Success` dialog | | |
| `Submit report` without batch | | |
| `pop(true)` as “saved” | | |

List every occurrence with file:line. These are demo traps.

---

## Phase 6 — Output document

Write **`docs/FLOW_VERIFICATION_REPORT.md`** (or paste in chat) with:

### A. Executive summary (5 bullets max)

- Is Flutter on the Firestore spine yet? (yes/no/partial)
- Count of beats: YES / PARTIAL / NO
- Top 3 BLOCKER gaps
- What reference app proves end-to-end today that Flutter cannot

### B. How the reference flow works (short narrative)

One paragraph per stage: Home → Visit → Sign-off → Raise flows → Who reads it
(Portal, Concierge, Dashboard, PPM).

### C. How the Flutter flow works (short narrative)

Same stages — honest about REST vs local vs missing.

### D. Full gap matrix (Phase 3 table)

### E. Prior audit reconciliation

For each claim in `ENGINEER_APP_ALIGNMENT.md`:

| Prior claim | Still true? | Evidence |

### F. Verification commands run

Paste output of audit scripts and any Firestore reads (redact secrets).

### G. Recommended fix order (verification only — no implementation)

Numbered list referencing gap row ids. Do not write code.

### H. Manual demo script (both apps)

Same click path for a human to reproduce gaps in 15 minutes:

1. Sign in / open app
2. Open reactive job
3. Transit → form → sign-off
4. Raise FP from job card **and** from follow-on (compare)
5. PPM lead (if UI exists)
6. PM / PPM visit if seeded

For each step: **Expected in Firestore** vs **Reference app** vs **Flutter app**.

---

## Reference cheat sheet (verify against code, do not assume)

Use this as a checklist only. Your report must cite the runtime files.

### Collections the reference app writes to

```
demo_engineer_jobs          status, actual_*, completion_data, photos[], fp_submission_id
demo_job_status_updates     timeline rows
demo_reports                __ld / __pm suffix ids
demo_job_photos             camelCase jobId, photoUrl
demo_fp_submissions         + demo_fp_line_items on FP raise
demo_customer_enquiries     PPM_INTEREST, PM_INTEREST, etc.; origin NAV_APP
demo_pm_projects            updated on PM sign-off recount
```

### Enums the reference app writes (never friendly labels)

```
job_type:     REACTIVE | FP | PM
status:       SCHEDULED | DISPATCHED | IN_TRANSIT | ON_SITE | COMPLETE | AWAITING_APPROVAL | APPROVED
enquiry:      status NEW; categories PPM_INTEREST, PM_INTEREST, …
FP:           status SUBMITTED
origin:       NAV_APP on engineer-raised leads
```

### Flutter patterns that usually indicate a gap (grep these)

```
_statusIndex
setState(() =>
_handleRaiseJob
Photo captured (dummy)
Draft saved
POST /api/work-orders
Fixed Price (Single)
Pending Confirmation
pop(true)
onTap: () {}
```

### Flutter patterns that indicate alignment (grep these)

```
FirebaseFirestore
demo_engineer_jobs
demo_fp_submissions
demo_customer_enquiries
PPM_INTEREST
engineer_email
IN_TRANSIT
completion_data
ppm_enquiry_id
```

If the second grep returns zero hits in `lib/`, state clearly: **Flutter is
not on the Firestore spine.**

---

## Stop conditions

| Condition | Action |
| --- | --- |
| Only one repo available | Document reference fully; mark Flutter columns “not verified” |
| Live HTML older than runtimes | Note “stale build”; suggest `make_live_app.py` for human, do not run unless asked |
| Firestore unreachable | Static code comparison only; label Phase 4 skipped |
| Flutter added Firestore since prior audit | Re-run Phase 2–4; update reconciliation section |

**Remember: verify and report. Do not edit application code.**
