# Chumley Navigator Architecture Report

Generated on: 2026-06-04

## Executive Summary

Chumley Navigator is a Flutter application targeting mobile, web, and desktop platforms. The current codebase is primarily a presentation-led Flutter app with a strong reusable widget layer, a static route table, app-wide theme state, and early scaffolding for API/authentication concerns.

The implemented product surface is centered on a dashboard-style employee/navigation experience: splash, login, dashboard, leaderboard, milestones, vehicle checks, forms, enquiries, absences, notifications, profile, goals, earnings detail, and redeem points. Most feature screens currently use local widget state, demo models, or static data rather than remote data.

The backend integration layer exists in outline through Dio, interceptors, response helpers, preference storage, and Azure AD auth service classes, but important pieces are incomplete or not yet wired into UI flows.

## Technology Stack

- Framework: Flutter
- Language: Dart
- Responsive layout: `flutter_screenutil`
- Fonts: `google_fonts`
- Icons: Flutter Material icons, `flutter_lucide`, `lucide_icons_flutter`
- Media: `video_player`
- Image capture: `image_picker`
- Dropdowns: `dropdown_button2`
- HTTP client: `dio`
- Persistence: `shared_preferences`
- Authentication dependency: `aad_oauth`
- State management dependencies: `flutter_bloc`, `equatable`

## Repository Layout

```text
lib/
  main.dart
  components/
    common/
    dashboard/
    redeem_points/
    calendar/
  core/
    network/
    storage/
    app_constants.dart
    app_dependencies.dart
    utils.dart
  data/
  models/
  providers/
  screens/
    absences/
    dashboard/
    enquiries/
    forms/
    home/
    leaderboard/
    login/
    milestones/
    notifications/
    profile/
    redeemPoints/
    splash/
    vehicle_check/
  service/
  utils/
  widgets/
    absences/
    milestones/
    profile/
    ui/
    vehicle/
```

The project also includes standard Flutter platform folders:

- `android/`
- `ios/`
- `web/`
- `macos/`
- `linux/`
- `windows/`

Static assets are grouped under:

- `assets/images/`
- `assets/videos/`
- `assets/brands/`

## Application Bootstrap

Entry point: `lib/main.dart`

Startup flow:

1. `WidgetsFlutterBinding.ensureInitialized()` prepares Flutter bindings.
2. A `ThemeNotifier` is created and loaded from `SharedPreferences`.
3. `runApp()` starts `MyApp`.
4. `MyApp` wraps the app in `ScreenUtilInit`.
5. `ThemeScope` exposes the `ThemeNotifier` through an `InheritedNotifier`.
6. `MaterialApp` is configured with:
   - `AppRoutes.routes`
   - `AppRoutes.splash` as initial route
   - light and dark `ThemeData`
   - Google Inter font
   - seed color from `AppColors.brandRed`

This gives the app a simple global composition root:

```text
main()
  -> ThemeNotifier.load()
  -> MyApp
      -> ScreenUtilInit
          -> ThemeScope
              -> AnimatedBuilder
                  -> MaterialApp
```

## Navigation Architecture

Route definitions live in `lib/utils/routes.dart`.

Navigation uses a static `Map<String, WidgetBuilder>` passed directly to `MaterialApp.routes`.

Current top-level route constants:

- `/` -> `SplashScreen`
- `/login` -> `LoginScreen`
- `/dashboard` -> `DashboardScreen`
- `/home` -> `Home`
- `/notifications` -> `NotificationScreen`
- `/goals` -> `GoalsTargetsScreen`
- `/redeemPoints` -> `RedeemPointsScreen`
- `/profile` -> `ProfileScreen`
- `/vehicleForm` -> `VehicleForm`
- `/earningsDetail` -> `EarningsDetailScreen`

The `Home` screen is the main tab-like container. It keeps `selectedIndex` in local state and renders one of these feature screens:

- Dashboard
- Leaderboard
- Milestones
- Vehicle
- Forms
- Enquiries
- Absences

The bottom navigation bar is custom-built and hides/shows based on `UserScrollNotification` direction.

## Feature Module Structure

