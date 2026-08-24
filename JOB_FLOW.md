# End-to-End Job Flow Architecture & Technical Specification

This document details the complete end-to-end job lifecycle in the Navigator Engineer application, covering status transitions, dynamic work-order routing, form flow restructuring and answer persistence, photo capture and cloud uploads, and the atomic sign-off submission leading to the final completed screen.

---

## 1. Architectural Overview & The Shared Pillar Spine

The Navigator application acts as the mobile/tablet client for engineers on site. It communicates directly with a single shared **Google Cloud Firestore** database (`flowing-garage-481412-p2`), forming the spine that interconnects four core products without intermediary translation layers:

```
+------------------+     +----------------------+     +--------------------+     +-----------------------+
| Customer Portal  |     | Navigator Dashboard  |     | Concierge (Office) |     | Navigator App (Mobile)|
+--------+---------+     +----------+-----------+     +---------+----------+     +-----------+-----------+
         \                          |                           /                            /
          \                         |                          /                            /
           +------------------------v-------------------------+----------------------------+
                                    |
                        Firestore (default database)
                                    |
          +-------------------------+-------------------------+
          | - demo_engineer_jobs                              |
          | - demo_job_status_updates                         |
          | - demo_reports                                    |
          | - demo_job_photos (Portal camelCase)              |
          | - demo_pm_projects / demo_pm_tasks                |
          | - demo_fp_submissions / demo_fp_line_items        |
          | - demo_customer_enquiries                         |
          +---------------------------------------------------+
```

### Core Architecture Principles
1. **Pristine Design Foundation:** The UI is an untouched 107-screen Figma HTML export (`app/Navigator-Modern-2026-full-app.html`) with a hash-less `data-nav` router and `data-name` layer identifiers. `tools/make_live_app.py` bundles the Firebase SDK and modular runtime scripts (`live_bind.js`, `state_runtime.js`, `form_flow.js`, `form_runtime.js`, `conditions_runtime.js`, `works_runtime.js`, `photo_runtime.js`, `upload_runtime.js`, `signoff_runtime.js`) to generate `app/Navigator-Modern-2026-live.html`.
2. **Authority Partitioning:**
   - **Firestore** is the system of record for shared state: job assignment, contract status rungs, status update timeline, final visit reports, public photo URLs, and PM project stage counts.
   - **Client `localStorage`** is the system of record for local transient state: current active job ID (`__LIVE_JOB_ID__`), draft form responses (`navigator.form.answers`), furthest step progress (`navigator.job.progress`), and pending Azure upload queues (`navigator.photo.uploads`).
3. **Strict Contract Conformance:** Follows `contract/contract.ts`. Reads tolerantly (normalising legacy inputs) and writes strictly with uppercase enums (`SCHEDULED`, `DISPATCHED`, `IN_TRANSIT`, `ON_SITE`, `COMPLETE`).

---

## 2. Step 1: Job Discovery, Scheduling & Routing

### 2.1 Live Job Subscription
On initialization, `app/live_bind.js` listens to Firestore with an active query:
```javascript
db.collection("demo_engineer_jobs")
  .where("engineer_email", "==", "navigatorengineer@aspect.co.uk")
  .onSnapshot(function(snapshot) { ... });
```
When jobs update, the app recalculates the daily schedule and updates the Home screen (`s-1657-2551`) and Schedule screen (`s-1668-3053`).

### 2.2 Job Trade & Kind Classification (`kindOf(job)`)
Jobs are categorised into three primary flows:
* **`bath` (Fixed Price / Project Works):** If `job_type` is `"FP"` (accepted fixed-price estimate) or `"PM"` (Project Management stage visit), or trade matches bathroom/refurbishment.
* **`gas` (Gas PPM / Boiler):** Trade/work type contains `"gas"`, `"boiler"`, or `"heat"`.
* **`leak` (Leak Detection):** Trade/work type contains `"leak"`, `"detect"`, or defaults to leak detection.

### 2.3 Home Screen & Day Strip Engine
* **Day Strip:** Generates a 7-day Monday–Sunday strip matching the current week. Days with booked visits display an active dot indicator.
* **Filtering:** The Home screen shows uncompleted jobs scheduled for the selected day. Completed jobs are hidden from Home once signed off to reduce clutter, but remain accessible on the "View all" Schedule screen.
* **Active Job Pull-Forward:** If a job scheduled for another date is already `IN_TRANSIT` or `ON_SITE`, it is automatically pulled onto "Today's Schedule".

