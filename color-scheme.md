# Form colour scheme

Leak, gas (CP12), and bathroom / works forms share **one** palette. There is no per-job-type theme.

**Source of truth:** `:root` in `app/Navigator-Modern-2026-full-app.html` / `app/Navigator-Modern-2026-live.html` (tokens), plus how forms actually use them (`app/form_runtime.js`, `app/form_flow.js`, `app/photo_runtime.js`, `app/live_bind.js` `TONE`).

Font: **Mont** (400 / 500 / 700 / 800), then `system-ui`.

---

## Page

Form screens (LD, CP12, bathroom, raise wizards) sit on this **vertical wash**, not a flat grey:

| Stop | Hex | Token |
| --- | --- | --- |
| 0% | `#F4F9FF` | `--surface-chrome` |
| 55% | `#EDF4FE` | Drawn in the export; no token |
| 100% | `#E2ECFA` | Drawn in the export; no token |

CSS equivalent:

```css
background-image: linear-gradient(180deg, #F4F9FF 0%, #EDF4FE 55%, #E2ECFA 100%);
```

| Role | Hex | Token |
| --- | --- | --- |
| Cards / fields | `#FFFFFF` | `--surface-card` |
| Sunken / photo empty | `#E3E9F2` | `--surface-muted` |
| Sunken (alt) | `#E9EDF5` | `--surface-sunken` |
| Hairline | `#E2E7F0` | `--border-hairline` |
| Strong border | `#D3DBE8` | `--border-strong` |
| Merge hairline fallback | `#E3E9F2` | `--border-subtle` (used in `form_flow.js`; **not** in `:root`) |
| Page fill (token, unused on form gradient) | `#F1F3F8` | `--surface-page` |
| Tertiary fill | `#F1F5F9` | `--colorfilltertiary` |

Studio canvas **behind** the phone device is `#101623`. That is not an in-app form colour.

---

## Brand (actions, selected, identity)

| Token | Hex | On forms |
| --- | --- | --- |
| `--brand-navy` | `#27549D` | Selected checkbox fill, selected chips, links, brand text |
| `--text-brand` | `#27549D` | Same as navy |
| `--surface-default` | `#27549D` | Same as navy |
| `--brand-navy-deep` | `#1A3A73` | Pressed / darker navy |
| `--brand-navy-soft` | `#C9DCF7` | Soft navy fill |
| `--brand-navy-tint` | `#D8E6FC` | Info chip background (same as `--status-info-bg`) |
| `--surface-lighter` | `#5A9CF6` | Lighter navy accents |
| `--surface-darker` | `#17325E` | Deep navy (rare on forms) |
| `--brand-yellow` | `#FFF23D` | Brand highlight (sliders / emphasis) |
| `--brand-yellow-deep` | `#E9F94A` | Yellow variant |
| `--brand-yellow-tint` | `#FBFFDE` | Yellow wash |
| `--colours-brandyellow-300` | `#F4FF7F` | Extra yellow step |
| `--border-lighter-200` | `#9FC3FC` | Light navy border |

**Checkbox** (`form_runtime.js`): unchecked fill is **transparent** (tick hidden); checked fill is `--brand-navy` `#27549D`.

---

## Text

| Token | Hex | Use |
| --- | --- | --- |
| `--text-primary` | `#0B1F3A` | Titles, answers, labels |
| `--text-secondary` | `#5A6B85` | Helper / secondary |
| `--text-tertiary` | `#8A99B0` | Section captions (e.g. “ADDITIONAL PHOTOGRAPHS…”) |
| `--text-inverse` | `#FFFFFF` | Text on navy |

`form_flow.js` caption fallback is `#8A99B4`. Prefer the token **`#8A99B0`**.

---

## Status (chips, complete, errors)

Same `TONE` map as the work order (`live_bind.js`):

