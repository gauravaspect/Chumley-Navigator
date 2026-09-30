import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobDetailsCard extends StatelessWidget {
  final DashboardTheme theme;
  final Appointment appointment;
  final String jobNo;
  final String customerName;
  final String jobTitleDescription;

  const JobDetailsCard({
    super.key,
    required this.theme,
    required this.appointment,
    required this.jobNo,
    required this.customerName,
    required this.jobTitleDescription,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Appointment ID', jobNo),
      ('Type', appointment.type.isNotEmpty ? appointment.type : 'Reactive'),
      ('Customer', customerName),
      ('Description', jobTitleDescription),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.border, width: 0.5),
          boxShadow: theme.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isDescription = item.$1 == 'Description';
            final labelStyle = TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            );
            final valueStyle = TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: theme.text,
              height: 1.35,
            );
            final valueText = item.$2.isNotEmpty ? item.$2 : '—';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0)
                  Divider(height: 14.h, color: theme.border, thickness: 0.5),
                if (isDescription)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: labelStyle),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.isDark
                              ? theme.surfaceDeep
                              : const Color(0xFFE3E9F2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          appointment.workType.isNotEmpty
                              ? appointment.workType
                              : (appointment.title.isNotEmpty
                                    ? appointment.title
                                    : jobTitleDescription),
                          style: valueStyle,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: Text(item.$1, style: labelStyle),
                      ),
                      const Spacer(),
                      Expanded(child: Text(valueText, style: valueStyle)),
                    ],
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