### 2.4 Dynamic Navigation & Resume Repointing
Before the user clicks a job row:
1. `app/state_runtime.js` evaluates `resumeScreen(job)`:
   - If `COMPLETE` $\rightarrow$ Routes directly to the completed Work Order terminal screen.
   - If `ON_SITE` $\rightarrow$ Routes directly to the **furthest step** reached in `navigator.job.progress[jobId]`.
   - If `IN_TRANSIT` $\rightarrow$ Routes to the In-Transit travel screen.
   - If `DISPATCHED` / `SCHEDULED` $\rightarrow$ Routes to the initial Dispatched Work Order screen.
2. `repointRows()` pre-populates `data-nav` attributes on the DOM rows, eliminating race conditions with the router.
3. Clicking a job captures `window.__LIVE_JOB_ID__ = row.getAttribute("data-live-job")` during the capture phase (`true`).

---

## 3. Step 2: The Forward-Only Status Ladder Lifecycle

The status ladder is strictly sequential and monotonic.

```
+---------------+      +----------------+      +--------------+      +-----------+      +------------+
| 0. SCHEDULED  | ---> | 1. DISPATCHED  | ---> | 2. IN_TRANSIT| ---> | 3. ON_SITE| ---> | 4. COMPLETE|
+---------------+      +----------------+      +--------------+      +-----------+      +------------+
```

### 3.1 Status Enums & Numeric Ranks
```javascript
var RANK = {
  SCHEDULED: 0,
  DISPATCHED: 1,
  IN_TRANSIT: 2,
  ON_SITE: 3,
  COMPLETE: 4,
  AWAITING_APPROVAL: 5,
  APPROVED: 6
};
```

### 3.2 Navigation-Driven Status Writes (`ON_ENTER`)
Arriving on a designated screen automatically triggers a Firestore write:
```javascript
var ON_ENTER = {
  "1991-3224": { status: "IN_TRANSIT" },  // Leak Detection - Travel screen
  "2205-3953": { status: "IN_TRANSIT" },  // Gas PPM - Travel screen
  "2317-4075": { status: "IN_TRANSIT" },  // PM Bathroom - Travel screen
  "2013-3427": { status: "ON_SITE" },     // LD Form Step 1 (Safety)
  "2196-3397": { status: "ON_SITE" },     // Gas CP12 Step 1
  "2317-4332": { status: "ON_SITE" },     // Works Form Step 1 (Risk Assessment)
  "2072-62797": { status: "COMPLETE" },   // WO - Completed (Leak)
  "2205-4099":  { status: "COMPLETE" },   // WO - Completed (Gas)
  "2317-4221":  { status: "COMPLETE" },   // WO - Completed (PM Bathroom)
};
```

### 3.3 Status Invariants & Single-Engineer Enforcement
When `setStatus(job, status)` runs in `app/live_bind.js`:
1. **Monotonic Forward Guard:** If `RANK[status] <= RANK[job.status]`, the write is rejected. Navigating backward does not demote the visit.
2. **Timestamping:**
   - Setting `IN_TRANSIT` records `actual_start: Timestamp.now()`.
   - Setting `COMPLETE` records `actual_end: Timestamp.now()`.
3. **Single-Engineer Single-Site Rule:** When an engineer enters `IN_TRANSIT` or `ON_SITE` on Job A, any other job assigned to that engineer currently marked `IN_TRANSIT` or `ON_SITE` is automatically demoted back to `DISPATCHED` with `actual_start: null`.
4. **Timeline Entry:** Every status change writes an immutable audit record to `demo_job_status_updates`:
   ```json
   {
     "job_id": "<job_id>",
     "status": "IN_TRANSIT | ON_SITE | COMPLETE",
     "engineer_email": "navigatorengineer@aspect.co.uk",
     "engineer_name": "Navigator Test Engineer",
     "created_at": "ServerTimestamp"
   }
   ```

---

## 4. Step 3: Work Order Presentation & Painting

When a Work Order screen is displayed, `paintWorkOrder()` dynamically binds live data into the Figma layers:

