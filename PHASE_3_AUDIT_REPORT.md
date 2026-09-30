# Phase 3 Audit Report: Core Journey & Job Detail Architecture Refactor

**Project:** Aspect Chumley Navigator (Flutter)  
**Phase:** Phase 3 (Core Journey & Job Detail Architecture Refactor)  
**Date:** September 2026  
**Status:** Completed & Verified  

---

## Executive Summary

Phase 3 focused on decomposing large, multi-responsibility stateful screens in the core job journey into focused presentation components, formalizing lifecycle state ownership, consolidating post-submit and follow-on flows, modularizing Chumley AI chat while isolating websocket lifecycles, and reviewing legacy form systems.

### Key Results:
- **`job_detail_page.dart`**: Reduced from **2,294 lines** to **1,102 lines** (**-52.0%**), transforming into an orchestration layer with 6 extracted widgets.
- **`post_submit_flow.dart`**: Reduced from **1,218 lines** to **100 lines** (**-91.8%**), decomposed into 4 modular phase screens and a reusable status progress timeline.
- **`follow_on_page.dart`**: Reduced from **1,076 lines** to **856 lines** (**-20.4%**) with shared attendance and referral modal sheets.
- **`chumley_chat.dart`**: Reduced from **1,407 lines** to **107 lines** (**-92.4%**), isolating Insights, AI Chat, and People Chats into dedicated tab views with centralized socket lifecycle ownership.
- **Zero Regressions**: **85/85 tests passing**, **0 analyzer issues**, full code formatting applied (`dart format`).

---

## 1. Job Detail Architecture

The previous monolithic `JobDetailPage` handled multiple lifecycle phases, map rendering, location streams, geocoding fallback, customer details, and bottom action sliders in a single 2,294-line file. It was restructured into an orchestration layer composing focused, presentation-only components.

```text
lib/screens/job_details/
├── job_detail_page.dart                     <-- Orchestrator & single source of truth
├── post_submit_flow.dart                    <-- Post-submit phase router
│
├── widgets/
│   ├── job_status_header.dart               <-- Status chip, job type chips, progress dots
│   ├── job_schedule_card.dart               <-- Date, time window, slot badge
│   ├── job_details_card.dart                <-- Key-value appointment details & description
│   ├── job_site_card.dart                   <-- Map preview, route info, geocoding overlay, navigation
│   ├── job_raise_jobs_card.dart             <-- On-site action tiles (FP, Reactive, Multi FP)
│   └── job_actions_panel.dart               <-- Slide-to-advance action slider & skip-ahead chips
│
├── modals/
│   ├── hourly_attendance_sheet.dart         <-- Modal sheet for urgent reactive/hourly attendance
│   └── referral_modal_sheet.dart            <-- Modal sheet for cross-trade referral enquiries
│
└── post_submit/
    ├── job_completed_screen.dart            <-- Post-submit completion view
    ├── follow_on_screen.dart                <-- Follow-on options selector
    ├── job_closed_screen.dart               <-- Closed job summary
    ├── visit_complete_screen.dart           <-- Visit complete hero card with copy & next steps
    └── status_progress_timeline.dart        <-- 6-step lifecycle timeline
```

---

## 2. Job Lifecycle State Management

Lifecycle state transitions are maintained through a single source of truth in `JobDetailPage`:

1. **State Ownership**:
   - `_currentStatus` (`Dispatched`, `Received`, `In Transit`, `On site`, `Job Closure`, `Visit Complete`)
   - `_allowedNextStatuses`: List of permitted next status transitions from API.
   - `_postSubmitPhase`: Handles post-submit transitions (`jobCompleted` → `followOn` → `jobClosed` → `visitComplete`).
   - `_formsDismissed`: Persisted locally via `FormDraftStore` so dismissing forms to inspect details doesn't reset draft state.
   - `_onSiteWizardSubmitted`: Gate check ensuring mandatory 12-step wizard sign-off prior to advancing to `Job Closure`.

