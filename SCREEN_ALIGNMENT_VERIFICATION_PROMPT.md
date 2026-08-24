# Prompt: verify screen alignment — Figma reference vs Flutter engineer app

Copy everything below the line into an agent chat that can read **both** repos.
Do **not** edit code. Verify and report only.

| Repo | Role |
| --- | --- |
| `navigator-app-workflows` | **Design reference** — 107 Figma screens in HTML (`data-title`, `data-name`, `data-nav`) |
| `chumley_navigator` (Flutter) | **Subject under test** — native reimplementation of the same journeys |

This prompt complements `docs/VERIFICATION_FLOW_PROMPT.md` (data spine). Here the
question is: **how much of the designed UI and navigation exists in Flutter,
and how faithfully?**

Attach:

- `navigator-app-workflows/app/Navigator-Modern-2026-full-app.html` (or live build)
- `navigator-app-workflows/docs/ENGINEER_APP_ALIGNMENT.md` (prior screen rows — re-verify)
- Flutter `lib/` tree and any embedded copy of the HTML export

---

You are performing a **read-only screen alignment audit**. Compare the Figma
export (canonical design) against the Flutter engineer app screen-by-screen and
journey-by-journey. **Do not implement fixes.**

## What “aligned” means (four layers)

Score each screen or step separately. A screen can be high on one layer and low
on another.

| Layer | Question | Levels |
| --- | --- | --- |
| **A. Exists** | Is there a Flutter route/widget for this `data-title`? | YES / PARTIAL / NO |
| **B. Reachable** | Can the engineer navigate here from Home → job → flow without dev hacks? | YES / PARTIAL / NO |
| **C. Structure** | Same step count, same primary fields/controls, same CTAs (`Slide to…`, `Submit report`, chip groups)? | MATCH / MERGED / SIMPLIFIED / MISSING / EXTRA |
| **D. Interactive** | Taps do what the design implies (not dummy/snackbar/dead `onTap`)? | WIRED / PARTIAL / DEAD |

**Overall screen status** (pick one):

- **ALIGNED** — A–D all good for pillar demo purposes
- **VISUAL ONLY** — looks similar; navigation or controls wrong
- **STUB** — placeholder, empty tabs, or success dialog only
- **ABSENT** — no Flutter equivalent
- **N/A** — out of scope (e.g. KPI boost) — say if hidden or still shown

---

## Ground rules

1. **Figma export is the screen catalogue.** Screen id = `s-XXXX-YYYY`. Human
   name = `data-title="…"` on the screen div. Layer names = `data-name="…"`.
2. **HTML live app may merge screens.** `form_flow.js` collapses LD 12 steps → 5
   at runtime. Record **design step count** and **effective step count** for
   both reference and Flutter.
3. **Flutter may collapse or split differently.** CP12 as 6 tabs vs 12 screens
   is a **structure** gap, not automatically absent.
4. **Evidence:** cite export id + `data-title`, Flutter file + class/widget,
   and whether the screen is registered in routing (`AppRoutes`, `GoRouter`, etc.).
5. **Do not edit code.** Optional: run read-only scripts listed below.

---

## Phase 0 — Build the reference screen catalogue

From `navigator-app-workflows`:

### 0.1 Extract all 107 screens

Run (read-only):

```bash
python3 << 'PY'
import re, io, json
p = "app/Navigator-Modern-2026-full-app.html"
t = io.open(p, encoding="utf-8", errors="replace").read()
screens = []
for m in re.finditer(r'id="(s-\d+-\d+)"', t):
    sid = m.group(1)
    chunk = t[m.start():m.start() + 800]
    dt = re.search(r'data-title="([^"]+)"', chunk)
    if dt:
        screens.append({"id": sid, "title": dt.group(1)})
# de-dupe
seen = set(); out = []
for s in screens:
    if s["id"] not in seen:
        seen.add(s["id"]); out.append(s)
print(json.dumps(out, indent=2))
print("total:", len(out), file=__import__("sys").stderr)
PY
```

Save output as **`reference_screens.json`** in the report appendix.

### 0.2 Map Figma sections (from export grid)

The HTML grid groups screens under `<h2>` headings. Use these **journeys** when
reporting coverage percentages:

