# Phase 4 Baseline Architecture & Codebase Audit Report

**Aspect Chumley Navigator (Flutter iOS / Android)**  
**Date:** September 25, 2026  
**Status:** Baseline Complete — Ready for Phase 4 Implementation  
**Baseline Verification:** `flutter analyze` (0 issues), `flutter test` (85/85 passed)

---

## 1. Repository Overview

| Metric | Value |
| --- | --- |
| **Target Platforms** | iOS / Android (Aspect Field Operative Tool) |
| **Flutter SDK** | `^3.10.3` (Dart 3.x compatible) |
| **Total Dart Files** | 228 in `lib/`, 22 in `test/` (250 total) |
| **Total Lines of Code (LOC)** | ~50,422 in `lib/` (~54,802 total repository) |
| **Core Architecture** | Feature-first / Hybrid MVVM with BLoC/Cubit + Repository Pattern |
| **State Management** | `flutter_bloc` / `cubit` (Auth, Appointments, Chat, Dashboard) + local `StatefulWidget` for complex wizard form state |
| **Networking** | `dio` + custom HTTP client (`PillarClient`, `JobService`, `ApiService`) + WebSocket (`web_socket_channel` / Centrifugo for AI chat) |
| **Local Storage** | `shared_preferences` (token caching, preferences, offline queue) |
| **Testing Structure** | 85 Unit/Widget tests across auth, job models, post-submit flow, follow-on sheets, and milestone calculation |

---

## 2. File Size Analysis

### Top 35 Dart Files Ranked by LOC

