import 'package:chumley_navigator/screens/enquiries/enquiries_screen.dart';
import 'package:chumley_navigator/screens/leaderboard/leaderboard_screen.dart';
import 'package:chumley_navigator/screens/milestones/milestone_screen.dart';
import 'package:flutter/material.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../dashboard/dashboard_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  late final List<_NavItem> navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      screen: const DashboardScreen(),
    ),
    _NavItem(
      label: 'Leaderboard',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      screen:  LeaderboardScreen(),
    ),
    _NavItem(
      label: 'Milestones',
      icon: Icons.star_border_rounded,
      activeIcon: Icons.star_rounded,
      screen: const MilestoneScreen(),
    ),
    _NavItem(
      label: 'Vehicle Check',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag_rounded,
      screen: const TargetsScreen(),
    ),
    _NavItem(
      label: 'Forms',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt,
      screen: const TasksScreen(),
    ),
    _NavItem(
      label: 'Enquiries',
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work,
      screen: EnquiriesScreen(),
    ),
    _NavItem(
      label: 'Absences',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      screen: const CalendarScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      // ─────────────────────────────────────────────
      // SCREEN
      // ─────────────────────────────────────────────

      body: navItems[selectedIndex].screen,

      // ─────────────────────────────────────────────
      // BOTTOM NAVBAR
      // ─────────────────────────────────────────────

      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: 12.h,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10.r,
                offset: Offset(0, 0.h),
              ),
            ],
          ),

          child: Row(
            children: List.generate(
              navItems.length,
                  (index) {
                final item = navItems[index];

                final bool isSelected =
                    selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },

                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 2.w,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentLime
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(100.r),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? item.activeIcon
                                : item.icon,
                            size: 22.sp,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textInactive,
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            item.label,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NAV ITEM MODEL
// ─────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}

// ─────────────────────────────────────────────────────────────
// SCREENS
// ─────────────────────────────────────────────────────────────

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Analytics',
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Favorites',
    );
  }
}

class TargetsScreen extends StatelessWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Targets',
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Tasks',
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'Calendar',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMMON SCREEN UI
// ─────────────────────────────────────────────────────────────

class _BaseScreen extends StatelessWidget {
  final String title;

  const _BaseScreen({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      body: SafeArea(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeadingDark,
            ),
          ),
        ),
      ),
    );
  }
}