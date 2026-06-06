import 'package:chumley_navigator/screens/absences/absences_screen.dart';
import 'package:chumley_navigator/screens/enquiries/enquiries_screen.dart';
import 'package:chumley_navigator/screens/forms/forms_screen.dart';
import 'package:chumley_navigator/screens/leaderboard/leaderboard_screen.dart';
import 'package:chumley_navigator/screens/milestones/milestone_screen.dart';
import 'package:chumley_navigator/screens/vehicle_check/vehile_check_screen.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../dashboard/dashboard_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _brandRed = AppColors.brandRed;

  int selectedIndex = 0;
  bool _showBottomBar = true;

  late final List<_NavItem> navItems = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      screen: const DashboardScreen(),
    ),
    _NavItem(
      label: 'Leaderboard',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      screen: LeaderboardScreen(),
    ),
    _NavItem(
      label: 'Milestones',
      icon: Icons.star_border_rounded,
      activeIcon: Icons.star_rounded,
      screen: const MilestoneScreen(),
    ),
    _NavItem(
      label: 'Vehicle',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag_rounded,
      screen: const VehileCheckScreen(),
    ),
    _NavItem(
      label: 'Forms',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt_rounded,
      screen: const FormsScreen(),
    ),
    _NavItem(
      label: 'Enquiries',
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      screen: const EnquiriesScreen(),
    ),
    _NavItem(
      label: 'Absences',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      screen: const AbsencesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);
        final isDark = theme.isDark;

        final fadeTop = isDark ? AppColors.darkBase : AppColors.lightBase;
        final barFill = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final barBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        final inactiveIcon = theme.textMuted;
        final selectedBg = isDark
            ? AppColors.darkSurfaceDeep
            : AppColors.lightSurfaceDeep;

        return Scaffold(
          backgroundColor: theme.base,
          body: Stack(
            fit: StackFit.expand,
            children: [
              NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  final direction = notification.direction;
                  if (direction == ScrollDirection.reverse && _showBottomBar) {
                    setState(() => _showBottomBar = false);
                  } else if (direction == ScrollDirection.forward &&
                      !_showBottomBar) {
                    setState(() => _showBottomBar = true);
                  }
                  return false;
                },
                child: navItems[selectedIndex].screen,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: !_showBottomBar,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 460),
                    curve: Curves.easeOutCubic,
                    offset: _showBottomBar ? Offset.zero : const Offset(0, 1.2),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: _showBottomBar ? 1 : 0,
                      child: SafeArea(
                        top: false,
                        child: Container(
                          height: 74.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color.lerp(
                                  Colors.transparent,
                                  fadeTop,
                                  0.94,
                                )!,
                                fadeTop,
                              ],
                              stops: const [0.0, 0.35, 1.0],
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(top: 14.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: barFill,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: barBorder,
                                  width: 0.5,
                                ),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowSoft,
                                  blurRadius: 16,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children:
                                  List.generate(navItems.length, (index) {
                                final item = navItems[index];
                                final isSelected = selectedIndex == index;

                                return Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        _showBottomBar = true;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 280),
                                      curve: Curves.easeOutCubic,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? selectedBg
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        border: isSelected
                                            ? Border.all(
                                                color: barBorder,
                                                width: 0.5,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.08 : 1,
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeOutBack,
                                          child: Icon(
                                            isSelected
                                                ? item.activeIcon
                                                : item.icon,
                                            size: 22.sp,
                                            color: isSelected
                                                ? _brandRed
                                                : inactiveIcon,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
}
