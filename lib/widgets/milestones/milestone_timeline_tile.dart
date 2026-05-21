import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40.w,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: completed ? AppColors.primaryBlue : ElevatedSurface.tintedFill,
                  border: completed
                      ? null
                      : Border.all(
                          color: AppColors.borderLightBlue.withValues(alpha: 0.55),
                          width: 1.25,
                        ),
                  shape: BoxShape.circle,
                  boxShadow: completed
                      ? ElevatedSurface.softShadows(elevation: 0.5)
                      : null,
                ),
                child: Center(
                  child: completed
                      ? Icon(Icons.check_rounded, color: AppColors.white, size: 18.sp)
                      : Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderLightBlue,
                              width: 2,
                            ),
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 44.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.primaryBlue
                        : AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PressableScale(
            onTap: () {},
            scale: 0.99,
            child: ElevatedSurface(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(14.r),
              borderRadius: 16.r,
              borderColor: completed
                  ? AppColors.primaryBlue.withValues(alpha: 0.35)
                  : AppColors.borderLightBlue.withValues(alpha: 0.4),
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
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: completed
                                    ? AppColors.textDarkBlue
                                    : AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: completed
                                    ? AppColors.primaryBlue
                                    : AppColors.borderLightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        trailing,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: completed
                          ? AppColors.textBodyMuted
                          : AppColors.textPlaceholder,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _pill(badgeText, badgeBg, badgeTextColor),
                      SizedBox(width: 6.w),
                      _pill(
                        points,
                        completed
                            ? AppColors.successBackground
                            : AppColors.dividerLight,
                        completed
                            ? AppColors.successText
                            : AppColors.textInactive,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