2. **Lifecycle Flow**:
   ```text
   Dispatched / Received
          ↓
      In Transit
          ↓
       On Site ────(Incomplete forms)───► OnSiteWizard (12-step sign-off)
          ↓                                     │
      Job Closure ◄─────────────────────────────┘
          ↓
      Follow-On (Fixed Price / Hourly Attendance / Referral)
          ↓
      Job Closed
          ↓
    Visit Complete
   ```

---

## 3. Extracted Components & Responsibilities

| Component | Responsibility | Consumer(s) |
|---|---|---|
| `JobStatusHeader` | Renders status chip, job number, status title, job category tags, and progress step dots | `JobDetailPage` |
| `JobScheduleCard` | Displays appointment date, scheduled start/end window, and slot duration pill | `JobDetailPage` |
| `JobDetailsCard` | Renders Appointment ID, Type, Customer, and highlighted description | `JobDetailPage` |
| `JobSiteCard` | Customer contact, address, embedded FlutterMap preview, GPS/geocoding loading indicator, and route distance/ETA | `JobDetailPage` |
| `JobRaiseJobsCard` | On-site action card for raising Fixed Price, reactive jobs, or multiple quotes with permission gating | `JobDetailPage` |
| `JobActionsPanel` | Bottom action container with `CallStyleActionSlider`, skip-ahead buttons, and loading spinner | `JobDetailPage` |
| `HourlyAttendanceSheet` | Bottom sheet for submitting hourly attendance enquiries via `PillarClient.raiseEnquiry` | `FollowOnPage`, `PostSubmitFlow` |
| `ReferralModalSheet` | Bottom sheet for submitting trade referral rewards via `PillarClient.raiseEnquiry` | `FollowOnPage`, `PostSubmitFlow` |
| `JobCompletedScreen` | Presentation screen for job completion after form sign-off | `PostSubmitFlow` |
| `FollowOnScreen` | Presentation screen displaying follow-on options (FP quote, attendance, referral, or none) | `PostSubmitFlow` |
| `JobClosedScreen` | Presentation screen for closed job state prior to visit completion | `PostSubmitFlow` |
| `VisitCompleteScreen` | Visit complete confirmation with clipboard copy and 'What happens next' timeline | `PostSubmitFlow` |
| `StatusProgressTimeline` | 6-step lifecycle timeline (Dispatched to Visit Complete) | `JobCompletedScreen`, `JobClosedScreen` |
| `ChatBubble` | Reusable styled chat bubble for user and AI/peer messages | `AiChatTabView`, `ChumleyThreadView` |
| `ChatComposer` | Multi-line text composer with pill border and submit button | `AiChatTabView`, `ChumleyThreadView` |
| `ChatErrorBanner` | Dismissible warning/error banner | `AiChatTabView`, `PeopleChatsTabView` |
| `ChatHeader` & `ChatTabBar` | Brand navigation header and tab bar switcher with unread badge counter | `ChumleyChatScreen` |
| `InsightsTabView` | Renders today's headlines, revenue/sales, capacity, and cash KPIs | `ChumleyChatScreen` |
| `AiChatTabView` | Prompt cards, conversation history picker, AI message list, and follow-up chips | `ChumleyChatScreen` |
| `PeopleChatsTabView` | DM conversations list, new chat dialog, and active socket thread viewer | `ChumleyChatScreen` |

---

## 4. Post-Submit & Follow-on Consolidation Matrix

| Behavior | `post_submit_flow.dart` | `follow_on_page.dart` | Consolidated Architecture |
|---|---|---|---|
| **Attendance Enquiry** | Callbacks | Inline Bottom Sheet | Shared `HourlyAttendanceSheet` |
| **Trade Referral** | Callbacks | Inline Bottom Sheet | Shared `ReferralModalSheet` |
| **Fixed Price Trigger** | Callback to `FixedPricePage` | Routes to `FixedPricePage` with `FixedPriceJobContext` | Reusable route with `FixedPriceJobContext` |
| **Timeline Visualization** | `_StatusProgressTimeline` | `_closedLadder` | Modular `StatusProgressTimeline` component |
| **Visit Complete Confirmation** | `_VisitCompleteScreen` | `_VisitCompleteView` | Reusable `VisitCompleteScreen` |

