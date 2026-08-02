# PPM Demo Tasks on Dashboard Calendar

Date: 2026-08-03  
Status: Draft for review

## Goal

Show demo PPM tasks on the dashboard calendar alongside existing Salesforce appointments, with a distinct highlight colour, and open a **new** job details page (existing `JobDetailPage` unchanged). Forms on the PPM details page are a later follow-up.

## Decisions

| Topic | Choice |
|-------|--------|
| Architecture | Dashboard data path (cubit/repo → calendar) |
| Calendar date | Always treat PPM tasks as **today** |
| Demo auth | Hardcode `X-Demo-Key` in `AppConstants` |
| Engineer filter | Logged-in `AuthUser.email` |
| Highlight | Teal accent (distinct from existing blue appointment UI) |
| Details | New `PpmJobDetailPage`; leave `JobDetailPage` alone |

## API

```
GET /api/demo/ppm-tasks?engineer_email=<AuthUser.email>
Header: X-Demo-Key: <AppConstants.demoApiKey>
```

- Base URL: existing `AppConstants.apiBaseUrl` / `ApiEndpoints`
- Parse with existing `PpmJobsResponse` / `PpmJobTask`
- Complete the stub in `DashboardApiService.fetchPpmJobs` (fix typing, query param, demo header, Dio error handling)

## Data flow

1. `DashboardCubit.load()` fetches profile + points as today.
2. Also fetch PPM tasks (best-effort): if PPM fails, still emit loaded dashboard with `ppmTasks: []` (or keep last good list); do not fail the whole screen solely because PPM failed.
3. Extend `DashboardState` (`DashboardLoaded` / loading/error cache helpers) with `List<PpmJobTask> ppmTasks`.
4. `DashboardScreen` passes `ppmTasks` into `DashboardCalendar`.

## Calendar UI

- New optional param: `List<PpmJobTask> ppmTasks`.
- Day indicator:
  - Existing appointment → existing primary/blue dot.
  - PPM on today → teal dot (or dual dots if both exist that day).
- Schedule list for selected day:
  - Appointments → existing `JobScheduleCard` → `JobDetailPage`.
  - PPM (when selected day is today) → `PpmJobScheduleCard` (same layout language, teal-tinted border/header, small “PPM” badge) → `PpmJobDetailPage`.
- Time display from `start_hour` / `end_hour` (e.g. `07:00 – 09:00`).

## PpmJobDetailPage

Lightweight shell (not a fork of the full map/status lifecycle page):

- Header: subject + status
- Details: appointment number, trade group, work type, job type, postcode, hours, engineer name/email
- Forms section: empty placeholder (“Forms coming soon” / reserved slot for later attachment)
- Back navigation only; no fixed-price / LD / damp / vent wiring yet

## Out of scope

- PPM forms set (user will attach later)
- Mapping PPM into `Appointment` / reusing `JobDetailPage`
- Caching PPM in `Prefs`
- Showing PPM on days other than today

## Files touched (expected)

- `lib/core/app_constants.dart` — `demoApiKey`
- `lib/core/network/api_endpoints.dart` — `getPpmJobs` (+ optional skip-auth if demo route must not send Bearer; verify against live API)
- `lib/core/network/api_client.dart` — allow per-request headers on `get` if missing
- `lib/screens/dashboard/service/dashboard_api_service.dart` — finish `fetchPpmJobs`
- `lib/screens/dashboard/repo/dashboard_repository.dart`
- `lib/screens/dashboard/cubit/dashboard_cubit.dart` + `dashboard_state.dart`
- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/components/dashboard/dashboard_calendar.dart` — PPM list + dots + card
- `lib/screens/job_details/ppm_job_detail_page.dart` — **new**

## Success criteria

- Today’s schedule shows PPM tasks with teal styling distinct from appointments.
- Tapping a normal job still opens `JobDetailPage`.
- Tapping a PPM job opens `PpmJobDetailPage`.
- Dashboard still loads if the demo PPM endpoint errors.
