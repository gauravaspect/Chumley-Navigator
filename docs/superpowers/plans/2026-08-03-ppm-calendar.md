# PPM Calendar Implementation Plan

> **For agentic workers:** Implement task-by-task. Steps use checkbox syntax.

**Goal:** Show demo PPM tasks on today’s dashboard calendar with teal styling and a separate details page.

**Architecture:** Dashboard cubit/repo fetches `/api/demo/ppm-tasks` with `X-Demo-Key` and auth email; calendar renders PPM separately from appointments; tap opens `PpmJobDetailPage`.

**Tech Stack:** Flutter, Dio, Cubit, existing Equatable models.

## Global Constraints

- PPM always on today; existing `JobDetailPage` untouched; PPM forms placeholder only; PPM fetch failures must not fail dashboard load.

---

### Task 1: API wiring

- [x] Add `AppConstants.demoApiKey`
- [x] Add `ApiEndpoints.getPpmJobs`
- [x] Extend `ApiClient.get` with optional `Options`/headers
- [x] Fix `DashboardApiService.fetchPpmJobs` (email query + demo header + `PpmJobsResponse`)
- [x] Add `DashboardRepository.fetchPpmJobs`

### Task 2: Cubit/state + dashboard screen

- [x] Add `ppmTasks` to loaded/loading/error state helpers
- [x] Best-effort PPM fetch in `DashboardCubit.load`
- [x] Pass `ppmTasks` into `DashboardCalendar`

### Task 3: Calendar UI + PPM details page

- [x] Day dots + PPM schedule cards (teal)
- [x] New `PpmJobDetailPage` with details + forms placeholder
