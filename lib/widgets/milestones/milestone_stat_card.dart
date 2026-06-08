import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneStatCard extends StatelessWidget {
  const MilestoneStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return PressableScale(
      onTap: () {},
      scale: 0.98,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: theme.isDark
                    ? AppColors.kpiBarHigh
                    : AppColors.primaryBlue,
                size: 14.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.textMuted,
                fontSize: 10.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.text,
                fontSize: 22.sp,
                height: 1.1,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(height: 6.h),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