| Rank | File | LOC | Classes | Methods | Primary Responsibility |
| ---: | :--- | --: | ------: | ------: | :--- |
| 1 | `lib/screens/forms/eicr_form_page.dart` | 2,083 | 4 | 26 | Multi-tab Electrical Installation Condition Report (EICR) form |
| 2 | `lib/screens/forms/damp_survey_form_page.dart` | 1,834 | 3 | 26 | 9-step Damp & Mould Survey assessment form |
| 3 | `lib/screens/milestones/milestone_screen.dart` | 1,440 | 10 | 29 | Gamification, achievements, badges, tiers & XP progress screen |
| 4 | `lib/screens/forms/vent_hygiene_form_page.dart` | 1,387 | 3 | 26 | Ventilation hygiene compliance, operatives & kitchen extract form |
| 5 | `lib/components/dashboard/dashboard_calendar.dart` | 1,314 | 7 | 22 | Dashboard calendar widget, date pagination & scheduled job lists |
| 6 | `lib/screens/forms/ld_form_page.dart` | 1,198 | 3 | 28 | Legacy 4-tab Leak Detection form (superseded by `on_site_wizard.dart`) |
| 7 | `lib/screens/job_details/job_detail_page.dart` | 1,101 | 2 | 16 | Core Job Details screen & lifecycle state coordinator (Refactored Phase 3) |
| 8 | `lib/screens/vehicle_check/vehicle_form.dart` | 1,071 | 6 | 12 | 5-step daily operative vehicle safety & equipment check form |
| 9 | `lib/screens/job_details/on_site_wizard.dart` | 1,064 | 3 | 12 | On-site Leak Detection 4-step wizard coordinator (Modularized Phase 2) |
| 10 | `lib/screens/job_details/fixed_price_page.dart` | 942 | 2 | 16 | Fixed price estimate/quote generation wizard (Modularized Phase 2) |
| 11 | `lib/screens/job_details/ppm_job_detail_page.dart` | 895 | 3 | 8 | Planned Preventative Maintenance (PPM) job detail screen |
| 12 | `lib/screens/job/follow_on_page.dart` | 856 | 6 | 11 | Follow-on quote/job raising modal and forms (Refactored Phase 3) |
| 13 | `lib/screens/enquiries/enquiries_screen.dart` | 851 | 10 | 10 | Operative customer enquiries list and detail viewing |
| 14 | `lib/screens/leaderboard/leaderboard_screen.dart` | 818 | 7 | 13 | Operative peer ranking & KPI leaderboard screen |
| 15 | `lib/screens/dashboard/earnings_detail_screen.dart` | 765 | 4 | 9 | Pay/commission analytics and earnings breakdown screen |
| 16 | `lib/screens/absences/absences_screen.dart` | 733 | 2 | 8 | Holiday booking, sick leave, and absence request screen |
| 17 | `lib/screens/profile/profile_screen.dart` | 689 | 9 | 17 | Operative user profile, settings, certifications & credentials |
| 18 | `lib/screens/redeemPoints/redeem_points.dart` | 688 | 10 | 14 | Points shop, rewards redemption catalog & checkout flow |
| 19 | `lib/screens/job_details/fixed_price/fixed_price_ui_helpers.dart` | 678 | 1 | 1 | Shared UI helper builders for fixed price wizard steps |
| 20 | `lib/screens/job_details/steps/ld_step_ui_helpers.dart` | 676 | 9 | 9 | Shared UI helper builders for Leak Detection wizard steps |
| 21 | `lib/models/fixed_price_submit_payload.dart` | 658 | 10 | 2 | DTO payload models & JSON serialization for fixed price quotes |
| 22 | `lib/screens/vehicle_check/vehile_check_screen.dart` | 651 | 3 | 6 | Vehicle check landing screen & historical vehicle inspection list |
| 23 | `lib/data/milestone_definitions.dart` | 595 | 1 | 0 | Static configuration definitions for badges, tiers, and milestones |
| 24 | `lib/screens/job_details/service/pillar_client.dart` | 590 | 1 | 0 | HTTP client for Pillar API compliance forms submission |
| 25 | `lib/screens/dashboard/goals_targets_screen.dart` | 588 | 6 | 7 | Target achievement and operative goal tracking screen |
| 26 | `lib/screens/job_details/widgets/pm_lead_wizard.dart` | 583 | 2 | 4 | Preventative Maintenance lead generator wizard |
| 27 | `lib/screens/job_details/widgets/ppm_lead_wizard.dart` | 564 | 2 | 5 | PPM lead generation dialog and steps |
| 28 | `lib/components/redeem_points/redeem_cards.dart` | 526 | 4 | 5 | Reward item card widgets for points catalog |
| 29 | `lib/components/dashboard/earnings_card.dart` | 516 | 3 | 3 | Dashboard earnings metric card with chart/breakdown |
| 30 | `lib/components/redeem_points/redeem_points_bottom_model.dart` | 503 | 5 | 4 | Reward redemption confirmation modal sheet |
| 31 | `lib/screens/chumley_ai/cubit/chumley_chat_cubit.dart` | 494 | 1 | 7 | Chumley AI chat business logic and streaming state cubit |
| 32 | `lib/models/appointment.dart` | 470 | 1 | 10 | Appointment DTO & status helpers |
| 33 | `lib/screens/job_details/widgets/job_site_card.dart` | 460 | 1 | 2 | Job site address, contact info & map launcher card |
| 34 | `lib/components/calendar/calendar_bottom_sheet.dart` | 431 | 2 | 10 | Calendar appointment selector modal sheet |
| 35 | `lib/screens/job_details/steps/ld_test_methods_step.dart` | 405 | 1 | 2 | Leak Detection testing methods step widget |

---

### Detailed Analysis of Files Above 1,000 LOC

#### 1. `lib/screens/forms/eicr_form_page.dart` (2,083 LOC)
* **Why it is large:** Implements a full 6-tab complex electrical inspection form (HSE Risk, CPS Report, Installation, Supply, Circuits, and Sign-off). Holds 40+ text controllers, photo slots, checkbox states, and large inline widget trees.
* **Cohesion:** Poor. Presentation, validation, controller instantiation, JSON payload construction, and photo capture are combined in a single state class.
* **Duplication:** Duplicates risk assessments, photo upload callbacks, and form control styling found across other forms.
* **Recommendation:** **Refactor in Phase 4.1**. Extract domain steps into `screens/forms/eicr/steps/` (`EicrCpsReportStep`, `EicrInstallationStep`, `EicrSupplyStep`, `EicrCircuitsStep`, `EicrSignoffStep`) while sharing `HseRiskSection` and `JobPhotoSlot`.

