import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAbsenceRecord {
  const MyAbsenceRecord({
    required this.reason,
    required this.dateRange,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
  });

  final String reason;
  final String dateRange;
  final String status;
  final Color statusColor;
  final Color statusBackground;
}

class MyAbsenceCard extends StatelessWidget {
  const MyAbsenceCard({super.key, required this.record});

  final MyAbsenceRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.borderLightBlue.withValues(alpha: 0.45),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.chartFillBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: AppColors.primaryBlue,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.reason,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  record.dateRange,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBodyMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: record.statusBackground,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: record.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAbsencesSection extends StatelessWidget {
  const MyAbsencesSection({super.key, required this.records});

  final List<MyAbsenceRecord> records;

  @override
  Widget build(BuildContext context) {
    return AbsenceFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Absences',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkBlue,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Recent requests and approvals',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textBodyMuted,
            ),
          ),
          SizedBox(height: 14.h),
          ...records.map((r) => MyAbsenceCard(record: r)),
        ],
      ),
    );
  }
}
