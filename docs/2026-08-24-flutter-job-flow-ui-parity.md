# Flutter job flow + UI parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Where to implement:** `chumley_navigator` (Flutter). This file lives in `navigator-app-workflows` because that repo is the **source of truth** for screens, routing, and Firestore field names. Open the Flutter repo and attach the **Reference pack** below.

**Goal:** Make the Flutter engineer app’s **job visit** (Home → work order → kind-specific on-site form → sign-off → completed / follow-on) behave and look the same as the HTML live app: same screens, same CTAs, same step counts, same `kindOf` routing, same status writes.

**Architecture:** Keep Flutter **native widgets** (no WebView of the Figma export). Treat `Navigator-Modern-2026-full-app.html` + live runtimes as the design and behaviour spec. Port `kindOf`, `JOURNEY`, `ON_ENTER`, `form_flow.js`’s **5 LD steps**, 12 CP12 screens, and 5 bathroom works screens one-for-one. Persist drafts locally by job id; persist status/sign-off in Firestore using `contract/contract.ts`. Do not invent a fourth form kind.

**Tech Stack:** Flutter, existing `chumley_navigator` routing/widgets, `firebase_core` / `cloud_firestore` (spine), SharedPreferences for drafts, `image_picker` + middleware for photos. Visual source: Figma HTML export + CSS tokens.

**Related plan (data only):** `docs/superpowers/plans/2026-08-12-flutter-firestore-spine.md` — field names, batches, Home query. **This plan owns navigation, screen structure, and UI.** Do both; UI without spine still lies to the office; spine without UI still fails the “exactly the same” bar.

## Global Constraints

- Source of truth for **behaviour** is the **live** HTML app (`form_flow.js` merge, `state_runtime.js` resume), not the raw 12-step Figma LD grid.
- Source of truth for **layout/copy/controls** is `data-title` + `data-name` on `app/Navigator-Modern-2026-full-app.html`.
- Three job kinds only: `leak` | `gas` | `bath`. `job_type` `FP` or `PM` → `bath` before any trade word.
- Status: arriving on In Transit **is** `IN_TRANSIT`; arriving on form step 1 **is** `ON_SITE`; Submit report **is** `COMPLETE`. No separate “On-site” WO that skips the form.
- Forward-only status. One in-flight job (`IN_TRANSIT` / `ON_SITE`); siblings → `DISPATCHED`.
- Write enums only: `REACTIVE` | `FP` | `PM`; `SCHEDULED` | `DISPATCHED` | `IN_TRANSIT` | `ON_SITE` | `COMPLETE` | `AWAITING_APPROVAL` | `APPROVED`.
- Read `job_type` tolerantly (`Fixed Price` → `FP`). Never write `'Fixed Price (Single)'`.
- Drafts: SharedPreferences keyed by job id. Never show “Draft saved” / “Captured” / “Job completed” unless the write happened.
- Do not port VCR, absences, points, withdraw, or Support Enquiries as substitutes for job raises.
- Do not edit the HTML export. Do not run `make_live_app.py` inside Flutter.
- Flutter file names in audits: `JobDetailPage`, `LdFormPage` (4 tabs today), `Cp12FormPage` (6 tabs), `PpmJobDetailPage`. There is **no** `OnSiteWizard` / `PostSubmitFlow` — ignore `docs/ENGINEER_APP_ALIGNMENT.md` class names.

---

## Reference pack (attach these to the Flutter chat)

Copy this list into the agent session that implements in `chumley_navigator`. Paths are relative to **this** repo (`navigator-app-workflows`).

### Must attach (job flow + UI)

