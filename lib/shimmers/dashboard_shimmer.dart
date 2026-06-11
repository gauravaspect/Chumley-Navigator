import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-body placeholder matching the dashboard section layout.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          ThemedShimmerBox(theme: theme, height: 168.h, radius: 16),
          SizedBox(height: 14.h),
          ThemedShimmerBox(theme: theme, height: 88.h, radius: 16),
          SizedBox(height: 14.h),
          ThemedShimmerBox(theme: theme, height: 320.h, radius: 20),
          SizedBox(height: 14.h),
          ThemedShimmerBox(
            theme: theme,
            height: 28.h,
            width: 220.w,
            radius: 8,
          ),
          SizedBox(height: 8.h),
          ThemedShimmerBox(
            theme: theme,
            height: 16.h,
            width: 280.w,
            radius: 6,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 200.h, radius: 18),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 200.h, radius: 18),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 200.h, radius: 18),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ThemedShimmerBox(theme: theme, height: 200.h, radius: 18),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ThemedShimmerBox(theme: theme, height: 220.h, radius: 16),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
