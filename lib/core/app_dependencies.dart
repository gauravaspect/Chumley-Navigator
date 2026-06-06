import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/dio_interceptors.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:chumley_navigator/screens/login/cubit/login_cubit.dart';
import 'package:chumley_navigator/screens/login/repo/login_repository.dart';
import 'package:chumley_navigator/screens/login/service/login_api_service.dart';
import 'package:chumley_navigator/service/auth_service.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';

class AppDependencies {
  AppDependencies._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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

  static final DashboardApiService dashboardApiService =
      DashboardApiService(apiClient);
  static final DashboardRepository dashboardRepository = DashboardRepository(
    dashboardApiService,
  );

  static DashboardCubit createDashboardCubit() =>
      DashboardCubit(dashboardRepository);

  static void initialize() {
    DioInterceptor.onUnauthorized = () async {
      loginCubit.markUnauthenticated();
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    };
  }
}