| File | Why |
| --- | --- |
| `docs/superpowers/plans/2026-08-24-flutter-job-flow-ui-parity.md` | This plan |
| `docs/superpowers/plans/2026-08-12-flutter-firestore-spine.md` | Firestore writes, collections, sign-off batch |
| `JOB_FLOW.md` | End-to-end visit: status, kind, forms, photos, sign-off |
| `docs/DATA_FLOW.md` | Shared pillar, `kindOf` order, status ladder |
| `contract/contract.ts` | Exact field names and enums |
| `app/live_bind.js` | `kindOf`, `jobTypeOf`, `ON_ENTER`, Home query, `setStatus` |
| `app/state_runtime.js` | `JOURNEY` screen ids, `resumeScreen` |
| `app/form_flow.js` | LD 12→5 merge + photo slot hosts |
| `app/form_runtime.js` | Pickers, persist answers, cascades |
| `app/conditions_runtime.js` | `hideWhen` rules |
| `app/works_runtime.js` | FP line items / PM tasks on works form |
| `app/photo_runtime.js` | Capture, local store, slot keys |
| `app/upload_runtime.js` | Middleware upload, SAS strip |
| `app/signoff_runtime.js` | Submit report batch |
| `reference_screens.json` | All 107 `s-XXXX-YYYY` + `data-title` |
| `app/Navigator-Modern-2026-full-app.html` | Visual + `data-name` layers (large; attach or keep repo open) |

### Attach for form content (questions, not layout)

| File | Why |
| --- | --- |
| `contract/forms.json` | Option groups / keys used by the live form |
| `contract/options.json` | Picker options |
| `contract/conditions.json` | Visibility rules (question titles) |
| `contract/ld_form.json` | Canonical LD question keys |

### Attach for “what Flutter is missing today”

| File | Why |
| --- | --- |
| `docs/Comparison report html vs flutter.md` | Combined UI + data gaps |
| `SCREEN_ALIGNMENT_REPORT.md` | Screen-by-screen Flutter widget map |
| `FLOW_VERIFICATION_REPORT.md` | Data beats Flutter does not write |
| `docs/SCREEN_ALIGNMENT_VERIFICATION_PROMPT.md` | How to re-audit screens after work |

### Do not treat as current Flutter class map

| File | Why |
| --- | --- |
| `docs/ENGINEER_APP_ALIGNMENT.md` | Stale (`OnSiteWizard`, `PostSubmitFlow`) |

### Optional (raises after the visit, not required for On-site)

| File | Why |
| --- | --- |
| `app/estimate_runtime.js` | FP raise → `demo_fp_submissions` |
| `app/enquiry_runtime.js` | PPM / PM / RA / Refer wizards |

### Flutter repo (subject) — keep open, do not copy into this repo

Open `chumley_navigator` and keep at least:

- `lib/` (especially `job_detail_page.dart`, `ld_form_page.dart`, `cp12_form_page.dart`, `ppm_job_detail_page.dart`, dashboard / home, `FixedPricePage`, `lib/utils/routes.dart`)
- `pubspec.yaml`
- `test/`

### How to view the reference UI while implementing

```bash
cd navigator-app-workflows
python3 tools/make_live_app.py
python3 tools/serve.py
# open the live HTML; walk leak, gas, and FP/PM jobs
```

Screenshot the **live** screens (after `form_flow.js` merge), not the raw 12-step LD grid.

---

## File map (Flutter)

| Create / change | Responsibility |
| --- | --- |
| `lib/pillar/form_kind.dart` | Port of `kindOf` / `jobTypeOf` |
| `lib/pillar/job_journey.dart` | Port of `JOURNEY` + resume |
| `lib/pillar/ld_flow.dart` | Port of `form_flow.js` PLAN + PHOTO_HOST |
| `lib/theme/navigator_tokens.dart` | Colours / type from HTML CSS variables |
| `lib/screens/job/work_order_page.dart` | One WO chrome, three visual states (Dispatched / Transit / Complete) per kind |
| `lib/screens/job/ld_visit_wizard.dart` | Replace `LdFormPage` 4 tabs with 5 sequential steps |
| `lib/screens/job/cp12_visit_wizard.dart` | Replace 6 tabs with 12 sequential steps matching `JOURNEY.gas.form` |
| `lib/screens/job/works_visit_wizard.dart` | New bathroom / FP / PM works 5 steps |
| `lib/screens/job/follow_on_page.dart` | Dedicated follow-on / visit-complete (not only a raise card) |
| Modify: `JobDetailPage` | Stop always opening LD; delegate to journey |
| Modify: `PpmJobDetailPage` | Same WO ladder as gas, not a side door into tabs |
| Modify: Home / dashboard | Job rows + resume like `repointRows` |
| Spine files from 2026-08-12 plan | `lib/pillar/*` repository, status, sign-off |