| Figma section | Pillar priority | Example `data-title` prefixes |
| --- | --- | --- |
| Core | HIGH | Sign in, Home, Schedule |
| AnR LD Job flow | HIGH | `WO -`, LD steps, Follow-on |
| Fixed price from survey | HIGH | `FP2 -` |
| PPM lead | HIGH | `PPM -` |
| PM project | HIGH | `PM -` |
| Reactive attendance | HIGH | `RA -` |
| Refer and earn | HIGH | `Refer -` |
| PPM Gas (CP12) | HIGH | `WO - (Gas PPM)`, `CP12` |
| PM Bathroom / BF | HIGH | `WO -`, `BF -` |
| Notifications | MED | `Notifications -` |
| Enquiry detail & withdraw | LOW | Enquiries, Withdraw |
| VCR flow | N/A (separate product) | `VCR -` |
| Profile & more | MED | Profile |
| Rewards & milestones | N/A chrome | Points Hub |
| KPI pools / nudge | N/A chrome | KPI |
| Instant pay | N/A chrome | Withdraw |

### 0.3 Reference navigation graph (verify in code)

Document **intended journeys** from runtimes (not from clicking alone):

**Leak reactive** — `state_runtime.js` `JOURNEY.leak`:

```
1991-3106 Dispatched → 1991-3224 In Transit
→ form: 2013-3427, 2013-3546, 2013-3795, 2057-3792, 2070-3895
  (form_flow.js merges 11 export screens into these 5)
→ 2072-62797 Completed → 2104-3322 Raise follow-on → …
```

**Gas / CP12** — `JOURNEY.gas`: 12 form screen ids `2196-*`

**PM bathroom / works** — `JOURNEY.bath`: `2317-3931` … `2317-4221`, form `2317-4332` … `2317-5049`

**FP estimate** — `estimate_runtime.js`: `2158-3209` Describe → `2178-3327` Scope → sent `2158-3656`

**Raise flows** — `enquiry_runtime.js` `FLOWS`: PPM 4 steps + sent; PM 4 + sent; RA 3 + sent; Refer 1 + sent

**Work orders bound to data** — `live_bind.js` `WO_SCREENS` + `ON_ENTER`

List every screen id in each journey for the matrix in Phase 2.

### 0.4 Reference component inventory (interactive controls)

Run:

```bash
python3 tools/audit_components.py
```

For each flow section (LD, Fixed price, PPM, PM, RA, Refer), note:

- Option groups: `Chip/` vs `Opt/` (Flutter must handle both patterns)
- Select dropdowns, Field text, Slot photo uploads, Slide buttons
- Count **dead** controls (0 dead = reference baseline)

---

## Phase 1 — Build the Flutter screen catalogue

In `chumley_navigator`:

### 1.1 Route and screen inventory

Grep and list:

```bash
grep -r "class .*Screen\|class .*Page\|GoRoute\|AppRoutes\." lib/ --include="*.dart"
grep -r "Navigator-Modern-2026\|data-title\|s-[0-9]" lib/ --include="*.dart"
```

For each Flutter screen file, record:

| Flutter widget | Route name / path | Intended Figma `data-title` (if documented in code/comments) | Registered in router? |

### 1.2 Embedded HTML export

If Flutter ships `Navigator-Modern-2026-full-app.html` under `lib/`:

- Is it used at runtime (WebView) or **visual reference only**?
- If reference only, Flutter alignment is **native widgets**, not the HTML file.

### 1.3 Multi-screen wizards

Identify wizards that map to **many** Figma screens in one widget:

| Flutter widget | Figma screens claimed | Step count in code | Notes |
| --- | --- | --- | --- |
| `OnSiteWizard` | LD 1–12 | ? | |
| `Cp12FormPage` | CP12 1–12 | 6 tabs? | |
| `FixedPricePage` | FP2 1–4 | 6 steps? | |
| `PostSubmitFlow` | Follow-on screens | phases? | |
| `PpmJobDetailPage` | Gas WO + forms | partial? | |

For each wizard: list step titles in order and map to export ids.

---

## Phase 2 — Screen alignment matrix

Produce one row per **Figma screen** (all 107), or one row per **journey step**
where wizards are merged (state both counts).

Columns:

| Figma id | data-title | Journey | Ref reachable | Flutter widget | A Exists | B Reachable | C Structure | D Interactive | Overall | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

**Ref reachable:** YES if HTML live app router or runtime journey includes this
screen (after merge, note “effective step 3 of 5”).

**Structure codes:**

- **MATCH** — same steps and primary controls
- **MERGED** — reference or Flutter combined multiple export screens (document which)
- **SIMPLIFIED** — fewer fields/steps than design
- **MISSING** — Flutter has nothing for this step
- **EXTRA** — Flutter has screens not in Figma (list separately)

---

## Phase 3 — Journey coverage scores

After the matrix, compute percentages **per Figma section** (Phase 0.2):

| Journey | Screens in design | Exists (A) | Reachable (B) | Structure MATCH/MERGED | Interactive WIRED | % aligned |
| --- | --- | --- | --- | --- | --- | --- |

Define **% aligned** as:

