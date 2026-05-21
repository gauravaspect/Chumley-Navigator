import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
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
    return PressableScale(
      onTap: () {},
      scale: 0.985,
      child: ElevatedSurface(
        padding: EdgeInsets.all(16.r),
        borderRadius: 18.r,
        borderColor: AppColors.primaryBlue.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.accentLime.withValues(alpha: 0.85),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.4),
                  width: 0.75,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 18.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDarkBlue,
                fontSize: 26.sp,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(height: 8.h),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