#### 2. `lib/screens/forms/damp_survey_form_page.dart` (1,834 LOC)
* **Why it is large:** Implements 9 inspection steps for Damp and Mould investigations: HSE, Customer Info, Visual Inspection, Sensor Readings, Property Details, Cause Diagnosis, Repair Works, Drying & Equipment, Sign-off.
* **Cohesion:** Poor. 50+ TextEditingControllers, inline meter reading cards, photo slots, and submission logic in one file.
* **Duplication:** Shares card structures, toggle buttons, photo capture slots, and signoff pads with EICR and Vent Hygiene.
* **Recommendation:** **Refactor in Phase 4.2**. Extract step components into `screens/forms/damp_survey/steps/`.

#### 3. `lib/screens/milestones/milestone_screen.dart` (1,440 LOC)
* **Why it is large:** Contains entire milestone category filtering, XP progress calculations, animated badge detail bottom sheets, celebratory confetti/dialog overlays, and achievement card grids.
* **Cohesion:** Medium. Highly coupled presentation and animation logic.
* **Duplication:** Multiple inline tier cards, badge tile builders, and bottom sheets.
* **Recommendation:** **Modularize in Phase 4.5**. Extract `MilestoneHeader`, `MilestoneCategoryCard`, `MilestoneBadgeTile`, and `MilestoneBadgeDetailSheet`.

#### 4. `lib/screens/forms/vent_hygiene_form_page.dart` (1,387 LOC)
* **Why it is large:** Contains 4 complex tabs for commercial kitchen/extract hygiene certificates, sub-operative lists, system access inspection, and cleaning checklists.
* **Cohesion:** Low. Manages dynamic list of sub-operatives (name, hours, rate), photo uploads, and payload construction.
* **Duplication:** Duplicates operative cost rows, photo attachment slots, and HSE cards.
* **Recommendation:** **Refactor in Phase 4.3**. Extract sub-operative management and inspection step cards.

#### 5. `lib/components/dashboard/dashboard_calendar.dart` (1,314 LOC)
* **Why it is large:** Contains calendar week/month matrix rendering, swipe gestures, appointment grouping, color-coded tag badges, empty states, and schedule list tiles.
* **Cohesion:** Mixed. Calendar view rendering is coupled with dashboard appointment business logic.
* **Duplication:** Duplicates day cell rendering and schedule card layouts that could leverage `AspectCalendarUtils`.
* **Recommendation:** **Decouple in Phase 4.6**. Separate appointment schedule presentation from calendar date math.

#### 6. `lib/screens/forms/ld_form_page.dart` (1,198 LOC)
* **Why it is large:** Legacy Leak Detection form containing 4 tabs (HSE, Findings, Methods, Sign-off).
* **Cohesion:** Low. Superseded by `on_site_wizard.dart` and `ld_step_*.dart` in Phase 2.
* **Status:** Legacy/fallback form. Maintained for route compatibility (`/ld-form`).

#### 7. `lib/screens/job_details/job_detail_page.dart` (1,101 LOC)
* **Why it is large:** Central controller and state manager for the entire job lifecycle. Reduced from 2,294 LOC in Phase 3.
* **Cohesion:** High. Responsibilities are now cleanly delegated to 6 child cards (`JobStatusHeader`, `JobScheduleCard`, `JobDetailsCard`, `JobSiteCard`, `JobRaiseJobsCard`, `JobActionsPanel`).
* **Status:** Refactored & cohesive. No further structural split needed in Phase 4.

#### 8. `lib/screens/vehicle_check/vehicle_form.dart` (1,071 LOC)
* **Why it is large:** 5-step vehicle inspection wizard (Fluids, Lights, Bodywork, Equipment, Declaration) with 12 photo slots and checklist cards.
* **Cohesion:** Medium. Clean wizard flow, but inline step definitions inflate file size.
* **Recommendation:** Retain wizard structure; standardize photo slots with shared media component.

