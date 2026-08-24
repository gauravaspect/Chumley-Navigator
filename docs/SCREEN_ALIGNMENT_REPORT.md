# Screen alignment report — Figma reference vs Flutter engineer app

**Date:** 2026-08-20  
**Method:** Read-only screen audit. No application code edited.  
**Complements:** [`docs/FLOW_VERIFICATION_REPORT.md`](FLOW_VERIFICATION_REPORT.md) (data spine)

| Repo | Role |
| --- | --- |
| `navigator-app-workflows` | Design reference — 107 Figma screens in HTML |
| `chumley_navigator` | Subject — native Flutter reimplementation |

**Reference catalogue:** [`docs/reference_screens.json`](reference_screens.json) (107 screens extracted from export)

---

## A. Executive summary

- **Total Figma screens:** 107 (verified via export parse)
- **Pillar journey % aligned** (strict: Overall = ALIGNED, or VISUAL ONLY + interactive WIRED): **~8%** (5 / 64 HIGH-priority screens)
- **All 107 screens — Exists (layer A):** **~42%** have a Flutter widget that covers some or all of the screen; **~35%** are ABSENT on pillar journeys; chrome (rewards/KPI/withdraw) mostly stub or partial
- **Reachable without dev hacks:** Core + reactive WO + FP from job card + PPM detail + VCR/absences/profile — **~25 screens** reachable on happy paths
- **Interactive WIRED for demo parity:** Only sign-in, FP submit wizard, VCR, absences, and partial job-card navigation qualify; most form/raise flows are STUB or DEAD

### Top 5 ABSENT screens blocking demo parity

| # | Figma id | data-title | Why it blocks |
| --- | --- | --- | --- |
| 1 | `s-2317-3931` … `s-2317-4221` | PM Bathroom WO + BF 1–5 | Reference routes FP/PM jobs to works form; Flutter has zero BF screens |
| 2 | `s-1907-2670` … `s-1908-3056` | PPM lead 1–4 + Sent | No wizard; support Enquiries tab is a different product shape |
| 3 | `s-1916-2811` … `s-1917-3198` | PM lead 1–4 + Sent | Entire journey missing |
| 4 | `s-2104-3322`, `s-2280-3863` | Follow-on / Visit complete | No `PostSubmitFlow`; raise card uses fake success dialogs |
| 5 | `s-2205-3953`, `s-2205-4099` | Gas PPM In Transit + Completed WO | `PpmJobDetailPage` skips WO ladder; no complete CTA |

### Top 5 STUB screens (look done, are not)

| # | Screen | Flutter | Trap |
| --- | --- | --- | --- |
| 1 | LD Form sign-off `s-2013-4305` | `LdFormPage._onSave` | Snackbar + `pop(true)`; no submit report |
| 2 | CP12 photos `s-2196-4854` | `Cp12FormPage._photoRow` | Toggles “Captured” on label string |
| 3 | RA Sent `s-2137-3718` | `_handleRaiseJob('Reactive Job')` | Success dialog only |
| 4 | Enquiries submit `s-2006-3475` | `EnquiriesScreen` | Submit `onTap: () {}` |
| 5 | WO Completed `s-2072-62797` | `JobDetailPage` banner | Local `_statusIndex`; “All forms submitted” with no sign-off |

### Biggest structure mismatches

| Journey | Design | Reference (live) | Flutter |
| --- | --- | --- | --- |
| LD form | 11 export screens | **5 effective steps** (`form_flow.js` merge) | **4 tabs** in `LdFormPage` (not a sequential wizard) |
| CP12 | 12 screens | 12 steps in `JOURNEY.gas` | **6 tabs** in `Cp12FormPage` |
| FP estimate | 4 screens (Describe → Confirm → Scope → Sent) | `estimate_runtime.js` | **6 internal steps** in `FixedPricePage` (different shape) |
| Reactive WO | Dedicated follow-on screens | 4 screens after complete | Merged into `JobDetailPage` banner + raise card |

---

## B. Reference: how screens work in the HTML app

The export (`Navigator-Modern-2026-full-app.html`) is a **107-screen grid** with in-app routing via `data-nav` on clickable elements. Runtimes (`live_bind.js`, `state_runtime.js`, `form_runtime.js`, etc.) are stitched into the live build by `make_live_app.py` — they bind Firestore data **without editing** the export DOM.