```
screens with Overall = ALIGNED or (VISUAL ONLY + WIRED interactive)
────────────────────────────────────────────────────────────────── × 100
screens in journey with pillar priority HIGH
```

Report **two numbers**:

1. **Pillar journeys only** (Core + LD + FP + raises + CP12 + PM bathroom)
2. **All 107 screens** including rewards/VCR/withdraw

---

## Phase 4 — Navigation path verification

For each pillar journey, verify **path equivalence** (manual or by reading code).

Use this checklist format:

### 4.1 Reactive leak (design reference)

| Step | Figma id / title | HTML live (after merge) | Flutter path | Match? |
| --- | --- | --- | --- | --- |
| 1 | Home `s-1657-2551` | live_bind home | `DashboardScreen` | |
| 2 | Open job row | `data-nav` → WO | `JobDetailPage` | |
| 3 | Dispatched `s-1991-3106` | WO_SCREENS | status panel | |
| 4 | In Transit `s-1991-3224` | ON_ENTER | slider | |
| 5 | LD step 1 `s-2013-3427` | form step 0 | wizard step 0 | |
| … | | | | |
| n | Submit report | signoff_runtime | `_onNext` | |
| n+1 | Follow-on `s-2104-3322` | paintFollowOn | `PostSubmitFlow` | |

Repeat templates for:

- Gas CP12 (`2205-*`, `2196-*`)
- PM bathroom (`2317-*`)
- FP estimate (`2158-*`, `2178-*`)
- PPM lead (`1907-*`, `1908-*`)
- PM lead (`1916-*`, `1917-*`)
- Reactive attendance (`2137-*`)
- Refer (`2115-*`, `2129-*`)

**Navigation gaps to flag explicitly:**

- Flutter opens LD for all jobs vs reference routes FP/PM to works form
- Follow-on “Raise Estimate” dialog vs `FixedPricePage` from job card
- PPM detail has no In Transit / Completed WO screens
- PM bathroom WO entirely absent in Flutter
- `FormsScreen` / legacy LD pages parallel to main wizard
- Support `EnquiriesScreen` vs designed PPM/PM wizards

---

## Phase 5 — Component-level alignment (controls)

For **pillar screens only**, sample-check that Flutter implements the same
**control types** as the export (`data-name` patterns):

| Control pattern | Export example | Reference wired? | Flutter equivalent | Aligned? |
| --- | --- | --- | --- | --- |
| `Slide to Start Transit` | WO In Transit | live_bind slider fix | `JobDetailPage` slider | |
| `Select/<question>` + sheet | LD form | form_runtime | dropdown/sheet? | |
| `Field/<question>` | LD text | form_runtime wireText | TextField? | |
| `Slot/` photo upload | LD / BF | photo + upload | ImagePicker? dummy? | |
| `Chip/` or `Opt/` groups | PPM/PM lead | enquiry_runtime | toggles? | |
| `Submit report` | LD sign off | signoff_runtime | button wired? | |
| `Save draft` → home | LD | state_runtime | snackbar only? | |
| Status ladder 5 steps | WO header | live_bind paint | `_statusIndex` | |
| Day strip Mon–Sun | Home | live_bind paintStrip | calendar widget? | |
| Job row template `Job/` | Home | live_bind clone | appointment card? | |

Run reference audit:

```bash
python3 tools/audit_components.py
```

For Flutter: grep for `onTap: () {}`, `dummy`, `coming soon`, `Success dialog`,
`Photo captured (dummy)`, `Draft saved` without persistence — map to screen.

---

## Phase 6 — Visual fidelity (optional, manual)

If you can run both apps side by side (HTML via `python3 tools/serve.py`, Flutter
on simulator), score **visual** alignment for pillar screens only:

| Screen | Layout (header, ladder, CTA position) | Typography/colours | Copy/labels | Score 1–5 |
| --- | --- | --- | --- | --- |

Use `data-title` and primary heading text as the copy checklist. This is
subjective; mark as manual.

Do **not** require pixel-perfect match. Flag:

- Missing status ladder on WO
- Wrong stepper dot count (LD 5 vs 12)
- Placeholder customer names from design (`Simone Zacchi`) still showing in Flutter
- Follow-on screen not naming live job (reference `paintFollowOn` fixes this)

---

## Phase 7 — Output document

Write **`docs/SCREEN_ALIGNMENT_REPORT.md`** (or paste in chat):

### A. Executive summary

- Total Figma screens: 107
- Pillar journey **% aligned** (Exists / Reachable / Wired)
- Top 5 **ABSENT** screens blocking demo parity
- Top 5 **STUB** screens that look done but are not
- Biggest **structure** mismatches (LD 12→5, CP12 12→6, FP wizard shape)

### B. Reference: how screens work in the HTML app

