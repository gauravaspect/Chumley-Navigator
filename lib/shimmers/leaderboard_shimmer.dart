import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Placeholder matching standing card + podium + ranking list.
class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedShimmerBox(theme: theme, height: 96.h, radius: 22),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ThemedShimmerBox(theme: theme, height: 140.h, radius: 16),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ThemedShimmerBox(theme: theme, height: 170.h, radius: 16),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ThemedShimmerBox(theme: theme, height: 140.h, radius: 16),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: ThemedShimmerBox(theme: theme, height: 18.h, radius: 6),
            ),
            SizedBox(width: 80.w),
            ThemedShimmerBox(
              theme: theme,
              width: 64.w,
              height: 14.h,
              radius: 6,
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ThemedShimmerBox(theme: theme, height: 220.h, radius: 18),
      ],
    );
  }
}
