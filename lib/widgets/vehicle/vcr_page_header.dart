import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrPageHeader extends StatelessWidget {
  const VcrPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Condition Report (VCR)',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 1.5,
            color: AppColors.textDarkBlue,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Record fleet condition checks clearly, attach evidence quickly, and submit a professional inspection report for your company records.',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            height: 1.35,
            color: AppColors.textBodyMuted,
          ),
        ),
      ],
    );
  }
}