| Target Element | Binding Logic |
| :--- | :--- |
| **Status Chip** | Painted with status label (`In transit`, `On site`, `Complete`) and styled via CSS design tokens (`TONE.info`, `TONE.warning`, `TONE.success`). |
| **Job Type & Work Type Chips** | Displays normalized job type (`Reactive`, `Fixed price`, `PM project visit`) and trade/stage. |
| **Status Ladder Component** | Re-classes the 5-step progress bar: completed steps receive `.c1005` (with check icons), the active step receives `.c1006`, and pending steps receive `.c1008`. |
| **Appointment & Customer Details** | Populates Appointment ID, Customer Name, and Site Address beside their respective labels. |
| **Schedule & Window** | Calculates arrival window from `scheduled_start` and `scheduled_end` (e.g. `10:50 – 12:50 (2h window)`). |
| **Multi-Line Description** | For PM visits, generates enriched stage descriptions (e.g. `First Fix · visit 2 of 5 · Bathroom refurbishment` + architectural stage summary). Expands container bounds cleanly. |
| **Completion Banner** | The green banner (`"Job completed - all forms submitted"`) is hidden unless the job status is `COMPLETE`, `APPROVED`, or `AWAITING_APPROVAL`. |

---

## 5. Step 4: Form Architectures & Interactive Filling

### 5.1 Form Restructuring & Step Merging (`app/form_flow.js`)
In the original Figma export, Leak Detection comprised 12 disconnected steps with photo slots isolated on a terminal grid (Step 9). At runtime, `app/form_flow.js` restructures the DOM dynamically without altering source files:
* **Inline Photo Relocation:** Distributes photo slots directly adjacent to the questions they evidence:
  - *Front of property* $\rightarrow$ Step 2 (Context)
  - *Water meter reading* $\rightarrow$ Step 2 (beside water meter question)
  - *Affected area overview & close-up* $\rightarrow$ Step 3 (Inspection)
  - *Proposed access route* $\rightarrow$ Step 4 (Findings)
* **Collapse into 5 Logical Units:**
  1. **Step 1: Safety** (Host: `2013-3427`, absorbs Risk Assessment `2023-3704`)
  2. **Step 2: Context** (Host: `2013-3546`, absorbs Arrival & Meter Notes `2013-3670`)
  3. **Step 3: Inspection** (Host: `2013-3795`, absorbs Visual Inspection & Test Methods `2013-4048`)
  4. **Step 4: Findings** (Host: `2057-3792`, absorbs Leak Conclusion & Recommendations `2062-3848`)
  5. **Step 5: Sign off** (Host: `2070-3895`, absorbs Job Notes & Declaration `2013-4305`)
* **Stepper Updates:** Re-renders stepper dots to show a clear `Step X of 5` indicator.
* **Exit Repointing:** "Save draft" and "Cancel" buttons on all steps are repointed to Home (`s-1657-2551`).

### 5.2 Question Selection & Cascading Dependencies (`app/form_runtime.js`)
* **Picker Sheet:** Tapping a `Select/<question>` element opens an in-device modal sheet anchored to `#glass`.
* **Persistence:** Every selection immediately updates `localStorage.getItem("navigator.form.answers")` scoped to `__LIVE_JOB_ID__` and dispatches `form:answer`.
* **Cascading Logic (`dependsOn` & `optionsByValue`):**
  - If a child question (e.g. *Equipment Used*) depends on a parent question (e.g. *Test Method*), tapping the child before the parent triggers a prompt: *"Answer 'Test Method' first — it decides what can be offered here."*
  - Selecting a new parent value automatically filters child options or clears invalid downstream answers.

### 5.3 Conditional Field Visibility (`app/conditions_runtime.js`)
* Evaluates rules from `__LD_CONDITIONS__` (`hideWhen`: `empty`, `notEmpty`, `equals`, `in`, `notIn`).
* Rules cascade: Hiding a parent question automatically hides all downstream child questions.
* **Non-Destructive Hiding:** Hidden fields retain their values in `localStorage` so accidental toggles do not erase user input.

### 5.4 Works Form for Priced Work & Projects (`app/works_runtime.js`)
For Fixed Price (`FP`) and Project (`PM`) jobs, Screen `s-2317-4509` dynamically builds evidence items:
* **FP Jobs:** Loads approved line items from `demo_fp_line_items` where `submission_id == job.fp_submission_id`.
* **PM Jobs:** Loads stage tasks from `demo_pm_tasks` where `pm_project_id == job.pm_project_id` and `pm_stage == job.pm_stage`.
* Each item renders a `BEFORE` photo slot, an `AFTER` photo slot, and a content-editable description box for completed work notes.

### 5.5 Photo Capture & Upload Pipeline (`app/photo_runtime.js` & `app/upload_runtime.js`)
```
[ Camera / File Picker ]
          |
          v
[ HTML Canvas Downscaler ]  ---> (Max edge 900px, JPEG 0.65, ~55KB)
          |
          v
[ LocalStorage: navigator.form.photos ] ---> Immediate UI Preview & Offline Resilience
          |
          v
[ Upload Queue: aspect-middleware-server (:4000) /image-upload ]
          |
          v
[ Azure Blob Storage ] ---> Returns URL with SAS token
          |
          v
[ Strip SAS Token ]    ---> Clean URL stored in navigator.photo.uploads
```

