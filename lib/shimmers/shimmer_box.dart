import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Theme-aware shimmer block used by screen skeletons.
class ThemedShimmerBox extends StatelessWidget {
  const ThemedShimmerBox({
    super.key,
    required this.theme,
    required this.height,
    this.width,
    this.radius = 12,
    this.deep = false,
  });

  final DashboardTheme theme;
  final double height;
  final double? width;
  final double radius;
  final bool deep;

  @override
  Widget build(BuildContext context) {
    return ShimmerPlaceholder(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius.r),
      baseColor: deep ? theme.shimmerBaseDeep : theme.shimmerBase,
      highlightColor: theme.shimmerHighlight,
    );
  }
}
