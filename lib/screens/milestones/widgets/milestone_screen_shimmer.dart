import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneScreenShimmer extends StatelessWidget {
  final DashboardTheme theme;
  const MilestoneScreenShimmer({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 72 + 28,
        bottom: 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemedShimmerBox(theme: theme, height: 22.h, width: 120.w),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 74.h),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 74.h),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 74.h),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ThemedShimmerBox(theme: theme, height: 120.h),
          SizedBox(height: 14.h),
          ThemedShimmerBox(theme: theme, height: 18.h, width: 100.w),
          SizedBox(height: 4.h),
          ThemedShimmerBox(theme: theme, height: 14.h, width: 150.w),
          SizedBox(height: 8.h),
          Row(
            children: [
              ThemedShimmerBox(
                theme: theme,
                height: 34.h,
                width: 60.w,
                radius: 17,
              ),
              SizedBox(width: 8.w),
              ThemedShimmerBox(
                theme: theme,
                height: 34.h,
                width: 80.w,
                radius: 17,
              ),
              SizedBox(width: 8.w),
              ThemedShimmerBox(
                theme: theme,
                height: 34.h,
                width: 80.w,
                radius: 17,
              ),
              SizedBox(width: 8.w),
              ThemedShimmerBox(
                theme: theme,
                height: 34.h,
                width: 80.w,
                radius: 17,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ThemedShimmerBox(theme: theme, height: 160.h),
          SizedBox(height: 10.h),
          ThemedShimmerBox(theme: theme, height: 160.h),
        ],
      ),
    );
  }
}
