import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Placeholder matching the profile hero, details, and stats grid.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedShimmerBox(theme: theme, height: 160.h, radius: 12),
        SizedBox(height: 10.h),
        ThemedShimmerBox(
          theme: theme,
          height: 12.h,
          width: 64.w,
          radius: 4,
        ),
        SizedBox(height: 8.h),
        ThemedShimmerBox(theme: theme, height: 44.h, radius: 10),
        SizedBox(height: 6.h),
        ThemedShimmerBox(theme: theme, height: 44.h, radius: 10),
        SizedBox(height: 10.h),
        ThemedShimmerBox(
          theme: theme,
          height: 12.h,
          width: 48.w,
          radius: 4,
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 1.12,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (_, index) => ThemedShimmerBox(
            theme: theme,
            height: 96.h,
            radius: 10,
            deep: true,
          ),
        ),
        SizedBox(height: 6.h),
        ThemedShimmerBox(theme: theme, height: 56.h, radius: 10, deep: true),
        SizedBox(height: 6.h),
        ThemedShimmerBox(theme: theme, height: 72.h, radius: 12),
        SizedBox(height: 10.h),
        ThemedShimmerBox(theme: theme, height: 40.h, radius: 10),
        SizedBox(height: 24.h),
      ],
    );
  }
}