Do **not** split `JobDetailPage` into 107 widgets. One WO shell + three wizards is enough if each **state** matches the Figma frame (header, chips, ladder, primary slider/CTA, footer).

---

## What “UI exactly the same” means (acceptance)

For each HIGH-priority job screen in `SCREEN_ALIGNMENT_REPORT.md` section D:

| Layer | Pass |
| --- | --- |
| **A Exists** | Flutter route/widget for that `data-title` (or the **live merged** host for LD) |
| **B Reachable** | Home → job → screen without debug flags |
| **C Structure** | Same primary fields, same CTA copy (`Slide to start journey`, `Slide to arrive on site`, `Submit report`, `Save draft`), same stepper (`Step X of 5` for LD; 12 for CP12; 5 for works) |
| **D Interactive** | Control does the live-app thing, not a snackbar lie |

LD: implement **5 live steps**, not 11 export screens and not 4 tabs.

Pixel check: iPhone-width screenshot of live HTML vs Flutter for (1) leak Dispatched WO, (2) leak form step 1 Safety, (3) leak Completed WO. Tokens: `--brand-navy`, `--surface-muted`, status chip colours from `live_bind.js` `TONE`.

Out of scope for this plan: rewards, KPI, withdraw, empty notifications, support Enquiries tab.

---

### Task 1: Port `kindOf` (no UI)

**Files:**
- Create: `chumley_navigator/lib/pillar/form_kind.dart`
- Test: `chumley_navigator/test/pillar/form_kind_test.dart`
- Consumes: `app/live_bind.js` `jobTypeOf` + `kindOf` (copy logic, do not “improve”)
- Produces: `JobTypeCoerce.coerce(String?)`, `FormKind kindOf(DemoJobLike job)` where `FormKind` is `leak` | `gas` | `bath`

```dart
enum FormKind { leak, gas, bath }

class JobTypeCoerce {
  static String coerce(String? raw) {
    final t = (raw ?? '').trim().toUpperCase();
    if (t == 'FIXED PRICE' || t == 'FIXEDPRICE') return 'FP';
    if (t == 'PM PROJECT' || t == 'PROJECT') return 'PM';
    return t;
  }
}

class FormKindResolver {
  static FormKind kindOf({
    required String? jobType,
    required String? trade,
    required String? workType,
    required String? description,
  }) {
    final tradeBlob = '${trade ?? ''} ${workType ?? ''}'.toLowerCase();
    final desc = (description ?? '').toLowerCase();
    final jt = JobTypeCoerce.coerce(jobType);
    if (jt == 'FP' || jt == 'PM') return FormKind.bath;
    if (RegExp(r'leak|detect').hasMatch(tradeBlob)) return FormKind.leak;
    if (RegExp(r'gas|boiler|heat').hasMatch(tradeBlob)) return FormKind.gas;
    if (RegExp(r'bathroom|refurb|fitting|fixed price|project').hasMatch(tradeBlob)) {
      return FormKind.bath;
    }
    if (RegExp(r'gas safety|boiler|cp12').hasMatch(desc)) return FormKind.gas;
    if (RegExp(r'refurbishment|strip out|first fix|second fix|snagging').hasMatch(desc)) {
      return FormKind.bath;
    }
    return FormKind.leak;
  }
}
```

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';

