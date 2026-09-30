import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Tracks the active route so the global Chumley AI tab can hide on auth/splash.
class ChumleyAiRouteObserver extends NavigatorObserver {
  /// Start on splash so the FAB is hidden before the first observer event.
  static final ValueNotifier<String?> routeName = ValueNotifier<String?>(
    AppRoutes.splash,
  );

  void _setRoute(Route<dynamic>? route) {
    final name = route?.settings.name;
    // Keep the last named route when pushing unnamed screens (e.g. JobDetail).
    if (name != null && name.isNotEmpty) {
      routeName.value = name;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _setRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _setRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _setRoute(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _setRoute(previousRoute);
  }
}

/// Wraps the app and paints the Chumley AI pull tab above all screens.
class ChumleyAiAppOverlay extends StatelessWidget {
  const ChumleyAiAppOverlay({super.key, required this.child});

  final Widget child;

  static const _hiddenRoutes = {
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.chumleyChat,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ChumleyAiRouteObserver.routeName,
      builder: (context, routeName, _) {
        // Hidden on splash, login, chumley chat, and before any named route.
        final showFab = routeName != null && !_hiddenRoutes.contains(routeName);

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (showFab)
              const Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: ChumleyAiFloatingButton(),
              ),
          ],
        );
      },
    );
  }
}

/// Right-edge vertical tab with curved top-left and top-right corners.
class ChumleyAiFloatingButton extends StatelessWidget {
  const ChumleyAiFloatingButton({super.key, this.unreadCount = 0});

  final int unreadCount;

  void _openChumleyChat(BuildContext context) {
    // Overlay lives outside the Navigator (MaterialApp.builder), so use the
    // global navigator key instead of Navigator.of(context).
    final navigator = AppDependencies.navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(AppRoutes.chumleyChat);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(18.r),
      topRight: Radius.circular(18.r),
      bottomLeft: Radius.circular(18.r),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 8,
        shadowColor: AppColors.primaryBlue.withValues(alpha: 0.28),
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () => _openChumleyChat(context),
          borderRadius: borderRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.streakOrange, AppColors.primaryBlue],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 18.h, 8.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unreadCount > 0) ...[
                    Container(
                      constraints: BoxConstraints(minWidth: 20.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: AppColors.streakOrange),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.streakOrange,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Icon(LucideIcons.sparkles, color: Colors.white, size: 15.sp),
                  SizedBox(height: 10.h),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'CHUMLEY AI',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
