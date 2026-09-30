# Phase 5 — Baseline Architecture & Codebase Quality Audit

**Project:** Chumley Navigator (Aspect Field Service Mobile Application)  
**Phase:** 5 — Architecture Hardening, Final Refactoring & Codebase Quality Audit  
**Date:** September 25, 2026  
**Status:** Initial Baseline Recorded (Pre-Implementation)  
**Baseline Verification:** `flutter analyze` → 0 issues, `flutter test` → 85/85 passed, `dart format` → 100% compliant.

---

## 1. Repository Snapshot

| Parameter | Baseline Value |
| :--- | :--- |
| **Git Branch** | `code-optimise` |
| **Git Status** | Working tree contains Phase 1–4 verified changes |
| **Flutter Version** | 3.38.4 (Channel stable) |
| **Dart SDK Version** | 3.10.3 (macos_arm64) |
| **Total Dart Source Files (`lib/`)** | 255 |
| **Total Lines of Code (`lib/`)** | 55,747 LOC |
| **Test Suite Baseline** | 85 passed / 85 total (100% passing) |
| **Analyzer Issues** | 0 issues (0 errors, 0 warnings, 0 lints) |
| **Dart Formatting** | 100% compliant across `lib/` and `test/` |
| **State Management Foundation** | Flutter BLoC / Cubit + `ValueNotifier` / `ListenableBuilder` |
| **Networking Layer** | Dio HTTP client with `ApiClient` wrapper + Azure AD OAuth / Firebase |
| **Key Architectural Layers** | `lib/core/`, `lib/models/`, `lib/screens/`, `lib/components/`, `lib/pillar/`, `lib/widgets/` |

---

## 2. File-Size Audit

### Global Size Distribution
- **Files > 2,000 LOC:** 0
- **Files > 1,500 LOC:** 0
- **Files > 1,000 LOC:** 5
- **Files > 500 LOC:** 30

### Top 30 Largest Dart Files Ranking