void main() {
  test('FP and PM beat trade words including leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'PM',
        trade: 'Plumbing',
        workType: '',
        description: 'Strip out - bathroom refurbishment',
      ),
      FormKind.bath,
    );
    expect(
      FormKindResolver.kindOf(
        jobType: 'Fixed Price',
        trade: 'Fixed Price',
        workType: '',
        description: '',
      ),
      FormKind.bath,
    );
  });

  test('leak job mentioning bathroom stays leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'REACTIVE',
        trade: 'Leak Detection',
        workType: '',
        description: 'suspected water leak in the bathroom',
      ),
      FormKind.leak,
    );
  });

  test('empty plumbing reactive defaults to leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'REACTIVE',
        trade: 'Plumbing',
        workType: '',
        description: '',
      ),
      FormKind.leak,
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/pillar/form_kind_test.dart`

Expected: FAIL (library not found)

- [ ] **Step 3: Implement `form_kind.dart` as above**

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/pillar/form_kind_test.dart`

Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/pillar/form_kind.dart test/pillar/form_kind_test.dart
git commit -m "$(cat <<'EOF'
feat: port HTML kindOf so FP/PM jobs do not open leak detection

EOF
)"
```

---

### Task 2: Port journey + resume (no UI)

**Files:**
- Create: `chumley_navigator/lib/pillar/job_journey.dart`
- Test: `chumley_navigator/test/pillar/job_journey_test.dart`
- Consumes: `app/state_runtime.js` `JOURNEY`, `resumeScreen`
- Produces: `JobJourney.forKind(FormKind)`, `resumeTarget({status, kind, furthestStep})`

Copy screen ids **exactly** (no `s-` prefix in JS; Flutter may store with `s-`):

```dart
class JobJourney {
  final String dispatched;
  final String transit;
  final List<String> form;
  final String complete;

  const JobJourney({
    required this.dispatched,
    required this.transit,
    required this.form,
    required this.complete,
  });

  static const leak = JobJourney(
    dispatched: '1991-3106',
    transit: '1991-3224',
    form: ['2013-3427', '2013-3546', '2013-3795', '2057-3792', '2070-3895'],
    complete: '2072-62797',
  );

  static const gas = JobJourney(
    dispatched: '2205-3809',
    transit: '2205-3953',
    form: [
      '2196-3397', '2196-3574', '2196-3704', '2196-3876', '2196-4001',
      '2196-4116', '2196-4332', '2196-4523', '2196-4636', '2196-4854',
      '2196-5003', '2196-5152',
    ],
    complete: '2205-4099',
  );

  static const bath = JobJourney(
    dispatched: '2317-3931',
    transit: '2317-4075',
    form: ['2317-4332', '2317-4509', '2317-4779', '2317-4914', '2317-5049'],
    complete: '2317-4221',
  );

  static JobJourney forKind(FormKind k) {
    switch (k) {
      case FormKind.gas:
        return gas;
      case FormKind.bath:
        return bath;
      case FormKind.leak:
        return leak;
    }
  }
}

enum ResumePhase { dispatched, transit, form, complete }

ResumePhase resumePhase(String status) {
  final st = status.toUpperCase();
  if (st == 'COMPLETE' || st == 'AWAITING_APPROVAL' || st == 'APPROVED') {
    return ResumePhase.complete;
  }
  if (st == 'ON_SITE') return ResumePhase.form;
  if (st == 'IN_TRANSIT') return ResumePhase.transit;
  return ResumePhase.dispatched;
}