The app uses a pragmatic feature-folder structure under `lib/screens/`, supported by reusable widgets under `lib/widgets/` and larger presentational components under `lib/components/`.

### Dashboard

Main file: `lib/screens/dashboard/dashboard_screen.dart`

The dashboard composes these components:

- `DashboardHeader`
- `EarningCard`
- `KpiOverview`
- `PointsCard`
- `DashboardCalendar`
- `EarningGraph`

Data currently comes from:

- `UserModel.demo`
- `KpiDataSource.instance`
- locally generated event dates

`KpiDataSource` simulates loading with a delayed future and returns static KPI card data.

### Home

Main file: `lib/screens/home/home.dart`

`Home` owns the primary in-app navigation state. It does not use nested navigators; it directly swaps the selected screen widget in the body.

This is simple and effective for the current app, but it means each tab does not preserve its own navigation stack unless additional logic is added later.

### Login and Authentication

Main UI file: `lib/screens/login/login_screen.dart`

The login screen currently presents a Microsoft sign-in button, but the button routes directly to `AppRoutes.home`. It does not currently invoke `AzureAuthService`, the login cubit, or a login repository.

Scaffolded files exist under `lib/screens/login/`:

- `cubit/login_state.dart`
- `cubit/login_cubit.dart`
- `repo/login_repository.dart`
- `service/login_api_service.dart`

At the time of review, `login_cubit.dart`, `login_repository.dart`, and `login_api_service.dart` are empty. `login_state.dart` defines auth states, but references `UserModel` without an import.

### Splash

Main file: `lib/screens/splash/splash_screen.dart`

Splash uses `video_player` to play `assets/videos/navigator-splash.mp4`, then animates an outro before routing to `/login`.

The splash screen is animation-heavy and keeps animation/video lifecycle concerns local to the screen.

### Vehicle Check

Main files:

- `lib/screens/vehicle_check/vehile_check_screen.dart`
- `lib/screens/vehicle_check/vehicle_form.dart`
- `lib/screens/vehicle_check/vcr_step_data.dart`

`VehicleForm` uses:

- local `State`
- `TextEditingController`
- `ImagePicker`
- `File` captures keyed by capture slot ID
- static step data from `vcr_step_data.dart`

The feature is UI-complete enough to step through inspection sections and capture photos locally, but there is no visible submission/API integration yet.

### Absences

Main file: `lib/screens/absences/absences_screen.dart`

Absences uses local state for selected reason, selected date, time fields, whole-day toggle, and description text. Calendar marks and absence records are static/demo data.

Reusable absence widgets live under `lib/widgets/absences/`.

### Other Feature Areas

The following feature screens are present and mostly presentation-oriented:

- Forms
- Form details
- Enquiries
- Milestones
- Notifications
- Profile
- Leaderboard
- Goals and targets
- Earnings detail
- Redeem points

These features follow the same broad pattern:

```text
screen file
  -> local state where needed
  -> shared theme via ThemeScope/DashboardTheme
  -> reusable components/widgets
  -> static or demo display data
```

## Theming and Styling

The theme layer is one of the more consistent parts of the app.

Key files:

- `lib/providers/theme_notifier.dart`
- `lib/widgets/theme_scope.dart`
- `lib/utils/dashboard_theme.dart`
- `lib/utils/colors.dart`

Architecture:

```text
ThemeNotifier
  -> stores `isDark` in SharedPreferences
  -> extends ChangeNotifier
  -> exposed through ThemeScope
  -> consumed by DashboardTheme.of(context)
```

Many screens use:

```dart
ListenableBuilder(
  listenable: ThemeScope.of(context),
  builder: ...
)
```

This gives screens explicit rebuilds when the theme changes.

`AppColors` centralizes a large color palette covering brand colors, surfaces, semantic states, dashboard colors, gift-card colors, shadows, and dark/light variants.

## Data and State Management

Current state patterns:

- App-wide theme: `ThemeNotifier` with `InheritedNotifier`
- Screen-local UI state: `StatefulWidget` fields and controllers
- Static singleton data source: `KpiDataSource.instance`
- Persistent tokens/theme flags: `SharedPreferences`
- Planned auth state: sealed auth states under login cubit folder

