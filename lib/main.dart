import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/providers/theme_notifier.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDependencies.initialize();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.load();
  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeNotifier});

  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      builder: (context, child) {
        return ThemeScope(
          notifier: themeNotifier,
          child: BlocProvider.value(
            value: AppDependencies.loginCubit,
            child: AnimatedBuilder(
              animation: themeNotifier,
              builder: (context, _) {
                final isDark = themeNotifier.isDark;
                return MaterialApp(
                  navigatorKey: AppDependencies.navigatorKey,
                  debugShowCheckedModeBanner: false,
                  title: 'Chumley Navigator',
                  routes: AppRoutes.routes,
                  initialRoute: AppRoutes.splash,
                  theme: ThemeData(
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: AppColors.lightBase,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    textTheme: GoogleFonts.interTextTheme(),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.brandRed,
                      brightness: Brightness.light,
                    ),
                  ),
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: AppColors.darkBase,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    textTheme: GoogleFonts.interTextTheme(
                      ThemeData.dark().textTheme,
                    ),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.brandRed,
                      brightness: Brightness.dark,
                    ),
                  ),
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