int clampFormStep(int furthest, int formLength) {
  if (formLength <= 0) return 0;
  if (furthest < 0) return 0;
  if (furthest > formLength - 1) return formLength - 1;
  return furthest;
}
```

- [ ] **Step 1: Write the failing test**

```dart
test('ON_SITE resumes at furthest form step not step 0', () {
  expect(resumePhase('ON_SITE'), ResumePhase.form);
  expect(clampFormStep(3, JobJourney.leak.form.length), 3);
  expect(JobJourney.leak.form.length, 5);
  expect(JobJourney.gas.form.length, 12);
  expect(JobJourney.bath.form.length, 5);
});

test('COMPLETE does not resume at dispatched', () {
  expect(resumePhase('COMPLETE'), ResumePhase.complete);
});
```

- [ ] **Step 2: Run** `flutter test test/pillar/job_journey_test.dart` — expect FAIL
- [ ] **Step 3: Implement `job_journey.dart`**
- [ ] **Step 4: Run tests — expect PASS**
- [ ] **Step 5: Commit** `feat: port HTML job journey screen ids and resume phases`

---

### Task 3: Tokens + WO shell (UI)

**Files:**
- Create: `chumley_navigator/lib/theme/navigator_tokens.dart`
- Create or refactor: `lib/screens/job/work_order_page.dart`
- Modify: `job_detail_page.dart` to use `WorkOrderPage` instead of a single mixed layout that always implies leak
- Test: `test/screens/work_order_page_test.dart` (widget test: finds CTA labels)

**Interfaces:**
- Consumes: `FormKind`, `ResumePhase`, job fields (`job_number`, `customer_name`, `site_address`, `trade` / PM stage label)
- Produces: `WorkOrderPage({required DemoJob job, required FormKind kind, required ResumePhase phase})`

Copy from leak/gas/bath WO frames (`s-1991-3106`, `s-2205-3809`, `s-2317-3931` and their transit/complete siblings):

Must show:

- Status chip: `Dispatched` | `In transit` | `On site` | `Complete` (On site only after form step 1 has been entered; if `status == ON_SITE` but user opened WO via back, chip still On site and primary CTA is “continue form” not “arrive again”)
- Job type chip: `Reactive` | `Fixed price` | `PM project visit` from coerced `job_type`
- Work type / stage chip from trade or PM stage
- 5-rung status ladder matching `live_bind.js` paint (completed / active / pending)
- Appointment id, customer, site, window from `scheduled_start` / `scheduled_end`
- Primary control:
  - Dispatched: **Slide to start journey** → navigate to transit + write `IN_TRANSIT`
  - Transit: **Slide to arrive on site** → push form step 0 + write `ON_SITE` on form appear
  - Complete: hide transit slider; show green banner **Job completed - all forms submitted** only if status is `COMPLETE` / `APPROVED` / `AWAITING_APPROVAL`

Gas and bath use the **same chrome**, different `FormKind` so titles/icons match HTML (`icon/thermometer` vs `hard-hat` vs `droplet` — use existing icon set closest to those).

Do not keep a leak-only `JobDetailPage` as the only WO. `PpmJobDetailPage` must not skip transit.

- [ ] **Step 1: Widget test** — `WorkOrderPage` in dispatched phase finds `Slide to start journey`; transit finds `Slide to arrive on site`; complete finds `Job completed`
- [ ] **Step 2: Run widget test — expect FAIL**
- [ ] **Step 3: Implement shell + tokens; screenshot against live HTML**
- [ ] **Step 4: Tests PASS; visual check on simulator**
- [ ] **Step 5: Commit** `feat: work order chrome matches HTML dispatched/transit/complete`

Spine: if Firestore is not wired yet, still **call** `PillarJobsRepository.setStatus` (stub that throws or no-ops is forbidden — either write Firestore or show an error, never a fake success). Prefer completing spine Task 2 from the 2026-08-12 plan in the same PR if possible.

---

### Task 4: On-site = form step 1 (flow)

**Files:**
- Modify: `WorkOrderPage` transit CTA
- Modify: Home job row `onTap` to use `resumePhase` + `clampFormStep` from SharedPreferences `navigator.job.progress.<jobId>`
- Test: `test/pillar/on_site_entry_test.dart`

**Rule (copy `ON_ENTER`):**

| Event | Status write |
| --- | --- |
| Push transit screen | `IN_TRANSIT` + `actual_start` + timeline |
| First frame of form index 0 | `ON_SITE` + timeline |
| Submit report | `COMPLETE` (sign-off task) |

Do **not** write `ON_SITE` on the transit slider before the form route is shown. The HTML writes when the form screen id is entered.

Resume: `status == ON_SITE` → open wizard at saved step, **not** Dispatched WO.

- [ ] **Step 1: Unit test** — given `ON_SITE` and `furthestStep: 2`, `openJob` returns `ResumePhase.form` and step 2
- [ ] **Step 2: FAIL then implement Home + WO navigation**
- [ ] **Step 3: Manual** — kill app on form step 2; reopen job; land on step 2
- [ ] **Step 4: Commit** `feat: arriving on site opens the form and resumes at furthest step`

---

### Task 5: Leak wizard — 5 steps matching live merge

**Files:**
- Create: `lib/pillar/ld_flow.dart` (PLAN names only)
- Create: `lib/screens/job/ld_visit_wizard.dart`
- Delete or stop routing to: `LdFormPage` 4-tab UI
- Test: `test/pillar/ld_flow_test.dart`

**Live merge (`form_flow.js`) — implement this, not the export 12:**

| Step | Title | Host id | Absorbs | Photos on this step |
| --- | --- | --- | --- | --- |
| 1 of 5 | Safety | `2013-3427` | `2023-3704` (work at height) | none extra |
| 2 of 5 | Context | `2013-3546` | `2013-3670` | Front of property; water meter reading |
| 3 of 5 | Inspection | `2013-3795` | `2013-4048` | Affected area overview + close-up |
| 4 of 5 | Findings | `2057-3792` | `2062-3848` | Proposed access route |
| 5 of 5 | Sign off | `2070-3895` | `2013-4305` | none (declaration + Submit report) |

Do **not** add a sixth “photos grid” step (`2013-3921`). Those slots move inline as above. Duplicate slots listed in `PHOTO_DUPLICATE` stay omitted.

UI:

- Header: `Step X of 5` + host title (Safety / Context / …)
- Footer: **Save draft** → pop to Home (answers already in Prefs); **Continue** / **Submit report** on last step
- Questions: rebuild from `contract/forms.json` + `ld_form.json` grouped into the five hosts. Use HTML `data-name` labels from the absorbed screens so copy matches.
- Cascades: port `form_runtime.js` dependsOn (e.g. Test Method → Equipment). If child tapped first: snackbar *Answer 'Test Method' first — it decides what can be offered here.*
- Conditions: `conditions_runtime.js` / `contract/conditions.json` — hide, do not delete stored answers

- [ ] **Step 1: Test** `LdFlow.hosts.length == 5` and photo host map keys match `PHOTO_HOST`
- [ ] **Step 2: FAIL; implement `ld_flow.dart`**
- [ ] **Step 3: Build `LdVisitWizard` sequential `PageView` or `Navigator` pages (not TabBar of 4)**
- [ ] **Step 4: Persist `navigator.form.answers.<jobId>` on every change; Save draft never claims success without a write**
- [ ] **Step 5: Side-by-side with live LD form; commit** `feat: leak visit wizard matches live 5-step merge`

---

### Task 6: Gas wizard — 12 CP12 screens

**Files:**
- Create: `lib/screens/job/cp12_visit_wizard.dart`
- Modify: `PpmJobDetailPage` / gas WO to push this wizard, not `Cp12FormPage` 6 tabs
- Visual: `s-2196-3397` … `s-2196-5152` in the HTML export

**Structure:** 12 sequential steps, ids from `JobJourney.gas.form`. Stepper `Step X of 12`. Photo step `2196-4854` uses real `ImagePicker`, not a string toggle.

Do not collapse combustion / findings / notes to make the form “shorter”.

- [ ] **Step 1: Widget test** — 12 page titles exist; last page has Submit report
- [ ] **Step 2: Implement sequential wizard; remove 6-tab as the gas path**
- [ ] **Step 3: Screenshot CP12 1 vs live**
- [ ] **Step 4: Commit** `feat: CP12 visit is 12 steps matching HTML gas journey`

---

### Task 7: Works wizard — FP/PM bathroom (new)

**Files:**
- Create: `lib/screens/job/works_visit_wizard.dart`
- Port: `app/works_runtime.js`
- Visual: `s-2317-4332`, `2317-4509`, `2317-4779`, `2317-4914`, `2317-5049`

**Steps:**

1. Risk assessment (`2317-4332`) — entering writes `ON_SITE` (same as other kinds)
2. Before / after evidence (`2317-4509`) — list from Firestore:
   - FP: `demo_fp_line_items` where `submission_id == job.fp_submission_id`
   - PM: `demo_pm_tasks` where `pm_project_id` and `pm_stage` match
   - Each row: BEFORE slot, AFTER slot, notes
3. Parts used (`2317-4779`)
4. Job notes (`2317-4914`)
5. Review (`2317-5049`) → Submit report

PM Home row title: project title + stage + `visit {pm_stage_order} of {sa_count}` — `work_type` is often empty; do not label the job “Plumbing leak”.

- [ ] **Step 1: Unit test** — `FormKind.bath` jobs open `WorksVisitWizard`, never `LdVisitWizard`
- [ ] **Step 2: Build 5-step UI from HTML frames**
- [ ] **Step 3: Load line items / tasks (empty state if none — do not show designer placeholder bathrooms)**
- [ ] **Step 4: Commit** `feat: FP/PM jobs open bathroom works form like HTML`

---

### Task 8: Drafts, photos, sign-off

**Files:**
- Create: `lib/pillar/form_draft_store.dart` (Prefs JSON by job id)
- Create: `lib/pillar/photo_uploader.dart` (port SAS strip + POST `{uploadBase}/image-upload`)
- Modify: wizards’ last step → `signoff_runtime.js` batch (see 2026-08-12 Task 4)
- Test: `test/pillar/strip_sas_test.dart`

```dart
String stripSas(String url) {
  final u = Uri.parse(url);
  return u.replace(query: '').toString().replaceFirst(RegExp(r'\?$'), '');
}
```

Sign-off must write (deterministic ids):

- `demo_engineer_jobs/{id}`: `COMPLETE`, `actual_end`, `completion_data`, `photos[]`
- `demo_reports/{id}__ld` or `{id}__pm`
- `demo_job_status_updates/{id}__complete`
- `demo_job_photos/{id}__{slotSlug}` camelCase: `jobId`, `photoUrl`, `caption`, `uploadedAt`, `isReady`
- PM: recount `demo_pm_projects`

Then navigate to **kind complete WO** (`2072-62797` / `2205-4099` / `2317-4221`), not a snackbar on the form.

- [ ] **Step 1: SAS unit test**
- [ ] **Step 2: Draft store round-trip test**
- [ ] **Step 3: Wire Submit report; second submit overwrites same ids**
- [ ] **Step 4: Commit** `feat: job sign-off matches HTML batch and completed WO`

---

### Task 9: Follow-on screens (after complete)

**Files:**
- Create: `lib/screens/job/follow_on_page.dart`
- Visual: `s-2104-3322` Raise follow-on, `s-2280-3863` Visit complete, `s-2272-3831` Job closed
- Modify: completed WO CTAs to **push these screens**, not only an inline raise card with `_handleRaiseJob` dialogs

Until estimate/enquiry spine is done: **hide** raise rows rather than Success dialogs. Job-card `FixedPricePage` may stay, but follow-on **must not** claim a raise that did not write.

- [ ] **Step 1: Grep `_handleRaiseJob` / `Success` on job detail — remove liars**
- [ ] **Step 2: Dedicated follow-on + visit-complete layouts from HTML**
- [ ] **Step 3: Commit** `feat: post-complete follow-on screens match HTML`

Raises (FP / PPM / PM / RA / Refer) are **Task 6–7 of the 2026-08-12 spine plan**. Do not invent a second FP payload.

---

### Task 10: Home rows match live list behaviour

**Files:**
- Modify: dashboard / today’s schedule
- Consumes: Firestore `engineer_email` query (spine)

Behaviour from `JOB_FLOW.md` / `live_bind.js`:

- Day strip Mon–Sun; dots on days with visits
- Hide `COMPLETE` from Home; still on Schedule / View all
- Pull `IN_TRANSIT` / `ON_SITE` jobs onto today even if scheduled another day
- Row `data-nav` equivalent: tap uses `resumePhase`, not always Dispatched
- Icon from `FormKind`

- [ ] **Step 1: Unit test pull-forward + hide complete**
- [ ] **Step 2: Implement; screenshot Home vs `s-1657-2551`**
- [ ] **Step 3: Commit** `feat: home job rows resume like the live HTML list`

---

## Demo path (prove parity)

Same engineer email as HTML: `navigatorengineer@aspect.co.uk`.

1. Home lists the same Firestore jobs as live HTML.
2. Reactive leak: Dispatched WO → slide transit (`IN_TRANSIT`) → slide arrive → **Safety step 1 of 5** (`ON_SITE`) → fill → Submit report → Completed WO + follow-on.
3. Reload mid-form: land on furthest LD step.
4. Job with `job_type: PM` or `FP`: **works** 5-step, not leak.
5. Gas / boiler trade: CP12 **12** steps, gas WO transit/complete exist.
6. Portal/Dashboard see `ON_SITE` then `COMPLETE` + report + photos.

UI gate: three screenshots (leak WO dispatched, LD step 1, leak complete) vs live HTML at the same width.

## What you need running

```bash
# navigator-app-workflows
python3 tools/make_live_app.py
python3 tools/serve.py          # :8080