Although `flutter_bloc` and `equatable` are listed in dependencies, Bloc/Cubit is not currently wired into the active UI flow.

There is no central dependency injection mechanism yet. `lib/core/app_dependencies.dart` exists but is empty.

## Network Layer

Key files:

- `lib/core/network/dio_client.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/dio_interceptors.dart`
- `lib/core/network/api_response_helper.dart`
- `lib/core/network/network_exceptions.dart`
- `lib/core/network/api_endpoints.dart`

Flow:

```text
ApiClient
  -> DioClient().dio
      -> BaseOptions(baseUrl, timeouts, JSON headers)
      -> DioInterceptor
```

`ApiClient` exposes simple HTTP methods:

- `get`
- `post`
- `put`
- `delete`

`post` and `put` detect `FormData` and set `multipart/form-data`.

`DioInterceptor`:

- reads a bearer token from `Prefs.getAccessBearer()`
- attaches `Authorization: Bearer <token>`
- attempts to retry requests on 401 if a refresh token exists
- removes token keys on refresh failure

Important implementation note: the interceptor currently does not perform a real token refresh call. On 401 it retries the original request using the same request options. That will not resolve expired-token failures unless some other mechanism updates the token before retry.

`ApiResponseHelper` normalizes response bodies and extracts friendly error messages, including handling 413 upload-size failures. It also includes file-size helpers for upload validation.

`ApiEndpoints.baseUrl` is currently an empty string.

## Storage Layer

Key file: `lib/core/storage/prefs.dart`

`Prefs` wraps `SharedPreferences` access for:

- bearer token
- refresh token
- clearing all preferences

Observed key names:

- bearer token: `bearer`
- refresh token: `refreshToken`

There is a mismatch in `DioInterceptor` error cleanup, where it removes `access_token` and `refresh_token`, while `Prefs` stores `bearer` and `refreshToken`. That means failed refresh cleanup may leave stored auth values behind.

## Authentication Layer

Key file: `lib/service/auth_service.dart`

`AzureAuthService` wraps `aad_oauth` with:

- tenant ID
- client ID from `AppConstants.clientId`
- scope: `openid profile email User.Read`
- redirect URI: `msauth.uk.co.aspect.engineerapp://auth`

Current limitations:

- `AppConstants.clientId` is empty.
- `LoginScreen` does not use `AzureAuthService`.
- Login repository/service/cubit files are mostly empty.
- Token persistence is not connected to the OAuth login flow.

## Models

Current model file:

- `lib/models/user_model.dart`

`UserModel` is a UI-oriented model with fields for:

- first name
- last name
- trips today
- rating
- acceptance rate
- today earnings

It includes display helpers such as `displayName`, `todayEarningsLabel`, `ratingLabel`, `acceptRateLabel`, `initials`, and `avatarColorSeed`.

The current dashboard uses `UserModel.demo`.

## Shared UI Layer

Reusable widgets are grouped by domain and generic UI use:

- `lib/widgets/ui/`: buttons, animation helpers, surfaces, shimmer, title blocks
- `lib/widgets/vehicle/`: vehicle-check cards, slots, indicators, warnings
- `lib/widgets/absences/`: absence calendar, form cards, time picker, absence cards
- `lib/widgets/milestones/`: milestone timeline and stat cards
- `lib/widgets/profile/`: profile info/stat widgets

Reusable components are slightly larger composed UI blocks:

- `lib/components/dashboard/`
- `lib/components/redeem_points/`
- `lib/components/common/`
- `lib/components/calendar/`

This creates a practical split:

```text
screens/     route-level feature surfaces
components/  composed feature sections
widgets/     smaller reusable UI elements
utils/       theme, colors, routes, helpers
core/        network/storage/app infrastructure
```

## Assets and Platform Support

The app declares asset folders in `pubspec.yaml`:

- `assets/images/`
- `assets/videos/`
- `assets/brands/`

The splash screen depends on:

- `assets/videos/navigator-splash.mp4`

Branding and product imagery are stored as PNG/JPG assets.

