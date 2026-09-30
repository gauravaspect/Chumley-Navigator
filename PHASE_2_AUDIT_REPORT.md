# Phase 2 Audit Report: UI Modularization & Reusable Architecture

**Project:** Aspect Chumley Navigator (Flutter)  
**Phase:** Phase 2 (UI Modularization & Reusable Architecture)  
**Date:** September 2026  
**Status:** Completed & Verified  

---

## Executive Summary

Phase 2 focused on decomposing monolithic `StatefulWidget` files, extracting clean and focused UI step components, unifying duplicated calendar and form logic, and formalizing reusable design system components without changing business behavior or introducing extraneous dependencies.

### Key Results:
- **`on_site_wizard.dart`**: Reduced from **2,951 lines** to **1,068 lines** (**-63.8%**).
- **`fixed_price_page.dart`**: Reduced from **2,256 lines** to **939 lines** (**-58.4%**).
- **Calendar Logic**: Unified duplicated month grid calculations, date math, and suffix formatters across `dashboard_calendar.dart` and `absence_calendar.dart` into `AspectCalendarUtils` and `AspectCalendarView`.
- **Zero Regressions**: **85/85 tests passing**, **0 analyzer issues**, full code formatting applied (`dart format`).

---

## 1. Refactored Files & Component Breakdown

### 1.1 On-Site Wizard (`on_site_wizard.dart`)
The 12-step Leak Detection on-site wizard was decomposed into dedicated step widgets under `lib/screens/job_details/steps/`:

| Component File | Step Responsibility |
|---|---|
| `steps/ld_step_ui_helpers.dart` | Shared styling, `LdSectionCard`, `LdLabeled`, `LdChipGroup`, `LdDropdown`, `LdDeclarationTile`, `LdInfoBanner`, `LdTextField`, and `LdPartEntry` model. |
| `steps/ld_risk_assessment_step.dart` | **Step 0**: Site access, risk assessment declaration, HSE gatekeeper checks, and pre-work checks. |
| `steps/ld_work_at_height_step.dart` | **Step 1**: WAHR guidance, access methods, equipment inspection, exclusion zone, lone working, and training. |
| `steps/ld_context_step.dart` | **Step 2**: Leak triage, property profile, water meter, insurance claim, and scope limitations. |
| `steps/ld_system_details_step.dart` | **Step 3**: Plumbing subsystem, pipe material, age band, maintenance history, and previous leaks. |
| `steps/ld_visual_inspection_step.dart` | **Step 4**: Visible signs, affected area extent, active wetness, pattern, and first impressions. |
| `steps/ld_test_methods_step.dart` | **Step 5**: Test methods deployed, thermal readings, moisture verification, before/after evidence photos. |
| `steps/ld_visit_conclusion_step.dart` | **Step 6**: Leak identification status, repair details, repair photos, drying & reinstatement briefing. |
| `steps/ld_parts_used_step.dart` | **Step 7**: Consumed parts list with dynamic add/remove, categories, quantities, and reference numbers. |
| `steps/ld_photos_step.dart` | **Step 8**: Standard evidence gallery (front of property, overview, close-up, water meter, etc.). |
| `steps/ld_notes_step.dart` | **Step 9**: Customer-facing narrative with 50-char validation, suggested topics, and office notes. |
| `steps/ld_findings_step.dart` | **Step 10**: Findings summary, severity levels, leak classification, and suspected source. |
| `steps/ld_sign_off_step.dart` | **Step 11**: 10-step review navigation summary, engineer declaration, timestamps, and signature pad. |

**Parent Responsibility:** `on_site_wizard.dart` now acts as a high-level wizard orchestrator managing step progression, draft serialization/deserialization via `FormDraftStore`, and speech-to-text dictation lifecycle.

---

### 1.2 Fixed Price Wizard (`fixed_price_page.dart`)
The 6-step Fixed Price Agreement wizard was decomposed into dedicated step widgets under `lib/screens/job_details/fixed_price/`:

| Component File | Step Responsibility |
|---|---|
| `fixed_price/fixed_price_ui_helpers.dart` | Reusable searchable dropdowns (`DropdownButtonFormField2`), currency fields with `£` prefix, animated multiline fields, radio option groups, and animated toggle switches. |
| `fixed_price/fixed_price_catalog_step.dart` | **Step 1**: Trade, category, and work-type catalog selection with shimmers and search controllers. |
| `fixed_price/fixed_price_scope_step.dart` | **Step 2**: Selected work type card, approval limit notice, and 3-tier scope of work editor. |
| `fixed_price/fixed_price_pricing_step.dart` | **Step 3**: Collection fee, list price service selection, operative & Aspect materials, drainage patches, and ULEZ toggles. |
| `fixed_price/fixed_price_operative_step.dart` | **Step 5**: Zonal discount indicators, duration hours input, labour rate selection cards, and customer charge breakdown. |
| `fixed_price/fixed_price_confirmation_step.dart` | **Step 7**: Scope summary preview, pricing subtotal / VAT / deposit calculations, customer confirmation options (Accept / Reject). |
| `fixed_price/fixed_price_review_step.dart` | **Step 8**: Full job context validation, contact details, invoice generation flags, and final agreement review. |

**Calculations & Domain Logic:** Pure pricing formulas remain encapsulated in `FixedPriceSubmitPayload` (`labourCharge`, `hourlyRateForLevel`, `calculateSubtotal`, etc.), ensuring zero duplicated math and high testability.

