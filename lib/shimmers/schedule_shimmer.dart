import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Placeholder rows for the schedule card while appointments load.
class ScheduleCardShimmer extends StatelessWidget {
  const ScheduleCardShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (_) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: ThemedShimmerBox(theme: theme, height: 52.h, radius: 16),
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        ThemedShimmerBox(theme: theme, height: 36.h, radius: 12),
        SizedBox(height: 12.h),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          ThemedShimmerBox(theme: theme, height: 56.h, radius: 12),
        ],
      ],
    );
  }
}

/// Placeholder for the calendar month schedule list while loading.
class CalendarScheduleShimmer extends StatelessWidget {
  const CalendarScheduleShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: ThemedShimmerBox(
              theme: theme,
              height: 14.h,
              width: 120.w,
              radius: 6,
            ),
          ),
          SizedBox(height: 8.h),
          ThemedShimmerBox(theme: theme, height: 64.h, radius: 12),
        ],
      ],
    );
  }
}
