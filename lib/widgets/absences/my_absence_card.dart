import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyAbsenceRecord {
  const MyAbsenceRecord({
    required this.reason,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    this.icon = LucideIcons.calendar,
  });

  final String reason;
  final String subtitle;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final IconData icon;
}

class MyAbsenceCard extends StatelessWidget {
  const MyAbsenceCard({super.key, required this.record});

  final MyAbsenceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFE9EDF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              record.icon,
              color: theme.dashSubtitle,
              size: 19.sp,
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
                    fontWeight: FontWeight.w700,
                    color: theme.dashHeading,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  record.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.dashMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10.w, 5.h, 12.w, 5.h),
            decoration: BoxDecoration(
              color: record.statusBackground,
              borderRadius: BorderRadius.circular(500.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: record.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  record.status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: record.statusColor,
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

class MyAbsencesSection extends StatelessWidget {
  const MyAbsencesSection({
    super.key,
    required this.records,
    this.loadFailed = false,
    this.title = 'Pending requests',
  });

  final List<MyAbsenceRecord> records;
  final bool loadFailed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final hairline =
        theme.isDark ? theme.dashBorderLight : const Color(0xFFE2E7F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
            decoration: theme.dashCardDecoration(radius: 20),
            child: Text(
              'No pending requests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.dashSubtitle,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: theme.dashCardDecoration(radius: 20),
            child: Column(
              children: [
                for (var i = 0; i < records.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Divider(height: 1, color: hairline),
                    ),
                  MyAbsenceCard(record: records[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Maps absence type strings to a prototype-style icon.
IconData absenceTypeIcon(String type) {
  final t = type.toLowerCase();
  if (t.contains('sick') || t.contains('unplanned')) {
    return LucideIcons.thermometer;
  }
  if (t.contains('late') || t.contains('early') || t.contains('clock')) {
    return LucideIcons.clock;
  }
  if (t.contains('mot') || t.contains('garage') || t.contains('material')) {
    return LucideIcons.car;
  }
  if (t.contains('holiday') || t.contains('absence')) {
    return LucideIcons.calendar;
  }
  return LucideIcons.calendar;
}

Color absenceStatusFg(String status, {required bool approved}) {
  if (approved || status.toLowerCase() == 'approved') {
    return const Color(0xFF15803D);
  }
  if (status.toLowerCase() == 'rejected' ||
      status.toLowerCase() == 'cancelled') {
    return AppColors.errorText;
  }
  return AppColors.primaryBlue;
}

Color absenceStatusBg(String status, {required bool approved}) {
  if (approved || status.toLowerCase() == 'approved') {
    return const Color(0xFFE9F8EF);
  }
  if (status.toLowerCase() == 'rejected' ||
      status.toLowerCase() == 'cancelled') {
    return AppColors.errorBackground;
  }
  return const Color(0xFFD8E6FC);
}

String absenceStatusLabel(String status, {required bool approved}) {
  if (approved || status.toLowerCase() == 'approved') return 'Approved';
  if (status.toLowerCase() == 'rejected') return 'Rejected';
  if (status.toLowerCase() == 'cancelled') return 'Cancelled';
  return 'In review';
}