| Tone | Background | Foreground |
| --- | --- | --- |
| Neutral | `#E3E9F2` (`--surface-muted`) | `#5A6B85` (`--text-secondary`) |
| Info | `#D8E6FC` (`--status-info-bg`) | `#27549D` (`--brand-navy`) |
| Success | `#E9F8EF` (`--status-success-bg`) | `#15803D` (`--status-success`) |
| Warning | `#FEF6E7` (`--status-warning-bg`) | `#B45309` (`--status-warning`) |
| Error | `#FDEDED` (`--status-error-bg`) | `#C42A2A` (`--status-error`) |

Extra fills in `:root`:

| Token | Hex |
| --- | --- |
| `--colours-green-100` | `#D3FAD1` |
| `--colours-red-100` | `#FFDDD2` |
| `--colours-red-700` | `#A72B01` |

`--status-danger` is **not** in `:root`. Runtimes fall back to `#C42A2A` (same as `--status-error`).

---

## Full `:root` token list

Copy of the export (forms + chrome). Tier colours are for rewards, not on-site forms.

```css
:root {
  --border-hairline: #E2E7F0;
  --border-lighter-200: #9FC3FC;
  --border-strong: #D3DBE8;
  --brand-navy: #27549D;
  --brand-navy-deep: #1A3A73;
  --brand-navy-soft: #C9DCF7;
  --brand-navy-tint: #D8E6FC;
  --brand-yellow: #FFF23D;
  --brand-yellow-deep: #E9F94A;
  --brand-yellow-tint: #FBFFDE;
  --colorfilltertiary: #F1F5F9;
  --colours-brandyellow-300: #F4FF7F;
  --colours-green-100: #D3FAD1;
  --colours-red-100: #FFDDD2;
  --colours-red-700: #A72B01;
  --status-error: #C42A2A;
  --status-error-bg: #FDEDED;
  --status-info-bg: #D8E6FC;
  --status-success: #15803D;
  --status-success-bg: #E9F8EF;
  --status-warning: #B45309;
  --status-warning-bg: #FEF6E7;
  --surface-card: #FFFFFF;
  --surface-chrome: #F4F9FF;
  --surface-darker: #17325E;
  --surface-default: #27549D;
  --surface-lighter: #5A9CF6;
  --surface-muted: #E3E9F2;
  --surface-page: #F1F3F8;
  --surface-sunken: #E9EDF5;
  --text-brand: #27549D;
  --text-inverse: #FFFFFF;
  --text-primary: #0B1F3A;
  --text-secondary: #5A6B85;
  --text-tertiary: #8A99B0;
  --tier-bronze: #C77B30;
  --tier-diamond: #35C2D4;
  --tier-gold: #E0A526;
  --tier-platinum: #6D8299;
  --tier-silver: #7C8794;
  --white: #FFFFFF;
}
```

---

## Flutter mapping (forms)

```dart
// Page gradient
static const pageTop = Color(0xFFF4F9FF);
static const pageMid = Color(0xFFEDF4FE);
static const pageBottom = Color(0xFFE2ECFA);

static const card = Color(0xFFFFFFFF);
static const muted = Color(0xFFE3E9F2);
static const sunken = Color(0xFFE9EDF5);
static const hairline = Color(0xFFE2E7F0);
static const border = Color(0xFFD3DBE8);

static const navy = Color(0xFF27549D);
static const navyDeep = Color(0xFF1A3A73);
static const navySoft = Color(0xFFC9DCF7);
static const navyTint = Color(0xFFD8E6FC);
static const navyLight = Color(0xFF5A9CF6);
static const yellow = Color(0xFFFFF23D);
static const yellowDeep = Color(0xFFE9F94A);
static const yellowTint = Color(0xFFFBFFDE);

static const textPrimary = Color(0xFF0B1F3A);
static const textSecondary = Color(0xFF5A6B85);
static const textTertiary = Color(0xFF8A99B0);
static const textOnNavy = Color(0xFFFFFFFF);

static const success = Color(0xFF15803D);
static const successBg = Color(0xFFE9F8EF);
static const warning = Color(0xFFB45309);
static const warningBg = Color(0xFFFEF6E7);
static const error = Color(0xFFC42A2A);
static const errorBg = Color(0xFFFDEDED);
```

Do not use `--tier-*` on visit forms. Attach this file with the Flutter job-flow plan when matching HTML UI.
