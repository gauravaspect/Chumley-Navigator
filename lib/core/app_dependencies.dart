import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/dio_interceptors.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:chumley_navigator/screens/leaderboard/repo/leaderboard_repository.dart';
import 'package:chumley_navigator/screens/leaderboard/service/leaderboard_api_service.dart';
import 'package:chumley_navigator/screens/login/cubit/login_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/repo/vehicle_check_repository.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vehicle_check_api_service.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/repo/vcr_examples_repository.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vcr_examples_api_service.dart';
import 'package:chumley_navigator/screens/login/repo/login_repository.dart';
import 'package:chumley_navigator/screens/login/service/login_api_service.dart';
import 'package:chumley_navigator/screens/absences/cubit/absences_cubit.dart';
import 'package:chumley_navigator/screens/absences/repo/absences_repository.dart';
import 'package:chumley_navigator/screens/absences/service/absences_api_service.dart';
import 'package:chumley_navigator/screens/milestones/cubit/milestones_cubit.dart';
import 'package:chumley_navigator/screens/milestones/repo/milestones_repository.dart';
import 'package:chumley_navigator/screens/milestones/service/milestones_api_service.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_cubit.dart';
import 'package:chumley_navigator/screens/job_details/repo/appointments_repository.dart';
import 'package:chumley_navigator/screens/job_details/repo/fixed_price_repository.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';
import 'package:chumley_navigator/screens/job_details/service/fixed_price_api_service.dart';
import 'package:chumley_navigator/screens/chumley_ai/auth/chumley_auth_provider.dart';
import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_cubit.dart';
import 'package:chumley_navigator/screens/chumley_ai/repo/chumley_chat_repository.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/chumley_chat_api_service.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/navigator_chat_api_service.dart';
import 'package:chumley_navigator/service/auth_service.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';

class AppDependencies {
  AppDependencies._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static final ApiClient apiClient = ApiClient();
  static final AzureAuthService azureAuthService = AzureAuthService(
    navigatorKey: navigatorKey,
  );
  static final LoginApiService loginApiService = LoginApiService(apiClient);
  static final LoginRepository loginRepository = LoginRepository(
    azureAuthService: azureAuthService,
    loginApiService: loginApiService,
  );
  static final LoginCubit loginCubit = LoginCubit(loginRepository);

  static final DashboardApiService dashboardApiService = DashboardApiService(
    apiClient,
  );
  static final DashboardRepository dashboardRepository = DashboardRepository(
    dashboardApiService,
    appointmentsRepository: appointmentsRepository,
  );

  static final LeaderboardApiService leaderboardApiService =
      LeaderboardApiService(apiClient);
  static final LeaderboardRepository leaderboardRepository =
      LeaderboardRepository(leaderboardApiService);

  static final VehicleCheckApiService vehicleCheckApiService =
      VehicleCheckApiService(apiClient);
  static final VehicleCheckRepository vehicleCheckRepository =
      VehicleCheckRepository(vehicleCheckApiService);

  static final VcrExamplesApiService vcrExamplesApiService =
      VcrExamplesApiService(apiClient);
  static final VcrExamplesRepository vcrExamplesRepository =
      VcrExamplesRepository(vcrExamplesApiService);

  static final AbsencesApiService absencesApiService = AbsencesApiService(
    apiClient,
  );
  static final AbsencesRepository absencesRepository = AbsencesRepository(
    absencesApiService,
  );

  static final MilestonesApiService milestonesApiService = MilestonesApiService(
    apiClient,
  );
  static final MilestonesRepository milestonesRepository = MilestonesRepository(
    milestonesApiService,
  );

  static final FixedPriceApiService fixedPriceApiService = FixedPriceApiService(
    apiClient,
  );
  static final FixedPriceRepository fixedPriceRepository = FixedPriceRepository(
    fixedPriceApiService,
  );

  static final AppointmentsApiService appointmentsApiService =
      AppointmentsApiService(apiClient);
  static final AppointmentsRepository appointmentsRepository =
      AppointmentsRepository(appointmentsApiService);

  static final ChumleyAuthProvider chumleyAuthProvider = ChumleyAuthProvider(
    apiClient,
  );
  static final NavigatorChatApiService navigatorChatApiService =
      NavigatorChatApiService(apiClient);
  static final ChumleyChatApiService chumleyChatApiService =
      ChumleyChatApiService(chumleyAuthProvider);
  static final ChumleyChatRepository chumleyChatRepository =
      ChumleyChatRepository(
        authProvider: chumleyAuthProvider,
        navigatorApi: navigatorChatApiService,
        chumleyApi: chumleyChatApiService,
      );

  static DashboardCubit createDashboardCubit() =>
      DashboardCubit(dashboardRepository);

  static LeaderboardCubit createLeaderboardCubit() =>
      LeaderboardCubit(leaderboardRepository);

  static VehicleCheckCubit createVehicleCheckCubit() =>
      VehicleCheckCubit(vehicleCheckRepository);

  static VcrExamplesCubit createVcrExamplesCubit() =>
      VcrExamplesCubit(vcrExamplesRepository);

  static AbsencesCubit createAbsencesCubit() =>
      AbsencesCubit(absencesRepository);

  static MilestonesCubit createMilestonesCubit() =>
      MilestonesCubit(milestonesRepository);

  static FixedPriceCubit createFixedPriceCubit() =>
      FixedPriceCubit(fixedPriceRepository);

  static ChumleyChatCubit createChumleyChatCubit() =>
      ChumleyChatCubit(chumleyChatRepository);

  static void initialize() {
    loginCubit.onAfterLogout = () async {
      chumleyAuthProvider.clear();
      await chumleyChatRepository.disconnectSocket();
    };
    DioInterceptor.onUnauthorized = () async {
      chumleyAuthProvider.clear();
      await chumleyChatRepository.disconnectSocket();
      loginCubit.markUnauthenticated();
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    };
  }
}
