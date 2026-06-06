import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningsDetailScreen extends StatelessWidget {
  const EarningsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: DashboardPalette.heading,
        title: Text(
          'Earnings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'Detailed earnings breakdown will appear here.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textBodyMuted,
          ),
        ),
      ),
    );
  }
}
