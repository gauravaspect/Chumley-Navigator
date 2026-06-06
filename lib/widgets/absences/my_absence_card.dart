import 'package:chumley_navigator/utils/dashboard_theme.dart';
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
    final theme = DashboardTheme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dashCardBorderSoft, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: theme.dashSurfaceTint,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.event_busy_rounded,
              color: theme.dashPrimary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.reason,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.dashTitle,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  record.dateRange,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.dashSubtitle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: record.statusBackground,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
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
  const MyAbsencesSection({
    super.key,
    required this.records,
    this.loadFailed = false,
  });

  final List<MyAbsenceRecord> records;
  final bool loadFailed;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Absences',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: theme.dashHeading,
          ),
        ),
        SizedBox(height: 12.h),
        if (loadFailed)
          Text(
            'Could not load your absences.',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.accent,
            ),
          )
        else if (records.isEmpty)
          Text(
            'No absences yet.',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.dashSubtitle,
            ),
          )
        else
          ...records.map((r) => MyAbsenceCard(record: r)),
      ],
    );
  }
}