**Three trade journeys** (`state_runtime.js` `JOURNEY`):

| Kind | Dispatched | Transit | Form steps (effective) | Complete |
| --- | --- | --- | --- | --- |
| leak | `1991-3106` | `1991-3224` | 5 ids (11 export merged) | `2072-62797` |
| gas | `2205-3809` | `2205-3953` | 12 CP12 ids | `2205-4099` |
| bath | `2317-3931` | `2317-4075` | 5 BF ids | `2317-4221` |

**LD merge:** Export has 11 LD screens; live app uses 5 (`2013-3427`, `3546`, `3795`, `2057-3792`, `2070-3895`) after `form_flow.js` collapse.

**Raise flows:** `enquiry_runtime.js` `FLOWS` — PPM 4 + sent; PM 4 + sent; RA 3 + sent; Refer 1 + sent.

**Component audit:** `python3 tools/audit_components.py` → **23 option groups, 22 wired, 0 dead** (reference baseline).

---

## C. Flutter: how screens work today

- **Native widgets only** — no embedded `Navigator-Modern-2026-full-app.html` in the repo; alignment is against Figma titles, not a WebView.
- **Routing:** Named routes in `lib/utils/routes.dart` cover shell screens (login, home, profile, VCR, FP, chat). **Job flows use imperative** `Navigator.push` (`JobDetailPage.open`, `PpmJobDetailPage.open`, form pages).
- **Home shell:** `Home` bottom nav → Dashboard, Leaderboard, Milestones, Vehicle, Enquiries, Absences — **not** the Figma bottom bar, but functionally similar.
- **No `OnSiteWizard`, no `PostSubmitFlow`** — prior audit names are stale; LD is `LdFormPage` opened from job card; follow-on is inline on `JobDetailPage`.
- **`FormsScreen`** exists but is **not registered** in `AppRoutes`.
- **Wizard collapses:** see structure table above.

---

## D. Screen alignment matrix (journey-grouped)

Full catalogue: 107 rows in [`reference_screens.json`](reference_screens.json). Below: pillar journeys with merge notation.