---

## 3. Duplication Audit

### UI & Logic Duplication Matrix

| Location A | Location B | Duplication Description | Recommended Action | Confidence |
| :--- | :--- | :--- | :--- | :---: |
| `eicr_form_page.dart` | `damp_survey_form_page.dart` | Photo slots with gallery/camera picker & compression | Standardize on shared `JobPhotoSlot` / `ImageCompressor` | High |
| `eicr_form_page.dart` | `vent_hygiene_form_page.dart` | HSE hazard checklist & risk assessment form | Already uses shared `HseRiskSection` (verify consistency) | High |
| `damp_survey_form_page.dart` | `vent_hygiene_form_page.dart` | Signature pad capture & customer declaration cards | Reuse shared `AspectSignatureCard` / `LdDeclarationTile` | High |
| `eicr_form_page.dart` | `damp_survey_form_page.dart` | Section cards with collapsible headers & icons | Standardize on `LdSectionCard` / `FormSectionCard` | High |
| `milestone_screen.dart` | `redeem_points.dart` | Operative XP / points balance badge & tier icons | Extract shared `PointsBalanceBadge` | Medium |
| `dashboard_calendar.dart` | `calendar_bottom_sheet.dart` | Date calculations, week generator & month formatting | Share `AspectCalendarUtils` | High |
| `fixed_price_ui_helpers.dart`| `ld_step_ui_helpers.dart` | Currency input field & unit price calculator row | Extract `AspectCurrencyField` to `shared/widgets/forms/` | High |

---

## 4. Form Architecture Audit

### Form Comparison Matrix

| Form | LOC | Steps/Tabs | State Management | Photo Slots | Shared Components Used | Status / Target |
| :--- | --: | :--- | :--- | :---: | :--- | :--- |
| **`eicr_form_page.dart`** | 2,083 | 6 tabs | `StatefulWidget` + Controllers | 6+ | `HseRiskSection`, `JobPhotoSlot` | Active (Phase 4.1 Target) |
| **`damp_survey_form_page.dart`** | 1,834 | 9 steps | `StatefulWidget` + Controllers | 8+ | `HseRiskSection`, `JobPhotoSlot` | Active (Phase 4.2 Target) |
| **`vent_hygiene_form_page.dart`** | 1,387 | 4 tabs | `StatefulWidget` + Controllers | 6+ | `HseRiskSection`, `JobPhotoSlot` | Active (Phase 4.3 Target) |
| **`ld_form_page.dart`** | 1,198 | 4 tabs | `StatefulWidget` + Controllers | 4+ | `HseRiskSection` | Legacy fallback (Active route) |
| **`vehicle_form.dart`** | 1,071 | 5 steps | `StatefulWidget` + Wizard State | 12 | `JobPhotoSlot`, `AspectStepProgressBar` | Active compliance form |
| **`on_site_wizard.dart`** | 1,064 | 4 steps | `LdFormStateNotifier` (ValueNotifier) | 8+ | `LdSectionCard`, `LdStepUiHelpers` | Refactored Phase 2 |
| **`fixed_price_page.dart`** | 942 | 4 steps | `FixedPriceController` (ChangeNotifier) | 4 | `FixedPriceUiHelpers`, `AspectStepProgressBar` | Refactored Phase 2 |

---

## 5. Photo & Media Architecture

### Investigation Findings:
1. **Camera / Gallery Picker:** `image_picker` package is accessed primarily through `JobPhotoSlot` (`lib/widgets/job/job_photo_slot.dart`) and helper utilities in `lib/utils/image_compressor.dart`.
2. **Compression:** `ImageCompressor.compressFile()` compresses images to target dimensions and quality before Base64 encoding or upload.
3. **Storage & Serialization:** Forms serialize photos into JSON payloads as Base64 strings or post them via multipart requests in `PillarClient` / `JobService`.
4. **Conclusion:** No fragmented 3rd-party image libraries exist. `JobPhotoSlot` is the established, proven UI component across `eicr_form_page.dart`, `vehicle_form.dart`, and `on_site_wizard.dart`. We will standardize all form refactorings on `JobPhotoSlot` and `ImageCompressor`.

