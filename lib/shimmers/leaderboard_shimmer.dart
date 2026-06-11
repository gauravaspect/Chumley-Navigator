import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Placeholder matching the leaderboard podium + table layout.
class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ThemedShimmerBox(theme: theme, height: 175.h, radius: 16),
        SizedBox(height: 10.h),
        ThemedShimmerBox(theme: theme, height: 36.h, radius: 10),
        SizedBox(height: 6.h),
        ...List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: ThemedShimmerBox(
              theme: theme,
              height: 40.h,
              radius: 10,
              deep: true,
            ),
          ),
        ),
      ],
    );
  }
}
