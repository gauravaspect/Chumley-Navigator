import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/user_display.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.user,
    this.isLoading = false,
    this.hasNotifications = true,
  });

  final UserModel user;
  final bool isLoading;
  final bool hasNotifications;

  static String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final pageBg = theme.base;
    final now = DateTime.now();

    return SkeletonShimmer(
      isLoading: isLoading,
      child: isLoading
          ? SkeletonBox(
              height: 40.h,
              borderRadius: BorderRadius.circular(8.r),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.profile),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          userInitials(user),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(now),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.textMuted,
                            ),
                          ),
                          Text(
                            'Hi, ${userFirstName(user)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.text,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  theme: theme,
                  pageBg: pageBg,
                  icon: Icons.notifications_outlined,
                  semanticsLabel: 'Notifications',
                  showDot: hasNotifications,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.notifications,
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.theme,
    required this.pageBg,
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.showDot = false,
  });

  final DashboardTheme theme;
  final Color pageBg;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: theme.headerBellBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: theme.textMuted,
                ),
              ),
              if (showDot)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppColors.streakOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: pageBg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