Short narrative:

- Export is a grid + in-app router on `data-nav`
- Runtimes bind data without editing export
- LD merge (`form_flow.js`) vs export step count
- Three trade journeys (leak / gas / bath)

### C. Flutter: how screens work today

Short narrative:

- Which widgets map to which journeys
- What is native vs unused HTML asset
- Known wizard collapses and dead ends

### D. Full matrix (Phase 2)

### E. Journey scores (Phase 3 table)

### F. Navigation path tables (Phase 4)

### G. Component gaps (Phase 5)

### H. Prior audit reconciliation

For each screen row in `ENGINEER_APP_ALIGNMENT.md` inventory: **confirmed /
fixed / wrong**.

### I. Gap list for product (no code)

Group gaps:

1. **Missing screens** — build these routes/widgets
2. **Wrong routing** — same widgets, wrong graph
3. **Structure mismatch** — merge/split steps
4. **Dead controls** — wire or hide
5. **Chrome** — hide rewards/withdraw until wired

### J. 15-minute manual walk script

Same path on both apps; tick box per screen reached:

1. Sign in → Home → Schedule
2. Reactive job → WO ladder → LD → sign-off → follow-on
3. Raise FP (job card vs follow-on — note divergence)
4. PPM task → CP12
5. Attempt PPM lead / PM lead / RA / Refer (note absent steps)

---

## Reference journey cheat sheet (verify in code)

### Leak WO + form (HIGH)

| id | data-title |
| --- | --- |
| s-1657-2551 | Home (day strip) |
| s-1991-3106 | WO - Dispatched |
| s-1991-3224 | WO - In Transit |
| s-2013-3427 … s-2013-4305 | LD steps (11 export; 5 effective live) |
| s-2072-62797 | WO - Completed |
| s-2104-3322 | WO - Raise follow-on |
| s-2280-3863 | WO - Visit complete |
| s-2272-3831 | WO - Job closed |

### FP (HIGH)

| id | data-title |
| --- | --- |
| s-2158-3209 | FP2 - 1 Describe |
| s-2158-3405 | FP2 - 2 Confirm |
| s-2178-3327 | FP2 - 3 Scope |
| s-2158-3656 | FP2 - Sent |

### PPM lead (HIGH)

| id | data-title |
| --- | --- |
| s-1907-2670 | PPM - 1 Site |
| s-1907-2808 | PPM - 2 Scope |
| s-1908-2717 | PPM - 3 Lead |
| s-1908-2856 | PPM - 4 Review |
| s-1908-3056 | PPM - Sent |

### PM lead (HIGH)

| id | data-title |
| --- | --- |
| s-1916-2811 | PM - 1 Client |
| s-1916-2927 | PM - 2 Scope |
| s-1917-2855 | PM - 3 Timing |
| s-1917-2987 | PM - 4 Review |
| s-1917-3198 | PM - Sent |

### RA + Refer (HIGH)

| id | data-title |
| --- | --- |
| s-2137-3437 … s-2137-3718 | RA - 1 Issue … Sent |
| s-2115-3349, s-2129-3404, s-2115-3440 | Refer … Sent |

### Gas CP12 (HIGH)

| id | data-title |
| --- | --- |
| s-2205-3809 | WO - Dispatched (Gas PPM) |
| s-2205-3953 | WO - In Transit (Gas PPM) |
| s-2196-3397 … s-2196-5152 | CP12 steps |
| s-2205-4099 | WO - Completed (Gas PPM) |

### PM bathroom (HIGH)

| id | data-title |
| --- | --- |
| s-2317-3931 | WO - Dispatched (PM Bathroom) |
| s-2317-4075 | WO - In Transit (PM Bathroom) |
| s-2317-4332 … s-2317-5049 | BF steps |
| s-2317-4221 | WO - Job completed (PM Bathroom) |

---

## Flutter red flags (grep)

```bash
grep -rn "_statusIndex\|_handleRaiseJob\|Photo captured\|Draft saved\|onTap: () {}\|coming soon\|pop(true)" lib/
grep -rn "OnSiteWizard\|Cp12FormPage\|FixedPricePage\|PpmJobDetailPage\|PostSubmitFlow\|EnquiriesScreen" lib/
```

Zero hits for PPM/PM screen ids or widget names → those journeys are **ABSENT**.

---

## Stop conditions

| Condition | Action |
| --- | --- |
| Flutter repo missing | Catalogue reference 107 screens; Flutter columns “not verified” |
| Only HTML grid, not live app | Note LD merge applies only after `make_live_app.py`; do not run unless asked |
| Cannot run apps | Code + matrix only; skip Phase 6 visual |

**Remember: verify and report. Do not edit application code.**