| Rank | File Path | LOC | Primary Responsibility | Cohesive? | Recommended Action |
| ---: | :--- | ---: | :--- | :---: | :--- |
| 1 | `lib/screens/forms/ld_form_page.dart` | 1,198 | Leak Detection Form (Tabs, HSE, Information, Customer, Visual) | Partial | **Phase 5A:** Modularize into `ld/steps/` and `ld_form_helpers.dart`. |
| 2 | `lib/screens/job_details/job_detail_page.dart` | 1,101 | Reactive Job Hub (Status, Routing, Actions, Map, Panels) | Yes | **Keep:** Already modularized into cards/panels in Phase 3. Cohesive orchestrator. |
| 3 | `lib/screens/vehicle_check/vehicle_form.dart` | 1,071 | Vehicle Inspection Form (Checklist, Camera, Example Photos, Submitted Screen) | Partial | **Phase 5B:** Modularize into `vehicle_check/steps/` and extract `_SubmittedScreen`. |
| 4 | `lib/screens/job_details/on_site_wizard.dart` | 1,064 | 12-Step On-Site Form Orchestrator & Draft Store | Yes | **Keep:** Modularized in Phase 2 with step routing and state machine. |
| 5 | `lib/screens/forms/damp_survey_form_page.dart` | 1,037 | Damp Survey Form Orchestrator & State Management | Yes | **Keep:** Modularized in Phase 4 into 8 isolated steps; remaining code is pure state/payload. |
| 6 | `lib/screens/job_details/fixed_price_page.dart` | 942 | Fixed-Price Quotation Wizard & Breakdown | Yes | **Keep:** Modularized in Phase 2 into dedicated pricing/breakdown steps. |
| 7 | `lib/screens/job_details/ppm_job_detail_page.dart` | 895 | Planned Maintenance Detail Hub | Yes | **Keep:** Domain-specific status routing. |
| 8 | `lib/screens/job/follow_on_page.dart` | 856 | Follow-On Attendance & Referral Router | Yes | **Keep:** Modularized in Phase 3. |
| 9 | `lib/screens/enquiries/enquiries_screen.dart` | 851 | Customer Enquiries Hub & Status Tabs | Yes | **Keep:** Cohesive screen. |
| 10 | `lib/screens/forms/vent_hygiene_form_page.dart` | 829 | Duct / Vent Inspection Orchestrator | Yes | **Keep:** Modularized in Phase 4 with sub-operative models. |
| 11 | `lib/screens/leaderboard/leaderboard_screen.dart` | 818 | Gamification Leaderboard & Rankings | Yes | **Keep:** Cohesive tabbed rankings. |
| 12 | `lib/screens/dashboard/earnings_detail_screen.dart` | 765 | Earnings Breakdown & Historical Pay | Yes | **Keep:** Cohesive financial analytics screen. |
| 13 | `lib/screens/forms/eicr_form_page.dart` | 751 | Electrical EICR Form Orchestrator | Yes | **Keep:** Reduced from 2,083 LOC in Phase 4. |
| 14 | `lib/screens/absences/absences_screen.dart` | 733 | Holiday / Absence Manager | Yes | **Keep:** Calendar & request sheet. |
| 15 | `lib/screens/profile/profile_screen.dart` | 689 | Engineer Profile & Skill Overview | Yes | **Keep:** Profile management. |
| 16 | `lib/screens/redeemPoints/redeem_points.dart` | 688 | Points Marketplace & Rewards | Yes | **Keep:** Store catalog. |
| 17 | `lib/screens/job_details/fixed_price/fixed_price_ui_helpers.dart` | 678 | Fixed-Price UI Utilities & Formatting | Yes | **Keep:** Shared utility. |
| 18 | `lib/screens/job_details/steps/ld_step_ui_helpers.dart` | 676 | LD Form UI Utilities & Layouts | Yes | **Keep:** Shared utility. |
| 19 | `lib/models/fixed_price_submit_payload.dart` | 658 | Fixed Price JSON Serialization | Yes | **Keep:** Pure data model. |
| 20 | `lib/screens/vehicle_check/vehile_check_screen.dart` | 651 | Daily Vehicle Inspection Launcher | Yes | **Phase 5B:** Minor cleanup with vehicle cards. |
| 21 | `lib/data/milestone_definitions.dart` | 595 | Gamification Static Milestone Data | Yes | **Keep:** Static definitions. |
| 22 | `lib/screens/job_details/service/pillar_client.dart` | 590 | Pillar Backend Client Integration | Yes | **Keep:** Network service. |
| 23 | `lib/screens/dashboard/goals_targets_screen.dart` | 588 | Engineer Goals & KPI Targets | Yes | **Keep:** Dashboard sub-screen. |
| 24 | `lib/screens/job_details/widgets/pm_lead_wizard.dart` | 583 | Preventive Maintenance Lead Wizard | Yes | **Keep:** Multi-step wizard. |
| 25 | `lib/screens/job_details/widgets/ppm_lead_wizard.dart` | 564 | PPM Lead Wizard | Yes | **Keep:** Multi-step wizard. |
| 26 | `lib/screens/milestones/milestone_screen.dart` | 558 | Gamification Milestones Screen | Yes | **Keep:** Reduced from 1,441 LOC in Phase 4. |
| 27 | `lib/components/redeem_points/redeem_cards.dart` | 526 | Points Reward Cards | Yes | **Keep:** Presentation widgets. |
| 28 | `lib/components/dashboard/earnings_card.dart` | 516 | Dashboard Earnings Widget | Yes | **Keep:** Dashboard card. |
| 29 | `lib/components/redeem_points/redeem_points_bottom_model.dart` | 503 | Points Redemption Sheet | Yes | **Keep:** Modal sheet. |
| 30 | `lib/components/dashboard/appointment_schedule_card.dart` | 502 | Decoupled Schedule Job Card | Yes | **Keep:** Extracted in Phase 4. |

---

## 3. Architecture Audit

### Feature Boundaries & Domain Organization
- **Presentation Separation:** Major forms (EICR, Damp, Vent Hygiene) cleanly decouple page state orchestration from individual step presentation.
- **Service Layering:** Services reside under `lib/screens/<feature>/service/` or `lib/pillar/`. Network communication consistently leverages `ApiClient` and `JobsRepository`.
- **Serialization Isolation:** Models reside in `lib/models/` and handle JSON serialization cleanly without embedded presentation code.

---

## 4. LD Form Architecture Audit

**Target:** `lib/screens/forms/ld_form_page.dart` (1,198 LOC)

### Audit Findings:
1. **Tabs & Steps:**
   - Tab 0: Risk & HSE (`HseRiskSection`)
   - Tab 1: Information (LD Form Name, Work Order readonly, PDF URL, Service Appointment search dropdown)
   - Tab 2: Customer Details (Operative Name search dropdown, Front of Property image description, Survey Date & Time pickers)
   - Tab 3: Compulsory Visual Inspection (Visual Image Description, Findings, Weather dropdown, Weather other details)
