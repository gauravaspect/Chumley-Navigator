import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatGridCard extends StatelessWidget {
  const ProfileStatGridCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.97,
      child: ElevatedSurface(
        padding: EdgeInsets.all(18.r),
        borderRadius: 18.r,
        borderColor: AppColors.textDarkBlue.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.highlightYellow.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.textDarkBlue.withValues(alpha: 0.15),
                      width: 0.75,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.textDarkBlue,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppColors.textDarkBlue,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              body,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.2,
                color: AppColors.textDarkBlue,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