| Figma id | data-title | Journey | Ref reachable | Flutter widget | A | B | C | D | Overall | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| s-1669-3136 | Sign in | Core | YES | `LoginScreen` | YES | YES | MATCH | WIRED | **ALIGNED** | Route `/login` |
| s-1657-2551 | Home | Core | YES | `DashboardScreen` | YES | YES | SIMPLIFIED | PARTIAL | VISUAL ONLY | Day strip via calendar widget; no separate “View all” screen |
| s-1668-3053 | Schedule | Core | YES | `DashboardCalendar` + bottom sheet | PARTIAL | PARTIAL | MERGED | PARTIAL | VISUAL ONLY | Calendar embedded in Home, not full Schedule screen |
| s-1991-3106 | WO - Dispatched | LD | YES | `JobDetailPage` | YES | YES | MATCH | PARTIAL | VISUAL ONLY | Status ladder present; starts Dispatched always |
| s-1991-3224 | WO - In Transit | LD | YES | `JobDetailPage` slider | YES | YES | MATCH | PARTIAL | VISUAL ONLY | Slider WIRED locally |
| s-2013-3427 … s-2070-3895 | LD Form 1–10 (11 export) | LD | YES (5 live steps) | `LdFormPage` (4 tabs) | PARTIAL | PARTIAL | MERGED | PARTIAL | VISUAL ONLY | Missing work-at-height, system details, test methods, parts, photos as steps |
| s-2013-4305 | LD Form - 12 Sign off | LD | YES | `LdFormPage` save | PARTIAL | PARTIAL | SIMPLIFIED | DEAD | **STUB** | Save snackbar, not Submit report |
| s-2072-62797 | WO - Completed | LD | YES | `JobDetailPage` banner | PARTIAL | PARTIAL | SIMPLIFIED | PARTIAL | VISUAL ONLY | No separate screen |
| s-2104-3322 | WO - Raise follow-on | LD | YES | Raise jobs card | PARTIAL | PARTIAL | SIMPLIFIED | DEAD | **STUB** | FP from card OK; follow-on raises fake dialog |
| s-2280-3863 | WO - Visit complete | LD | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-2272-3831 | WO - Job closed | LD | YES | Terminal slider badge | PARTIAL | PARTIAL | SIMPLIFIED | PARTIAL | VISUAL ONLY | |
| s-2158-3209 | FP2 - 1 Describe | FP | YES | `FixedPricePage` step 0 | YES | YES | SIMPLIFIED | WIRED | VISUAL ONLY | 6-step wizard vs 4 design screens |
| s-2158-3405 | FP2 - 2 Confirm | FP | YES | `FixedPricePage` step 3/5 | YES | YES | MERGED | WIRED | VISUAL ONLY | |
| s-2178-3327 | FP2 - 3 Scope | FP | YES | `FixedPricePage` steps 1–2 | YES | YES | MERGED | WIRED | VISUAL ONLY | |
| s-2158-3656 | FP2 - Sent | FP | YES | Snackbar after pop | YES | YES | SIMPLIFIED | WIRED | VISUAL ONLY | |
| s-1907-2670 … s-1908-3056 | PPM lead | PPM | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-1916-2811 … s-1917-3198 | PM lead | PM | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-2137-3437 … s-2137-3718 | RA | RA | YES | — | NO | NO | MISSING | DEAD | **STUB** | Dialog only from raise card |
| s-2115-3349 … s-2115-3440 | Refer | Refer | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-2205-3809 | WO Dispatched (Gas PPM) | CP12 | YES | `PpmJobDetailPage` | PARTIAL | YES | SIMPLIFIED | PARTIAL | VISUAL ONLY | Task detail, not full WO frame |
| s-2205-3953 | WO In Transit (Gas PPM) | CP12 | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-2196-3397 … s-2196-5152 | CP12 1–12 | CP12 | YES | `Cp12FormPage` 6 tabs | PARTIAL | PARTIAL | MERGED | PARTIAL | VISUAL ONLY | Combustion/findings/notes collapsed |
| s-2205-4099 | WO Completed (Gas PPM) | CP12 | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | |
| s-2317-3931 … s-2317-4221 | PM Bathroom WO + BF | PM bath | YES | — | NO | NO | MISSING | DEAD | **ABSENT** | Entire journey |

### Chrome / N/A (summary)

| Section | Screens | Flutter coverage | Overall |
| --- | --- | --- | --- |
| VCR (8) | `VehileCheckScreen` + `VehicleForm` | 6 areas + submit WIRED | **ALIGNED** (N/A pillar) |
| Absences (1) | `AbsencesScreen` | WIRED | **ALIGNED** (N/A) |
| Leaderboard / Points / Milestones (10) | API-backed screens | Mostly VISUAL ONLY | N/A chrome |
| Rewards / KPI / Withdraw (14) | `RedeemPointsScreen`, stubs | Many `onTap: () {}`; withdraw placeholder | STUB / ABSENT |
| Notifications (4) | `NotificationScreen` | Empty tabs — shell only | STUB |
| Support Enquiries (6) | `EnquiriesScreen` | Submit dead; not PPM/PM wizards | STUB |
| Profile (2) | `ProfileScreen` | Partial | VISUAL ONLY |

---

## E. Journey coverage scores

| Journey | Screens (HIGH) | A Exists YES/PARTIAL | B Reachable | C MATCH/MERGED | D WIRED | % aligned* |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Core | 3 | 3 | 3 | 1 | 1 | 33% |
| LD reactive | 17 | 8 | 7 | 3 | 0 | 0% |
| FP estimate | 4 | 4 | 4 | 3 | 4 | 100%† |
| PPM lead | 5 | 0 | 0 | 0 | 0 | 0% |
| PM lead | 5 | 0 | 0 | 0 | 0 | 0% |
| RA | 4 | 0 | 0 | 0 | 0 | 0% |
| Refer | 3 | 0 | 0 | 0 | 0 | 0% |
| Gas CP12 | 15 | 7 | 6 | 1 | 0 | 0% |
| PM bathroom | 8 | 0 | 0 | 0 | 0 | 0% |
| **Pillar total** | **64** | **22** | **20** | **8** | **5** | **8%** |
| All 107 incl. chrome | 107 | ~45 | ~40 | ~15 | ~12 | **~11%** |

