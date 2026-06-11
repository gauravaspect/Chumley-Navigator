import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrPageHeader extends StatelessWidget {
  const VcrPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Condition Report (VCR)',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashHeading,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Record fleet condition checks clearly, attach evidence quickly, and submit a professional inspection report for your company records.',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            height: 1.35,
            color: theme.textMuted,
          ),
        ),
      ],
    );
  }
}
