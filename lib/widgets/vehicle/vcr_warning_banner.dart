import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrWarningBanner extends StatelessWidget {
  const VcrWarningBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.vcrWarningBackground.withValues(
          alpha: theme.isDark ? 0.35 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.vcrWarningBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: const BoxDecoration(
              color: AppColors.vcrWarningIcon,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.35,
                color: theme.isDark ? theme.text : AppColors.vcrWarningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