\* % aligned = screens with Overall ALIGNED or (VISUAL ONLY + D=WIRED) ÷ journey HIGH screens  
† FP counts as aligned on **screen presence + wired submit**; data shape still wrong per flow report

---

## F. Navigation path tables

### F.1 Reactive leak

| Step | Figma id / title | HTML live (effective) | Flutter path | Match? |
| --- | --- | --- | --- | --- |
| 1 | Home `s-1657-2551` | `live_bind` home | `DashboardScreen` | PARTIAL |
| 2 | Open job row | `data-nav` → WO | `JobDetailPage.open` | YES |
| 3 | Dispatched `s-1991-3106` | `JOURNEY.leak.dispatched` | Status panel index 1 | VISUAL |
| 4 | In Transit `s-1991-3224` | `ON_ENTER` / transit | Slider → index 2 | VISUAL |
| 5 | LD step 1 `s-2013-3427` | form step 0 of 5 | Open `LdFormPage` tab 1 (after on-site) | PARTIAL |
| 6 | LD steps 2–10 | form steps 1–4 (merged) | 4 tabs max; many export steps missing | NO |
| 7 | Sign off `s-2013-4305` | `signoff_runtime.submit` | `_onSave` snackbar | NO |
| 8 | Completed `s-2072-62797` | `JOURNEY.leak.complete` | Banner on same page | PARTIAL |
| 9 | Follow-on `s-2104-3322` | `paintFollowOn` | Raise card; FP OK, others STUB | NO |

**Gap:** Flutter opens LD for all reactive jobs; reference would send FP/PM to **bathroom works** (`kindOf` → `bath`).

### F.2 Gas CP12

| Step | Figma | HTML | Flutter | Match? |
| --- | --- | --- | --- | --- |
| 1 | WO Dispatched `s-2205-3809` | `JOURNEY.gas` | `PpmJobDetailPage` | PARTIAL |
| 2 | In Transit `s-2205-3953` | transit screen | — | NO |
| 3 | CP12 1–12 | 12 form screens | `Cp12FormPage` 6 tabs | MERGED |
| 4 | Completed `s-2205-4099` | complete screen | — | NO |

### F.3 PM bathroom

| Step | Figma | HTML | Flutter | Match? |
| --- | --- | --- | --- | --- |
| All | `s-2317-*` | `JOURNEY.bath` | — | **NO** |

### F.4 FP estimate

| Step | Figma | HTML | Flutter | Match? |
| --- | --- | --- | --- | --- |
| 1–3 | Describe / Confirm / Scope | `2158-*`, `2178-*` | `FixedPricePage` steps 0–5 | MERGED |
| 4 | Sent | `2158-3656` | Snackbar + pop | PARTIAL |

**Gap:** Job-card FP path works; follow-on “Raise Estimate” is commented out / dialog-only.

### F.5 PPM / PM / RA / Refer leads

| Journey | HTML `FLOWS` steps | Flutter | Match? |
| --- | --- | --- | --- |
| PPM | 4 + sent | — | NO |
| PM | 4 + sent | — | NO |
| RA | 3 + sent | Success dialog | NO |
| Refer | 1 + sent | — | NO |

---

## G. Component-level alignment (pillar sample)

| Control pattern | Reference | Flutter | Aligned? |
| --- | --- | --- | --- |
| Slide to Start Transit | `live_bind` + slider fix | `JobDetailPage` `CallStyleActionSlider` | VISUAL — works locally |
| Select / chip groups (LD) | `form_runtime` wired | `LdFormPage` dropdowns | PARTIAL |
| Field / text (LD) | `form_runtime` `wireText` | `TextField` controllers | PARTIAL |
| Slot photo upload | `photo_runtime` + `upload_runtime` | CP12 toggle; LD no photos | **NO** |
| Chip / Opt (PPM/PM lead) | `enquiry_runtime` | — | **NO** |
| Submit report | `signoff_runtime` | LD save snackbar | **NO** |
| Save draft → home | `state_runtime` | Snackbar only | **NO** |
| Status ladder (5 steps) | `live_bind` paint | `_statusIndex` 5 labels | VISUAL |
| Day strip Mon–Sun | `live_bind` `paintStrip` | `DashboardCalendar` | PARTIAL |
| Job row template | `live_bind` clone | Appointment / PPM cards | PARTIAL |