---

## 6. Step 5: Sign-Off, Report Submission & Job Completion

When the engineer reviews the summary on Step 5 and taps **"Submit report"** (`[data-name="Submit report"]`), `app/signoff_runtime.js` executes the atomic sign-off transaction.

```
                                  [ Submit Report Tapped ]
                                             |
                                             v
                             +-------------------------------+
                             |  Compile Answers & Skips      |
                             |  Collect Clean Azure URLs     |
                             |  Build Completion Summary     |
                             +---------------+---------------+
                                             |
                                             v
                             +-------------------------------+
                             |    Atomic Firestore Batch     |
                             +---------------+---------------+
                                             |
        +--------------------+---------------+--------------------+--------------------+
        |                                    |                    |                    |
        v                                    v                    v                    v
+-----------------------+          +-------------------+ +-------------------+ +-------------------+
| demo_engineer_jobs    |          | demo_reports      | |demo_job_status_   | | demo_job_photos   |
| doc(jobId)            |          | doc(jobId__ld/pm) | |  updates          | | doc(jobId__slot)  |
|                       |          |                   | | doc(jobId__comp)  | |                   |
| - status: COMPLETE    |          | - report_type     | |                   | | - jobId           |
| - actual_end: now()   |          | - title / summary | | - status: COMPLETE| | - photoUrl        |
| - photos: [urls...]   |          | - outcome / scope | | - note / timestamp| | - caption         |
| - completion_data: {  |          | - pm_project_id   | +-------------------+ | - isReady: true   |
|     answers, skips,   |          | - created_at      |                       +-------------------+
|     counts, metadata  |          +-------------------+
|   }                   |
+-----------------------+
        |
        v (if PM Project Visit)
+-------------------------------------------------------+
| advanceProject(db, job)                               |
| 1. Query all visits for pm_project_id                 |
| 2. Count visits where status == "COMPLETE"            |
| 3. Calculate percent_complete (complete / sa_count)   |
| 4. Update demo_pm_projects status:                    |
|    - APPROVED -> IN_PROGRESS -> COMPLETE              |
+-------------------------------------------------------+
        |
        v
+-------------------------------------------------------+
| UI Completion State                                   |
| 1. Show Green Toast: "Report submitted"               |
| 2. Router transitions to WO Completed screen          |
| 3. Banner displays: "Job completed - all forms sub."  |
| 4. Status Ladder displays 5 green checkmarks          |
+-------------------------------------------------------+
```

### 6.1 Data Payload Preparation
1. **Answers & Skips Separation:** Splits `__FORM_ANSWERS__` into substantive answers and photo skip reasons (prefixed with `skip:`).
2. **Photo URL Verification:** Collects uploaded Azure URLs from `__PHOTO_URLS__()`.
3. **Completion Object Construction:**
   ```json
   {
     "form": "leak_detection | pm_stage",
     "pm_project_id": "<project_id_or_null>",
     "pm_stage": "<stage_name_or_null>",
     "answers": { ... },
     "photo_skips": { ... },
     "photo_urls": { "affected area overview": "https://..." },
     "answered_count": 14,
     "photo_count": 5,
     "completed_by": "Navigator Test Engineer",
     "completed_at": "2026-08-24T00:45:00.000Z"
   }
   ```

### 6.2 Atomic Firestore Batch Execution
To ensure idempotency during repeated submissions or demo rehearsals, deterministic document IDs are used:
1. **`demo_engineer_jobs/<id>` (Update):**
   - `status`: `"COMPLETE"`
   - `actual_end`: `FieldValue.serverTimestamp()`
   - `completion_data`: `<completion_object>`
   - `photos`: `["https://.../photo1.jpg", ...]`
   - `updated_at`: `FieldValue.serverTimestamp()`
2. **`demo_reports/<id>__ld` (or `<id>__pm`) (Set):**
   - Deterministic ID prevents duplicate report records.
   - Stores report title, generated summary, outcome classification, scope notes, engineer email, and timestamp.
3. **`demo_job_status_updates/<id>__complete` (Set):**
   - Logs the final `COMPLETE` status on the audit timeline.