2. **State & Controllers:**
   - 8 `TextEditingController`s (`_formNameController`, `_pdfUrlController`, `_frontOfPropertyController`, `_visualImageDescController`, `_visualFindingsController`, `_weatherOtherController`, `_appointmentSearchController`, `_operativeSearchController`)
   - `HseRiskFormController`
   - `TabController`, `ScrollController`, `ValueNotifier<double>`
3. **Form Helpers & Pickers:**
   - Inline date/time modal sheets (`_pickSurveyDate`, `_pickSurveyTime`)
   - Inline custom text fields and dropdowns (`_labeledField`, `_textField`, `_expandableField`, `_readOnlyField`, `_pickerButton`, `_simpleDropdown`, `_searchableDropdown`)
4. **Recommended Modularization (Phase 5A):**
   - Extract `LdInformationTab`, `LdCustomerTab`, `LdVisualTab` into `lib/screens/forms/ld/steps/`.
   - Extract `LdFormHelpers` into `lib/screens/forms/ld/widgets/ld_form_helpers.dart`.
   - Keep `LdFormPage` as the public orchestrator for draft persistence (`saveFormDraft`, `fetchFormDraft`) and submission (`submitForm`).

---

## 5. Vehicle Check Architecture Audit

**Target:** `lib/screens/vehicle_check/vehicle_form.dart` (1,071 LOC) & `vehile_check_screen.dart` (651 LOC)

### Audit Findings:
1. **Inspection Steps & Areas:**
   - 6 inspection areas defined in `vcrStepData`: Front, Driver Side, Passenger Side, Rear, Interior & Dashboard, Tyres & Wheels.
   - Dynamic example photo fetching via `VcrExamplesCubit`.
2. **Inline Presentation Bloat:**
   - `_SubmittedScreen` (320+ LOC) is inlined at the bottom of `vehicle_form.dart`.
   - `_ImageSourceButton` and source selector modal inlined.
3. **Recommended Modularization (Phase 5B):**
   - Extract `VcrSubmittedScreen` into `lib/screens/vehicle_check/widgets/vcr_submitted_screen.dart`.
   - Extract `VcrImageSourceModal` into `lib/screens/vehicle_check/widgets/vcr_image_source_modal.dart`.
   - Extract `VcrExamplesSection` into `lib/screens/vehicle_check/widgets/vcr_examples_section.dart`.

---

## 6. Photo & Media Pipeline Audit

### Repository Photo Upload Matrix

| Feature / Form | Photo Capture Method | Compression Mechanism | Upload Mechanism | Backend Endpoint | Storage Strategy | Error Handling & Retries |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Visit Forms & OnSiteWizard** | `JobPhotoSlot` / `ImagePicker` | `PhotoPipelineService` (max 900px, quality 65, target ~55KB) | `JobsRepository.submitForm` / `PillarClient` (Azure SAS direct upload) | `/api/form-submissions` + SAS Blob URL | Azure Blob Storage | SAS fallback, retry on 403 SAS expiration |
| **Vehicle Inspection (VCR)** | `VcrCaptureSlot` / `ImagePicker` | `ImageCompressor` (max 1600px, quality 70) | `VehicleCheckApiService.submitVcrInspection` | `/api/vcr/submit` (Multipart `FormData`) | Backend multipart files array | Size check (<4MB), `VehicleCheckApiException` banner |
| **Enquiries** | `ImagePicker` | Direct file capture | Multipart / JSON upload | `/api/enquiries` | Backend file storage | Standard HTTP error alerts |
| **Chumley AI Chat** | File attachment | Direct bytes / base64 | WebSocket / Multipart API | `/api/chat/attachments` | Temporary session cache | Socket error listener |

### Critical Finding:
- **Two Distinct Backend Upload Paradigms Exist:**
  1. *Azure SAS Upload:* Form compliance endpoints expect client-side Azure SAS pre-signed blob uploads followed by URL submission.
  2. *Multipart FormData Upload:* Vehicle Check and Enquiries post raw multipart payloads directly to REST endpoints.
- **Architectural Decision:** Do NOT force both into a rigid single class that violates backend contract differences. Instead, harden `ImageCompressor` to avoid unnecessary byte-decoding in memory, and standardize photo preparation routines.

---

## 7. Memory & Image Performance Audit

1. **`ImageCompressor.compressImage` Memory Spikes:**
   - *Current Implementation:* Calls `final bytes = await file.readAsBytes();` and `decodeImageFromList(bytes)` in Dart VM memory to read dimensions before passing to native compressor.
   - *Fix in Phase 5F:* Pass image directly to `FlutterImageCompress.compressAndGetFile` with `minWidth: targetLongestEdge, minHeight: targetLongestEdge`, eliminating full raw bitmap memory allocations in Dart heap.
