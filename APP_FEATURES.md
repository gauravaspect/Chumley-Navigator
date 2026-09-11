# Chumley Navigator — Feature Status & Architecture Audit

**Document Version:** 1.0  
**Generated Date:** 2026-09-10  
**Project:** Chumley Navigator (Aspect Field Engineer Mobile Application)  
**Target Environment:** iOS & Android (Flutter)

---

## 1. Executive Summary

This document provides a comprehensive audit of all modules, screens, and features in the **Chumley Navigator** mobile application. It clearly categorizes features into:
- ✅ **Working (Live API Integration)**: Fully wired to backend endpoints with real business logic and data persistence.
- ⚠️ **Under Investigation / Partial**: Feature implemented but encountering specific runtime issues (e.g., VCR Image Submission).
- 🟡 **Prototype / Mock / Dummy UI**: Screen or flow built with local UI mockups, hardcoded states, or without active backend endpoints.

---

## 2. Feature Status Matrix

| Module / Feature | Status | Backend Endpoints | Notes |
| :--- | :---: | :--- | :--- |
| **Authentication & SSO** | ✅ Working | `POST /api/auth/mobile/exchange`<br>`POST /api/auth/signout` | Azure AD OAuth SSO / WebView exchange, token refresh, secure storage. |
| **Dashboard & KPIs** | ✅ Working | `GET /api/engineer/:id`<br>`GET /api/engineers/:id/points/summary` | Profile stats, score breakdown, performance history graph. |
| **Today's Schedule & PPM Jobs** | ✅ Working | `GET /api/engineer/appointments`<br>`GET /api/demo/ppm-tasks` | Appointments list, scheduled times, PPM demo jobs, full calendar. |
| **Job Details & Status Lifecycle** | ✅ Working | `GET /api/engineer/appointments/:saId`<br>`POST /api/engineer/appointments/:saId/status` | Job info, customer contacts, navigation, status updates (En Route, On Site, etc.). |
| **On-Site Wizard & Job Forms** | ✅ Working | `GET /api/engineer/appointments/:saId/forms`<br>`GET /api/engineer/appointments/:saId/forms/:wt`<br>`PUT .../draft`<br>`POST .../submit` | Dynamic step wizard, draft auto-saving, final form submission. |
| **Fixed Price Work Orders** | ✅ Working | `GET /api/work-orders/catalog/trades`<br>`GET /api/work-orders/catalog/categories`<br>`GET /api/work-orders/catalog/work-types`<br>`POST /api/work-orders` | Live multi-tier catalog browsing, pricing & margin calculations, work order creation. |
| **Vehicle Check Routine (VCR)** | ⚠️ Needs Investigation | `GET /api/vcr/allocations`<br>`GET /api/vcr/examples/:section`<br>`POST /api/vcr/submit` | Allocations & guides work; **image/report submission fails with unexpected error**. |
| **Milestones & Recognition** | ✅ Working | `GET /api/engineers/:id/milestones` | Milestone tiers, target tracking, points rewarded display. |
| **Leaderboard** | ✅ Working | `GET /api/leaderboard` | Engineer rank, points breakdown, dynamic period filter (all-time, monthly). |
| **Absences & Leave Requests** | ✅ Working | `GET /api/engineer/absences`<br>`POST /api/engineer/absences` | Leave history list, allowance cards, absence booking form submission. |
| **Chumley AI Assistant** | ✅ Working | `GET /api/insights/daily-briefing`<br>`GET/POST /api/navigator/conversations`<br>`POST /api/navigator/query`<br>`GET /api/scheduling/address-visit-summary` | Daily briefings, conversational context, role mapping, AI responses. |
| **Chumley Peer Chat** | ✅ Working | `GET /api/auth/chat-token`<br>`GET /api/permissions/me`<br>WebSocket real-time chat | Real-time direct messaging, channels, typing indicators, read receipts. |
| **Standalone Form Library** | 🟡 Partial / UI Flow | Linked to Job API if `saId` present; otherwise local UI | Damp Survey, Vent Hygiene, LD Form, EICR. Works standalone as interactive preview/draft. |
| **Goals & Targets Screen** | 🟡 Mock Data | Uses user KPI baseline from profile; detailed sub-pool history is static | Visual representation of conversion, productivity, procedural, vehicular scores. |
| **Earnings Detail Screen** | 🟡 Mock Data | Profile total earnings loaded; historical transaction list is mockup | Monthly breakdown graph and transaction feed are hardcoded prototype data. |
| **Points Redemption & Rewards** | 🟡 Mock Catalog | Live points balance displayed; reward catalog & claim flow are mockups | Gift cards (Amazon, Costa, Tesco) and voucher redemption flow are static UI demo. |
| **Notifications Screen** | 🟡 Empty State UI | None (No push notification service connected) | Tabbed container (All, Unread, Read) showing empty-state placeholders. |
| **Enquiries Hub** | 🟡 Prototype / Dummy | None (Local state only) | Dummy tickets (`ENQ-29384`), interactive inquiry submission form without backend API. |

