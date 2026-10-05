import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/core/firebase_options.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/core/responsive/responsive_breakpoints.dart';
import 'package:chumley_navigator/core/responsive/responsive_layout.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/providers/theme_notifier.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/chumley_ai_floating_button.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    Log('Firebase init skipped or error: $e\n$st', name: 'Firebase');
  }
  AppDependencies.initialize();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.load();

  final sessionToken = await Prefs.getSessionToken();
  Log('sessionToken: ${maskToken(sessionToken)}', name: 'AppStart');

  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeNotifier});

  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        ResponsiveBreakpoints.phoneDesignWidth,
        ResponsiveBreakpoints.phoneDesignHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      enableScaleWH: ResponsiveLayout.screenUtilShouldScale,
      enableScaleText: ResponsiveLayout.screenUtilShouldScale,
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
                  navigatorObservers: [
                    ChumleyAiRouteObserver(),
                    AppDependencies.routeObserver,
                  ],
                  debugShowCheckedModeBanner: false,
                  title: 'Chumley Navigator',
                  routes: AppRoutes.routes,
                  initialRoute: AppRoutes.splash,
                  builder: (context, child) {
                    // Keep system text scaling from blowing up phone layouts
                    // further on large foldables.
                    final mq = MediaQuery.of(context);
                    return MediaQuery(
                      data: mq.copyWith(
                        textScaler: mq.textScaler.clamp(
                          minScaleFactor: 0.85,
                          maxScaleFactor: 1.15,
                        ),
                      ),
                      child: ChumleyAiAppOverlay(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                  theme: ThemeData(
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: AppColors.lightBase,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    textTheme: GoogleFonts.montserratTextTheme(),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primaryBlue,
                      brightness: Brightness.light,
                    ),
                  ),
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: AppColors.darkBase,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    textTheme: GoogleFonts.montserratTextTheme(
                      ThemeData.dark().textTheme,
                    ),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primaryBlue,
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