### Flutter red-flag grep (screen-related)

| Pattern | Locations |
| --- | --- |
| `onTap: () {}` | `enquiries_screen.dart:324`, `job_detail_page.dart:1531`, profile, redeem, leaderboard, milestones |
| `_handleRaiseJob` | `job_detail_page.dart:1616` — Success dialog |
| `pop(true)` without persistence | `ld_form_page.dart:418`, `cp12_form_page.dart:370`, `form_details.dart:227`, etc. |
| `OnSiteWizard` | **0 hits** — not implemented |
| `PostSubmitFlow` | **0 hits** — not implemented |

---

## H. Prior audit reconciliation (`ENGINEER_APP_ALIGNMENT.md`)

| Prior inventory claim | Still true? | Notes |
| --- | --- | --- |
| OnSiteWizard for LD 1–12 | **Wrong** | Replaced by standalone `LdFormPage` (4 tabs) from job card |
| CP12 6 tabs not 12 screens | **Confirmed** | Structure MERGED |
| PostSubmitFlow for follow-on | **Wrong** | No widget; inline on `JobDetailPage` |
| PPM/PM/RA/Refer wizards absent | **Confirmed** | |
| PM bathroom absent | **Confirmed** | |
| Notifications empty tabs | **Confirmed** | |
| Forms hub unrouted | **Confirmed** | `FormsScreen` not in `AppRoutes` |
| Enquiries support tab not pillar leads | **Confirmed** | |
| VCR LIVE | **Confirmed** | |
| LD photos dummy | **Partially wrong** | LD page has no photo step; CP12 has dummy capture |

---

## I. Gap list for product (no code)

1. **Missing screens** — PPM lead, PM lead, Refer wizards; PM bathroom WO + BF; Gas PPM transit/complete WO; follow-on / visit-complete; dedicated Schedule screen; withdraw/KPI drawers.
2. **Wrong routing** — All reactive jobs → LD forms (should route FP/PM → works); follow-on FP vs job-card FP diverge; PPM opens form hub not WO ladder.
3. **Structure mismatch** — LD 11→5 (ref) vs 4 tabs (Flutter); CP12 12→6; FP 4→6; no sequential LD wizard with stepper.
4. **Dead controls** — Enquiries submit, related docs rows, raise dialogs, CP12 photo toggles, form save-as-submit.
5. **Chrome** — Hide or wire rewards redeem tiles, empty notifications, earnings/withdraw placeholders before investor demo.

---

## J. 15-minute manual walk script

| Step | Reference (localhost:8080 live) | Flutter | Tick |
| --- | --- | --- | --- |
| Sign in | Sign in screen | Login | ☐ |
| Home day strip | Home + strip | Dashboard | ☐ |
| Schedule | Schedule screen / view all | Calendar on dashboard | ☐ |
| Open reactive job | WO Dispatched | Job detail | ☐ |
| In Transit | Slider + screen | Slider | ☐ |
| LD form steps | 5 merged steps | 4-tab LD page | ☐ |
| Sign-off | Submit report | Save snackbar | ☐ |
| Completed + follow-on | 3 screens | Banner + raise card | ☐ |
| Raise FP job card | FP wizard | FixedPricePage | ☐ |
| Raise FP follow-on | Same wizard | Dialog only | ☐ |
| PPM task → CP12 | WO + 12 steps | Ppm detail → CP12 tabs | ☐ |
| PPM lead | 4-step wizard | Cannot reach | ☐ |
| PM lead | 4-step wizard | Cannot reach | ☐ |
| RA / Refer | Wizards | Dialog / absent | ☐ |
| PM bathroom job | BF form | Cannot reach | ☐ |

---

## Appendix: verification commands

```bash
# Reference screen extract → docs/reference_screens.json (107 screens)
python3 tools/audit_components.py
# → 23 option group(s): 22 wired, 0 dead, 4 multi-select
```

Phase 6 (visual side-by-side) skipped — not run in this audit.