2. **Photo Caching & Thumbnails:**
   - `JobPhotoSlot` and `VcrCaptureSlot` display thumbnails using `Image.file(File(path), width: ..., height: ..., fit: BoxFit.cover)`. Adding `cacheWidth` and `cacheHeight` prevents high-resolution decoding into the Flutter image cache.

---

## 8. Resource Lifecycle Audit Table

| File | Resource | Creation Location | Disposal Verification | Leak Risk |
| :--- | :--- | :--- | :--- | :---: |
| `ld_form_page.dart` | 8 `TextEditingController`s | `_LdFormPageState` | `dispose()` | **None** |
| `ld_form_page.dart` | `TabController`, `ScrollController`, `ValueNotifier` | `initState()` | `dispose()` | **None** |
| `vehile_check_screen.dart` | `VehicleCheckCubit`, `TextEditingController` | `initState()` | `dispose()` | **None** |
| `vehicle_form.dart` | `ImagePicker` | Stateful member | Garbage collected | **None** |
| `on_site_wizard.dart` | 12 `TextEditingController`s | Step lifecycle | `dispose()` | **None** |
| `eicr_form_page.dart` | 40+ `TextEditingController`s | `initState()` | `dispose()` | **None** |
| `damp_survey_form_page.dart` | 25+ `TextEditingController`s | `initState()` | `dispose()` | **None** |
| `vent_hygiene_form_page.dart` | `List<SubOperativeControllers>` | Dynamic User Action | `dispose()` & list remove | **None** |

---

## 9. Form State Management Audit

All major forms follow a consistent unidirectional data flow:
```
Parent StatefulWidget / Cubit
  ├── Owns State, Controllers & Draft Persistence
  └── Dispatches values to Domain Step Widgets (Stateless / Pure UI)
        └── Step Widgets trigger Callbacks (e.g., onChanged, onDatePicked)
```
- EICR, Damp Survey, and Vent Hygiene follow this standard.
- LD Form and Vehicle Check will be updated to conform to this exact architecture.

---

## 10. Testing Audit

- **Current Status:** 85/85 tests passing.
- **Gaps Identified for Phase 5E Expansion:**
  - Need isolated unit tests for `ImageCompressor` memory-safe compression.
  - Need widget tests for `VcrCaptureSlot` and `LdInformationTab`.
  - Need tests for EICR circuit model validation.

---

## 11. Dependency Audit

- `pubspec.yaml` contains 32 production dependencies and 2 dev dependencies.
- All packages (`flutter_bloc`, `dio`, `flutter_image_compress`, `flutter_screenutil`, `dropdown_button2`, `lucide_icons_flutter`, `permission_handler`) are actively used across core journeys.
- No obsolete or duplicate third-party packages identified.

---

## 12. Remaining Large Files Classification

| File | LOC | Category | Action |
| :--- | ---: | :---: | :--- |
| `lib/screens/forms/ld_form_page.dart` | 1,198 | **C — Modularize** | Extract steps into `ld/steps/` |
| `lib/screens/job_details/job_detail_page.dart` | 1,101 | **A — Keep** | Cohesive orchestrator |
| `lib/screens/vehicle_check/vehicle_form.dart` | 1,071 | **C — Modularize** | Extract submitted screen, modals, and examples |
| `lib/screens/job_details/on_site_wizard.dart` | 1,064 | **A — Keep** | Cohesive wizard orchestrator |
| `lib/screens/forms/damp_survey_form_page.dart` | 1,037 | **A — Keep** | State & submission orchestrator |

---

## 13. CI / Quality Gates

- Existing scripts: `flutter analyze`, `flutter test`, `dart format`.
- CI Quality Gate: Create a lightweight CI script / verification script `scripts/ci_quality_gate.sh` that validates format, analyzer, tests, and flags any un-modularized god-files (>1,200 LOC).

---

## 14. Implementation Plan (Phases 5A to 5I)

```
Phase 5A: Modularize LD Form (lib/screens/forms/ld/)
Phase 5B: Modularize Vehicle Check (lib/screens/vehicle_check/)
Phase 5C: Consolidate Photo/Media Pipeline & Harden ImageCompressor
Phase 5D: Resource Lifecycle Verification
Phase 5E: Expand Form & Widget Unit Tests
Phase 5F: Performance & Image Memory Optimization
Phase 5G: Dependency & Dead Code Hygiene
Phase 5H: CI Quality Gates Script
Phase 5I: Final Architecture Verification & PHASE_5_FINAL_AUDIT.md
```
