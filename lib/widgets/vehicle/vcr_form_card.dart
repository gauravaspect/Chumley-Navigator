import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrFormCard extends StatelessWidget {
  const VcrFormCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: child,
    );
  }
}