---

## 6. Form Field Architecture

### Existing Shared Components vs Candidates for Promotion:
* **`HseRiskSection`** (`lib/screens/forms/widgets/hse_risk_section.dart`): Robust, standardized HSE risk assessment widget used across compliance forms.
* **`JobPhotoSlot`** (`lib/widgets/job/job_photo_slot.dart`): Standard photo capture/preview slot with delete/replace functionality.
* **`AspectStepProgressBar`** (`lib/widgets/aspect_step_progress_bar.dart`): Wizard step progress indicator.
* **`LdSectionCard`** (`lib/screens/job_details/steps/ld_step_ui_helpers.dart`): Styled card container with header icon and border.
* **`AspectSignaturePad`** / Signature dialogs: Canvas signature capture with clear/save actions.

---

## 7. State Management Audit

* **Form Controllers:** Complex wizard forms (`EicrFormPage`, `DampSurveyFormPage`, `VentHygieneFormPage`) own their `TextEditingController` instances within their `State` classes.
* **Validation:** Step-level validation occurs before tab switching or submit (`_validateCurrentStep()`).
* **Drafts & Persistence:** Forms hold state in memory and submit directly to `PillarClient` / API on final step completion.
* **Separation of Concerns:** Forms currently mix UI widget layout with JSON payload mapping. Extracting step widgets will cleanly separate step layout from the form-level submit coordinator.

---

## 8. Controller & Resource Lifecycle Audit

| File | Resource | Created In | Disposed In | Leak Risk |
| :--- | :--- | :--- | :--- | :---: |
| `eicr_form_page.dart` | 40+ `TextEditingController`s | `initState()` | `dispose()` | Low (Disposed in batch) |
| `damp_survey_form_page.dart` | 50+ `TextEditingController`s | `initState()` | `dispose()` | Low (Disposed in batch) |
| `vent_hygiene_form_page.dart` | Dynamic `TextEditingController`s (Sub-operatives) | `_addSubOperative()` | Missing explicit dispose on removal | **Medium** (Fixed during Phase 4.3) |
| `milestone_screen.dart` | `AnimationController` & `TabController` | `initState()` | `dispose()` | Low |
| `dashboard_calendar.dart` | `ScrollController` & `PageController` | `initState()` | `dispose()` | Low |
| `chumley_chat_cubit.dart` | `StreamSubscription` (WebSocket) | `connect()` | `close()` | Low (Verified Phase 3) |

---

## 9. API & Network Audit

* **No API calls inside `build()` methods:** All network requests are dispatched from event handlers (`onPressed`, `initState`, Cubit events).
* **Payload Serialization:** Large form payloads are serialized via dedicated methods (`_buildPayload()`).
* **Token Handling:** Centralized token caching in `AuthService` (optimized in Phase 1) prevents redundant token decodes.

---

## 10. Performance Audit

* **Rendering:** Large form files previously triggered rebuilds of all 6–9 tabs when typing in a single field. Decomposing tabs into dedicated sub-widgets isolates widget subtrees.
* **Memory:** `ImageCompressor` ensures images taken via camera do not exhaust heap memory on lower-end Android devices.
* **List Virtualization:** `ListView.builder` is utilized in appointment lists, milestone badge grids, and enquiry feeds.

---

## 11. Dead & Legacy Code Audit

* **`ld_form_page.dart`:** Legacy fallback form. Kept for route safety.
* **`milestone_definitions.dart`:** Static registry of all badges and milestone criteria. Active.
* **Zero orphaned imports or broken routes detected.**

---

## 12. Dependency Audit

* `pubspec.yaml` dependencies reviewed. Core libraries: `flutter_bloc`, `dio`, `shared_preferences`, `image_picker`, `image`, `intl`, `web_socket_channel`.
* No unused or conflicting packages found.

---

## 13. Folder Structure Audit

