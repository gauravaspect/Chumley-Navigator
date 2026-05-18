import 'package:chumley_navigator/screens/dashboard/dashboard_screen.dart';
import 'package:chumley_navigator/screens/dashboard/goals_targets_screen.dart';
import 'package:chumley_navigator/screens/notifications/notification_screen.dart';
import 'package:chumley_navigator/screens/redeemPoints/redeem_points.dart';
import 'package:flutter/cupertino.dart';

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

  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => SplashScreen(),
    AppRoutes.login: (context) => LoginScreen(),
    AppRoutes.dashboard: (context)=> DashboardScreen(),
    AppRoutes.home : (context)=>Home(),
    AppRoutes.notifications: (context)=>NotificationScreen(),
    AppRoutes.goals: (context) => GoalsTargetsScreen(),
    AppRoutes.redeemPoints: (context) => RedeemPointsScreen(),
    AppRoutes.profile: (context) => ProfileScreen(),
  };
}