4. **`demo_job_photos/<id>__<slot_slug>` (Set):**
   - Writes individual photo documents matching Customer Portal requirements in **camelCase**:
   ```json
   {
     "jobId": "<id>",
     "photoUrl": "https://...",
     "caption": "affected area overview",
     "uploadedAt": "ServerTimestamp",
     "isReady": true
   }
   ```

### 6.3 PM Project Stage Recount (`advanceProject`)
If the completed job is a PM project visit (`job_type === "PM"`):
1. Reads all sibling jobs in `demo_engineer_jobs` with `pm_project_id == job.pm_project_id`.
2. Computes `complete = visits.filter(v => v.status === "COMPLETE").length`.
3. Determines total stages from `demo_pm_projects.sa_count`.
4. Calculates `percent_complete = Math.round((complete / total) * 100)`.
5. Updates `demo_pm_projects/<projectId>`:
   - `stages_complete`: `complete`
   - `percent_complete`: `percent`
   - `status`: `complete >= total ? "COMPLETE" : complete > 0 ? "IN_PROGRESS" : "APPROVED"`

---

## 7. Step 6: Terminal Screen & Post-Job Capabilities

### 7.1 The Completed Work Order Screen
Upon successful batch commit:
1. A confirmation toast displays: `"Report submitted"` (and `"Project X% complete"` for PM jobs).
2. The router navigates to the terminal Work Order screen:
   - Leak Detection: `s-2072-62797`
   - Gas PPM: `s-2205-4099`
   - PM Bathroom: `s-2317-4221`
3. `paintWorkOrder()` updates the terminal screen UI:
   - **Header Chip:** Displays green `Complete` badge (`TONE.success`).
   - **Completion Banner:** The green alert card `"Job completed - all forms submitted"` becomes visible.
   - **Status Ladder:** All five dots (`Scheduled`, `Dispatched`, `In transit`, `On site`, `Complete`) display solid green circles with checkmark icons.

### 7.2 Post-Job Raise Actions
From the completed Work Order screen, engineers can raise follow-on workflows directly linked to the current `job_id`:

```
                           Completed Work Order Screen
                                       |
       +-------------------------------+-------------------------------+
       |                               |                               |
       v                               v                               v
[ Raise Fixed-Price Estimate ]   [ Raise PPM Lead ]             [ Raise PM / RA / Refer ]
       |                               |                               |
       v                               v                               v
- demo_fp_submissions           - demo_customer_enquiries       - demo_customer_enquiries
- demo_fp_line_items              (category: PPM_INTEREST)        (PM_INTEREST / REFERRAL)
- job.fp_submission_id          - POST /api/public/office-      - Concierge office board
  (Visible to Customer Portal     enquiries (PPM Postgres)
   for online quote acceptance)
```

---

## 8. Summary Checklist of Flow Handlers

| Phase | Handled By | Storage / Network Target | Primary Function |
| :--- | :--- | :--- | :--- |
| **Discovery & List** | `live_bind.js` | Firestore `demo_engineer_jobs` | Live subscription by engineer email; schedule grouping. |
| **Progress & Resume**| `state_runtime.js` | `localStorage["navigator.job.progress"]` | Tracks furthest form step; routes directly to resume screen. |
| **Status Ladder** | `live_bind.js` | Firestore `demo_engineer_jobs` & `demo_job_status_updates` | Monotonic forward transitions; single-engineer enforcement. |
| **Form Layout** | `form_flow.js` | In-memory DOM restructuring | Merges 12 steps into 5 units; places photo slots inline. |
| **Form Data** | `form_runtime.js` | `localStorage["navigator.form.answers"]` | Manages sheet pickers, cascades, and answer persistence. |
| **Conditions** | `conditions_runtime.js` | In-memory DOM filtering | Evaluates `hideWhen` rules without deleting answers. |
| **Works Items** | `works_runtime.js` | Firestore `demo_fp_line_items` & `demo_pm_tasks` | Binds line items and stage tasks to before/after slots. |
| **Photo Capture** | `photo_runtime.js` | `localStorage["navigator.form.photos"]` | Downscales camera input to 900px JPEG; persists locally. |
| **Photo Upload** | `upload_runtime.js` | Azure Blob via middleware (`:4000`) | Uploads image queue, strips SAS tokens, stores public URLs. |
| **Sign-Off Commit** | `signoff_runtime.js`| Firestore Atomic Batch Commit | Sets `COMPLETE`, writes `demo_reports`, `demo_job_photos`, timeline, and recounts PM project stages. |
| **Completion UI** | `live_bind.js` | Terminal Work Order DOM screens | Paints green completion banner, 5-tick ladder, and post-job actions. |