* **Form domain locations:** All forms reside in `lib/screens/forms/` with reusable widgets in `lib/screens/forms/widgets/` and `lib/widgets/job/`.
* Clean separation between `lib/core/`, `lib/models/`, `lib/services/`, `lib/screens/`, and `lib/widgets/`.

---

## 14. Form-Specific Architectural Review

For our target forms (`eicr`, `damp_survey`, `vent_hygiene`):
* **Modular step structure:**
  ```text
  lib/screens/forms/eicr/
  ├── eicr_form_page.dart
  └── steps/
      ├── eicr_cps_report_step.dart
      ├── eicr_installation_step.dart
      ├── eicr_supply_step.dart
      ├── eicr_circuits_step.dart
      └── eicr_signoff_step.dart
  ```
  ```text
  lib/screens/forms/damp_survey/
  ├── damp_survey_form_page.dart
  └── steps/
      ├── damp_info_step.dart
      ├── damp_visual_step.dart
      ├── damp_repair_step.dart
      ├── damp_drying_step.dart
      └── damp_conclusion_step.dart
  ```
  ```text
  lib/screens/forms/vent_hygiene/
  ├── vent_hygiene_form_page.dart
  └── steps/
      ├── vent_operatives_step.dart
      ├── vent_system_step.dart
      └── vent_certificate_step.dart
  ```

---

## 15. Top 20 Phase 4 Problems & Action Plan

| Priority | File | Problem | Impact | Evidence | Recommended Action |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **P1** | `eicr_form_page.dart` | 2,083 LOC monolithic 6-tab form | High cognitive load, full-tree rebuilds | Rank 1 file | Modularize into `eicr/steps/` (Phase 4.1) |
| **P1** | `damp_survey_form_page.dart` | 1,834 LOC monolithic 9-step form | Hard to maintain, inline controllers | Rank 2 file | Modularize into `damp_survey/steps/` (Phase 4.2) |
| **P1** | `vent_hygiene_form_page.dart` | 1,387 LOC monolithic 4-tab form | Sub-operative controller lifecycle risk | Rank 4 file | Modularize into `vent_hygiene/steps/` (Phase 4.3) |
| **P2** | `milestone_screen.dart` | 1,440 LOC monolithic gamification screen | High presentation complexity | Rank 3 file | Modularize badge cards & sheets (Phase 4.5) |
| **P2** | `dashboard_calendar.dart` | 1,314 LOC calendar rendering + schedule | Coupled calendar math & job UI | Rank 5 file | Decouple appointment schedule views (Phase 4.6) |
| **P2** | `vent_hygiene_form_page.dart` | Dynamic sub-operative text controller leak risk | Memory leak on row deletion | Controller list without disposal on delete | Ensure dispose on sub-operative remove |
| **P2** | `eicr_form_page.dart` | Inline photo picker widgets | Code duplication | 6+ photo slots inlined | Use standard `JobPhotoSlot` |
| **P2** | `damp_survey_form_page.dart` | Inline meter reading cards | Duplicated card structure | 8+ reading sections | Extract shared meter widget |
| **P3** | `milestone_screen.dart` | Inline celebration & confetti dialogs | Bloated widget tree | 200+ LOC overlay builders | Extract celebration modal |
| **P3** | `dashboard_calendar.dart` | Inline appointment item card builders | Duplicated schedule cards | Multiple list tile builders | Extract `DashboardScheduleItem` |
| **P3** | `forms/widgets/` | Missing unified export barrel for form steps | Inconsistent imports across forms | Ad-hoc relative imports | Create clean exports |
| **P3** | `vehicle_form.dart` | Inline vehicle check photo grid | Large file size (1,071 LOC) | 12 inline slots | Standardize with `JobPhotoSlot` |

---

## Baseline Conclusion
The codebase is healthy (0 analyzer issues, 85/85 tests passing). Phase 4 will target the remaining large form monoliths (`eicr`, `damp_survey`, `vent_hygiene`), `milestone_screen.dart`, and `dashboard_calendar.dart` to establish a modular, clean, and maintainable forms and UI architecture.