---

## 3. Critical Issue Spotlight: VCR Image Submission Error

### Problem Statement
In the **Vehicle Check Routine (VCR)** screen (`/vehicleForm`), users complete the step-by-step vehicle inspection routine (capturing required camera angles, entering dashboard mileage, noting damages). However, upon clicking **Submit Inspection**, the submission fails with an **unexpected error** and images are not persisted.

### Current Implementation Overview
- **Endpoint:** `POST /api/vcr/submit`
- **Service File:** [`lib/screens/vehicle_check/service/vehicle_check_api_service.dart`](file:///Users/gaurav/Documents/Work/aspect/chumley_navigator/lib/screens/vehicle_check/service/vehicle_check_api_service.dart)
- **UI & Submission Logic:** [`lib/screens/vehicle_check/vehicle_form.dart`](file:///Users/gaurav/Documents/Work/aspect/chumley_navigator/lib/screens/vehicle_check/vehicle_form.dart)
- **Payload Construction:**
  ```dart
  final formData = FormData.fromMap({
    'vehicle_id': payload.vehicleId.trim(),
    'description': payload.description.trim(),
    'internal_notes': payload.internalNotes.trim(),
    'inspection_result': payload.inspectionResult.trim(),
  });

  for (final entry in payload.files) {
    formData.files.add(
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          entry.file.path,
          filename: '${entry.slotId}.jpg',
        ),
      ),
    );
  }
  ```

### Root Cause Hypotheses to Investigate
1. **Multipart Field Key Mismatch:**
   - Flutter Dio sends multiple files with the repeated key `'files'` or `'files[]'`. Some backends (e.g. FastAPI / Express / NestJS / Multer) expect explicit slot keys (e.g., `front_view`, `dashboard`, `odometer`) or array notation `files[]` rather than repeated `files` entries.
2. **Missing or Mismatched Content-Type Headers:**
   - Dio handles boundary headers automatically, but if overridden or intercepted incorrectly by custom interceptors, the backend fails to parse the multipart stream.
3. **File Size or Compression Format:**
   - Although client-side compression is applied via `ImageCompressor`, high-resolution files or camera outputs might exceed server body limits (e.g., 4MB / 10MB per file or request body limits on NGINX/reverse proxy).
4. **Backend Validation / Required Fields:**
   - The backend may require additional fields such as `engineer_id`, `odometer_reading`, `defects_found`, or `inspection_date` in addition to `vehicle_id`.
5. **Backend Error (500 / 422):**
   - The API server may encounter an unhandled exception when uploading images to S3 / Azure Blob Storage or processing EXIF metadata.

### Next Steps for Investigation
- [ ] Inspect raw HTTP request payload and response body using proxy / network logs.
- [ ] Verify backend Swagger / OpenAPI spec for `/api/vcr/submit` for expected field names and multipart schema.
- [ ] Test individual photo uploads vs batch uploads to isolate if a specific slot causes failure.

---

## 4. Detailed Feature Breakdown

### 4.1 Authentication & Profile
- ✅ **Azure AD SSO:** Interactive Microsoft OAuth authentication flow with automatic token exchange (`/api/auth/mobile/exchange`).
- ✅ **Token Refresh & Persistence:** Automatic session storage in Flutter Secure Storage and SharedPreferences.
- ✅ **Global 401 Interceptor:** Auto-redirects unauthenticated or expired sessions to `/login`.
- ✅ **Engineer Profile:** Displays user avatar, engineer ID, name, trade groups, and vehicle assignment.

---

### 4.2 Dashboard & Schedule
- ✅ **Performance KPI Header:** Real-time retrieval of engineer performance score, rank, and target benchmarks.
- ✅ **KPI Overview Cards:** Procedural, conversion, vehicular, and customer satisfaction metrics.
- ✅ **Earnings Card:** Live summary of base pay, job bonuses, and current cycle totals.
- ✅ **Today's Schedule:** Direct feed of assigned service appointments (`saId`), location, trade, and current status.
- ✅ **Demo PPM Tasks:** Integrated PPM job viewer with address details and asset specifications.
- ✅ **Interactive Calendar:** Mini dashboard calendar and full-screen month view (`/calendarFullScreen`).

---

### 4.3 Job Details & On-Site Execution Workflow
- ✅ **Job Detail Page:** Displays full appointment metadata, job descriptions, customer contact cards (with one-tap phone dialer), and navigation links.
- ✅ **Status Lifecycle Transitions:** Real-time progression buttons (`En Route` ➔ `On Site` ➔ `In Progress` ➔ `Completed` / `Cancelled`).
- ✅ **On-Site Wizard:** Interactive multi-step form runner for on-job reporting with draft saving and photo slot capture.
- ✅ **Post-Submit Flow:** Follow-on lead generation, customer signatures, and completion summaries.

---

### 4.4 Fixed Price Work Orders & Catalog
- ✅ **Live Trade & Category Catalog:** Dynamic cascading fetching from backend API:
  - Trades (`/api/work-orders/catalog/trades`)
  - Categories (`/api/work-orders/catalog/categories?trade_id=...`)
  - Work Types (`/api/work-orders/catalog/work-types?group_id=...`)
- ✅ **Interactive Pricing Calculator:** Live calculation of materials, labor hours, markup margins, and VAT.
- ✅ **Work Order Submission:** Direct creation and submission of quotes and job work orders (`POST /api/work-orders`).

---

### 4.5 Leaderboard & Milestones
- ✅ **Live Leaderboard:** Real-time leaderboard rankings, engineer points, rank badges (#1, #2, #3 podium), and time-range filtering.
- ✅ **Milestones Tracker:** Live milestone achievement data (`/api/engineers/:id/milestones`), category grouping, points awarded, and completion percentages.

---

### 4.6 Absences & Leave Management
- ✅ **Absences History:** Fetches existing holiday, sickness, and leave records.
- ✅ **Holiday Allowance Summary:** Computes remaining holiday balance, used days, and entitlement.
- ✅ **Leave Application Form:** Date picker range, absence type selector (Holiday, Sick, Unpaid, Training), description field, and backend submission (`POST /api/engineer/absences`).

---

### 4.7 Chumley AI & Peer Messaging
- ✅ **Navigator AI Assistant:**
  - Daily briefing insight summary (`/api/insights/daily-briefing`).
  - Contextual job and schedule queries (`/api/navigator/query`).
  - Conversation session persistence (`/api/navigator/conversations`).
- ✅ **Chumley Peer Chat:**
  - Token-based chat authentication (`/api/auth/chat-token`).
  - Direct 1-on-1 messaging and engineer group channels.
  - WebSocket real-time message stream with connection state management.

---

### 4.8 Mockup / Prototype / Dummy Modules
The following screens and components currently contain prototype or non-backend-integrated logic:

1. 🟡 **Enquiries Hub (`/enquiries`):**
   - UI for raising internal queries (HR, Pay, Job issues, Safety).
   - Sample ticket items (`ENQ-29384`, `ENQ-08917`) are hardcoded.
   - Form submission only adds tickets to local state in memory.
2. 🟡 **Points Redemption & Rewards (`/redeemPoints`):**
   - Shows active points balance from live profile.
   - Gift card catalog (Costa £5, Tesco £10, Amazon £15, Sainsbury's £20, Currys £25, Shell £50) is static.
   - Redemption flow has no backing transaction API yet.
3. 🟡 **Earnings Detail Screen (`/earningsDetail`):**
   - Monthly breakdown chart and transaction activity feed use static mock records.
4. 🟡 **Goals & Targets Detail (`/goals`):**
   - Pool history delta charts use mock baseline multipliers.
5. 🟡 **Notifications Hub (`/notifications`):**
   - Placeholder tabs (All, Unread, Read) with empty-state messages. No push notification API or inbox database integrated.

---

## 5. Architectural & Design Foundations
- **State Management:** Flutter BLoC / Cubit pattern for all major feature domains.
- **Networking:** Dio HTTP client with central interceptors, error mapping, and logging.
- **Responsive Layout:** ScreenUtil (`flutter_screenutil`) responsive scaling across screen sizes.
- **Design System:** Light & Dark theme palette (`DashboardTheme`), custom typography, glassmorphism cards, and micro-animations.

---

## 6. Recommended Action Items

| Priority | Action Item | Target Area |
| :--- | :--- | :--- |
| 🔴 **P0** | **Fix VCR Image Submission Error**<br>Investigate multipart field structure and server response on `POST /api/vcr/submit`. | `lib/screens/vehicle_check/` |
| 🟠 **P1** | **Connect Enquiries to Backend**<br>Implement API endpoints for creating, listing, and tracking enquiry tickets. | `lib/screens/enquiries/` |
| 🟠 **P1** | **Implement Real Rewards Redemption**<br>Connect gift card catalog and points deduction to backend reward service. | `lib/screens/redeemPoints/` |
| 🟡 **P2** | **Integrate Notifications Center**<br>Connect Firebase Cloud Messaging (FCM) or backend notification inbox. | `lib/screens/notifications/` |
| 🟡 **P2** | **Live Earnings Breakdown**<br>Wire historical earnings activity and payslip items to backend finance APIs. | `lib/screens/dashboard/earnings_detail_screen.dart` |
