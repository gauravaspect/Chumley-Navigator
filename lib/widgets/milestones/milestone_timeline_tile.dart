import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneTimelineTile extends StatelessWidget {
  const MilestoneTimelineTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.description,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.points,
    required this.completed,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String description;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final String points;
  final bool completed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final nodeColor =
        completed ? AppColors.brandRed : theme.surfaceDeep;
    final lineColor =
        completed ? AppColors.brandRed : theme.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36.w,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: nodeColor,
                  border: completed
                      ? null
                      : Border.all(color: theme.border, width: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completed
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 16.sp,
                        )
                      : Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.textMuted,
                              width: 1.5,
                            ),
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 40.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: PressableScale(
            onTap: () {},
            scale: 0.99,
            child: Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: theme.border, width: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: completed
                                    ? theme.text
                                    : theme.textMuted,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: completed
                                    ? theme.accent
                                    : theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        trailing,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _pill(badgeText, badgeBg, badgeTextColor),
                      SizedBox(width: 6.w),
                      _pill(
                        points,
                        completed
                            ? (theme.isDark
                                ? AppColors.trendUpBgDark
                                : AppColors.trendUpBgLight)
                            : theme.surfaceDeep,
                        completed
                            ? (theme.isDark
                                ? AppColors.kpiBarHigh
                                : AppColors.trendUpLight)
                            : theme.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