# aspect-middleware-server
npm start                       # :4000  POST /image-upload
```

Flutter: `--dart-define=PILLAR_UPLOAD_BASE=…` `--dart-define=PILLAR_SERVE_BASE=…` as in the 2026-08-12 plan.

## Do not do

- WebView the Figma file as a shortcut to “exact UI” unless product explicitly abandons native Flutter.
- Keep `LdFormPage` 4 tabs or `Cp12FormPage` 6 tabs as the production path.
- Open leak detection for every reactive job.
- Write `ON_SITE` without showing the form.
- Trust `docs/ENGINEER_APP_ALIGNMENT.md` widget names.
- Port chrome (rewards, withdraw, support Enquiries) in this plan.

## Scope split (if the team cannot land this in one PR)

Ship in this **order**; each slice is demoable:

1. Tasks 1–4 + spine status (routing + WO + On-site = form)
2. Task 5 (leak UI + 5 steps) + Task 8 (sign-off)
3. Tasks 6–7 (gas + works)
4. Tasks 9–10 (follow-on + Home)
5. Spine raises (separate plan file)

---

## Self-review

| Spec item | Task |
| --- | --- |
| `kindOf` FP/PM first | Task 1 |
| Resume `ON_SITE` → form | Tasks 2, 4 |
| ON_ENTER status | Task 4 + spine |
| LD 5-step merge + photos | Task 5 |
| CP12 12 | Task 6 |
| Works 5 + line items | Task 7 |
| Sign-off batch | Task 8 + 2026-08-12 |
| Follow-on screens | Task 9 |
| Home pull-forward | Task 10 |
| UI tokens / WO chrome | Task 3 |
| Reference pack | Header of this file |
