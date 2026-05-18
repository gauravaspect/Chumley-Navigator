import 'package:flutter/material.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningCard extends StatelessWidget {
  const EarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accentBlue, width: 1.25),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 4.h),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: Label + Amount ───────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '£1,312.00',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                  color: AppColors.textDarkBlue,
                  height: 1.2,
                ),
              ),
            ],
          ),

          // ── Right: Badge ───────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: AppColors.successText,
                  fontWeight: FontWeight.w900,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '+6%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