The repository includes generated/standard Flutter platform scaffolding for Android, iOS, web, macOS, Linux, and Windows.

## Architectural Strengths

- Clear Flutter app bootstrap with responsive setup and theme loading before `runApp`.
- Consistent screen composition using reusable widgets and feature-oriented folders.
- Centralized color palette and dashboard theme abstraction.
- Simple static route table that is easy to inspect.
- Network helper layer already exists and can be expanded without changing every feature screen.
- UI state is kept close to the relevant screen, which is reasonable while features are mostly static/demo.
- Reusable UI primitives reduce repeated styling across dashboard, vehicle, absence, and profile surfaces.

## Gaps and Risks

1. Authentication is scaffolded but not wired.
   - The login button bypasses auth and routes directly to home.
   - OAuth client ID is empty.
   - Login cubit/repository/service files are empty.

2. API configuration is incomplete.
   - `ApiEndpoints.baseUrl` is empty.
   - There is no environment configuration strategy visible in the Dart code.

3. Token refresh behavior is incomplete.
   - The interceptor retries the original 401 request without refreshing the access token.
   - Token cleanup uses different key names from `Prefs`.

4. State management is inconsistent with dependencies.
   - `flutter_bloc` is included, but current screens mostly use local state.
   - This is not automatically wrong, but the intended architecture is unclear.

5. `app_dependencies.dart` is empty.
   - There is no dependency composition/root object yet.
   - Services are currently constructed directly or left unused.

6. Demo/static data is still central to the app.
   - Dashboard, absences, KPI cards, user info, vehicle allocation, and other surfaces appear to rely on local/demo values.

7. Some naming and compile-readiness issues are visible.
   - `vehile_check_screen.dart` appears to contain a spelling typo in the filename.
   - `login_state.dart` references `UserModel` without importing it.
   - Empty Dart files may be harmless, but they indicate unfinished module wiring.

## Suggested Next Architecture Steps

1. Decide the app-wide state strategy.
   - If Bloc/Cubit is the target, wire login first and use that as the reference pattern.
   - If local state plus services is preferred, remove unused Bloc scaffolding and dependencies.

2. Create an environment/config layer.
   - Populate API base URL and Azure client ID from build-time configuration such as `--dart-define`.
   - Keep secrets out of source code.

3. Finish auth flow integration.
   - Connect `LoginScreen` to `AzureAuthService`.
   - Persist tokens through `Prefs`.
   - Add authenticated/unauthenticated routing decisions after splash.

4. Fix token refresh semantics.
   - Add a real refresh endpoint call or remove refresh retry behavior until implemented.
   - Align token key names across `Prefs` and interceptor cleanup.

5. Introduce feature repositories where remote data starts.
   - Dashboard repository
   - Absence repository
   - Vehicle-check repository
   - Profile repository

6. Define a dependency composition point.
   - Use `app_dependencies.dart` as a simple service container, or adopt provider-style injection.
   - Avoid constructing fresh API clients deep inside every repository once remote features expand.

7. Add architecture-focused tests.
   - Unit-test `ApiResponseHelper` and `NetworkExceptions`.
   - Test `ThemeNotifier` persistence behavior.
   - Widget-test key flows: splash route handoff, login button behavior, home navigation.

## High-Level Dependency View

```text
UI Screens
  -> Components
      -> Widgets
          -> ThemeScope / DashboardTheme / AppColors

UI Screens
  -> Models / Data sources

Future remote features
  -> Repositories
      -> ApiClient
          -> DioClient
              -> DioInterceptor
                  -> Prefs

Auth flow
  -> AzureAuthService
      -> aad_oauth
  -> Prefs
  -> Routing decision
```

## Current Architecture Classification

The current application is best described as:

```text
Feature-oriented Flutter UI architecture
with centralized theming,
static route navigation,
local screen state,
demo/static data sources,
and scaffolded network/auth infrastructure.
```

It is ready for UI iteration and prototype validation. The main architectural work remaining is to turn the scaffolded service layer into a consistent data/auth flow and decide whether Bloc/Cubit will become the standard state-management pattern or remain unused.