---

### 1.3 Calendar Unification (`aspect_calendar_view.dart`)
Extracted generic calendar calculations and date utility helpers to `lib/widgets/calendar/aspect_calendar_view.dart`:

- **`AspectCalendarUtils`**:
  - Month day grid generator (`buildCalendarDays`) resolving leading and trailing blanks without edge-case date overflow bugs.
  - Weekday arrays (`weekDays`, `fullWeekDays`) and month names (`monthNames`, `shortMonthNames`).
  - Day suffix formatter (`getDayWithSuffix`: `1st`, `2nd`, `3rd`, `4th`).
- **`AspectCalendarView`**:
  - Generic monthly calendar grid supporting customizable `dayBuilder`, navigation headers, and theme styling.
- **Consumers Refactored**:
  - `lib/components/dashboard/dashboard_calendar.dart`
  - `lib/widgets/absences/absence_calendar.dart`

---

## 2. Before / After Metrics

| Major File | Before LOC | After LOC | Difference | Reduction % |
|---|---|---|---|---|
| `lib/screens/job_details/on_site_wizard.dart` | 2,951 | 1,068 | -1,883 lines | **-63.8%** |
| `lib/screens/job_details/fixed_price_page.dart` | 2,256 | 939 | -1,317 lines | **-58.4%** |
| `lib/components/dashboard/dashboard_calendar.dart` | 1,334 | 1,269 | -65 lines | Logic unified into `AspectCalendarUtils` |
| `lib/widgets/absences/absence_calendar.dart` | 360 | 334 | -26 lines | Logic unified into `AspectCalendarUtils` |

### Codebase Inventory Summary:
- **Files Created**: 20 new modular components and helpers.
- **Files Deleted**: 0 (no breaking removals).
- **Test Suite Results**: 85/85 tests passing.
- **Dart Analyzer**: 0 issues found.

---

## 3. Duplication Consolidated

1. **Calendar Math & Date Logic**:
   - Consolidated month calculation math (`weekday % 7`), grid days generation, and ordinal suffixes into a single source of truth.
2. **Form Card & Container Builders**:
   - Replaced repetitive card decorations, labeled form sections, and declaration tiles with `LdSectionCard` and `LdLabeled`.
3. **Fixed Price Form Controls**:
   - Standardized currency fields, decimal inputs, and searchable dropdowns into `FixedPriceUiHelpers`.
4. **Speech-to-Text Dictation**:
   - Preserved microphone permission management and listener state at the wizard root while injecting standardized `onToggleDictation` and `isListeningFor` callbacks into text inputs.

---

## 4. Verification & Test Execution

```text
$ flutter analyze
Analyzing chumley_navigator...
No issues found! (ran in 3.0s)

$ flutter test
00:04 +85: All tests passed!

$ dart format lib test
Formatted 230 files (156 changed) in 1.02 seconds.
```

---

## 5. Remaining Large Files (>1,000 LOC) & Recommendations

| File | LOC | Primary Responsibilities | Recommended Refactoring |
|---|---|---|---|
| `lib/screens/job_details/job_detail_page.dart` | 2,283 | Multi-phase job management (Dispatched, In Transit, On Site, Closed), action sheets, navigation. | Decompose into distinct phase view widgets (`DispatchedPhaseView`, `InTransitPhaseView`, `OnSitePhaseView`, `ClosedPhaseView`). |
| `lib/screens/forms/damp_survey_form_page.dart` | 1,798 | Damp survey inspection wizard and HSE checklists. | Extract reusable step cards using `LdSectionCard` and `LdDeclarationTile`. |
| `lib/screens/chumley_ai/chumley_chat.dart` | 1,367 | AI chat screen with message history, voice recorder bar, and quick reply chips. | Extract `ChatMessageBubble`, `ChatVoiceRecorderBar`, and `ChatQuickActions`. |
| `lib/screens/forms/vent_hygiene_form_page.dart` | 1,362 | Ventilation hygiene inspection form. | Extract modular form section widgets. |
| `lib/screens/milestones/milestone_screen.dart` | 1,360 | Gamification badges, milestones, and celebration animations. | Extract milestone badge cards and progress header widgets. |
| `lib/screens/forms/eicr_form_page.dart` | 1,294 | Electrical installation condition report. | Extract modular inspection sections. |
| `lib/screens/job_details/post_submit_flow.dart` | 1,210 | Post-submission success and follow-on job routing. | Extract enquiry cards and attendance sheets. |
| `lib/screens/forms/ld_form_page.dart` | 1,195 | Legacy leak detection form. | Deprecate in favor of `on_site_wizard.dart` or modularize. |
| `lib/screens/vehicle_check/vehicle_form.dart` | 1,080 | Vehicle inspection form steps and photos. | Extract step widgets into `vehicle_check/steps/`. |
| `lib/screens/job/follow_on_page.dart` | 1,068 | Follow-on attendance, quotes, and referral sheets. | Extract sheet components into dedicated widgets. |

---

## 6. Next Recommended Phase: Phase 3

**Focus: Core Journey & Job Detail Page Decomposition**
1. Modularize `lib/screens/job_details/job_detail_page.dart` into phase-based widgets.
2. Modularize `lib/screens/job_details/post_submit_flow.dart` and `lib/screens/job/follow_on_page.dart`.
3. Modularize `lib/screens/chumley_ai/chumley_chat.dart` by separating voice recorder and message bubble widgets.
