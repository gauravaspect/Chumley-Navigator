import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/screens/chumley_ai/Chumley_Chat.dart';
import 'package:chumley_navigator/screens/dashboard/earnings_detail_screen.dart';
import 'package:chumley_navigator/screens/dashboard/goals_targets_screen.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price_page.dart';
import 'package:chumley_navigator/screens/notifications/notification_screen.dart';
import 'package:chumley_navigator/screens/redeemPoints/redeem_points.dart';
import 'package:chumley_navigator/screens/vehicle_check/vehicle_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/home/home.dart';
import '../screens/login/login_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const dashboard = "/dashboard";
  static const home = "/home";
  static const notifications = "/notifications";
  static const goals = "/goals";
  static const redeemPoints = "/redeemPoints";
  static const profile = "/profile";
  static const vehicleForm = "/vehicleForm";
  static const earningsDetail = "/earningsDetail";
  static const fixedPriceScreen = "/fixedPriceScreen";
  static const chumleyChat = "/chumleyChat";
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => SplashScreen(),
    AppRoutes.login: (context) => LoginScreen(),
    AppRoutes.dashboard: (context) => const Home(),
    AppRoutes.home : (context)=>Home(),
    AppRoutes.notifications: (context)=>NotificationScreen(),
    AppRoutes.goals: (context) => GoalsTargetsScreen(),
    AppRoutes.redeemPoints: (context) => RedeemPointsScreen(),
    AppRoutes.profile: (context) => BlocProvider(
      create: (_) => AppDependencies.createDashboardCubit()..load(),
      child: const ProfileScreen(),
    ),
    AppRoutes.vehicleForm: (context) => BlocProvider(
      create: (_) => AppDependencies.createVcrExamplesCubit(),
      child: const VehicleForm(),
    ),
    AppRoutes.earningsDetail: (context) => const EarningsDetailScreen(),
    AppRoutes.fixedPriceScreen: (context) => BlocProvider(
          create: (_) => AppDependencies.createFixedPriceCubit()..loadTrades(),
          child: const FixedPricePage(),
        ),
    AppRoutes.chumleyChat: (context) => BlocProvider(
          create: (_) => AppDependencies.createChumleyChatCubit()..initialize(),
          child: const ChumleyChatScreen(),
        ),
  };
}