---

## 5. Chumley AI Modularization & Socket Lifecycle

- `ChumleyChatCubit` retains sole ownership over the Socket lifecycle: connection, subscription, reconnection upon app resume, and disposal.
- The UI layer (`chumley_chat.dart`) is now a high-level router that swaps cleanly between:
  - `InsightsTabView`
  - `AiChatTabView`
  - `PeopleChatsTabView`
- Extracted `ChatBubble`, `ChatComposer`, `ChatErrorBanner`, and `ChatHeader` ensure presentation concerns do not re-trigger socket connections or leaks.

---

## 6. Legacy vs Active Code Review

- **`ld_form_page.dart`**:
  - **Reachable**: No (not referenced by any route, navigation path, deep link, or test).
  - **Functionality**: Prototype 4-tab form using placeholder string arrays.
  - **Active Replacement**: `OnSiteWizard` (12 steps, active drafts, multi-photo slots, offline storage, CP12/WORKS/LD dynamic kind detection).
  - **Status**: Kept intact for audit trail; marked obsolete in architecture map.

- **`eicr_form_page.dart`**:
  - **Reachable**: Yes, referenced by `PpmJobDetailPage`.
  - **Shared Component**: Reuses `hse_risk_section.dart`.

---

## 7. Major Refactored Files — Before vs After LOC

| File | Before LOC | After LOC | Difference | Reduction % | Primary Architectural Benefit |
|---|---|---|---|---|---|
| `lib/screens/job_details/job_detail_page.dart` | 2,294 | 1,102 | -1,192 lines | **-52.0%** | Decoupled UI presentation into 6 widgets; pure lifecycle orchestration |
| `lib/screens/job_details/post_submit_flow.dart` | 1,218 | 100 | -1,118 lines | **-91.8%** | Decomposed into 4 isolated phase screens + timeline |
| `lib/screens/job/follow_on_page.dart` | 1,076 | 856 | -220 lines | **-20.4%** | Extracted shared modal sheets (`HourlyAttendanceSheet`, `ReferralModalSheet`) |
| `lib/screens/chumley_ai/chumley_chat.dart` | 1,407 | 107 | -1,300 lines | **-92.4%** | Separated Insights, AI Chat, and People Chats into dedicated tab views |

---

## 8. Test and Analyzer Verification

```text
flutter analyze:
Analyzing chumley_navigator...
No issues found! (ran in 1.4s)

flutter test:
00:04 +85: All tests passed!
```

---

## 9. Architecture Assessment

1. **Is UI / Business Logic properly separated?**  
   Yes. UI widgets are strictly presentation-focused, accepting state/data models and emitting typed callbacks (`onPrimaryAction`, `onCloseJob`, `onSend`). Business rules and state transitions remain in their respective Cubits/Repositories (`JobsRepository`, `ChumleyChatCubit`, `AppointmentsApiService`).
2. **Is state ownership clear?**  
   Yes. `JobDetailPage` acts as the single source of truth for the active job's lifecycle without duplicate `setState` across nested child widgets.
3. **Are reusable widgets genuinely reusable?**  
   Yes. Components like `HourlyAttendanceSheet`, `ReferralModalSheet`, `ChatBubble`, and `ChatComposer` have clean, focused parameter lists and do not create artificial abstraction layers.
4. **Are there remaining duplicate systems?**  
   No. Shared modals and post-submit steps are consolidated without breaking feature-specific token themes.

---

## 10. Phase 4 Recommendations

1. **Forms Architecture Modularization**:
   - Refactor `eicr_form_page.dart` (2,083 LOC), `damp_survey_form_page.dart` (1,834 LOC), and `vent_hygiene_form_page.dart` (1,387 LOC) by extracting shared photo, checklist, and declaration sections.
2. **Dashboard Calendar & Milestones**:
   - Decompose `milestone_screen.dart` (1,440 LOC) and `dashboard_calendar.dart` (1,314 LOC) into focused presentation cards.
