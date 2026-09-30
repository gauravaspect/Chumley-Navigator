import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/job_details/job_detail_page.dart';
import 'package:chumley_navigator/screens/job_details/ppm_job_detail_page.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact appointment row used on weekly + monthly schedule UIs.
class CompactScheduleJobCard extends StatelessWidget {
  const CompactScheduleJobCard({super.key, required this.appointment});

  final Appointment appointment;

  static String jobTitle(Appointment a) {
    if (a.type.isNotEmpty) return a.type;
    final parts = a.title.split(' - ');
    if (parts.isNotEmpty && !parts[0].startsWith('J-')) return parts[0];
    return 'Job';
  }

  static String shortSite(Appointment a) {
    final parts = a.title.split(' - ');
    if (parts.length >= 3) return parts[2];
    if (parts.length >= 2) return parts[1];
    return a.title.isNotEmpty ? a.title : 'Site';
  }

  static String formatTime(DateTime? start) {
    if (start == null) return '--:--';
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  }

  static IconData iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('leak') || t.contains('plumb') || t.contains('water')) {
      return LucideIcons.droplets;
    }
    if (t.contains('boiler') || t.contains('thermal') || t.contains('heat')) {
      return LucideIcons.thermometer;
    }
    if (t.contains('bath') || t.contains('fit') || t.contains('install')) {
      return LucideIcons.hardHat;
    }
    if (t.contains('review') ||
        t.contains('performance') ||
        t.contains('ppm')) {
      return LucideIcons.trendingUp;
    }
    return LucideIcons.briefcase;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final title = jobTitle(appointment);
    final subtitle =
        '${shortSite(appointment)} · ${formatTime(appointment.scheduledStart)}';
    final status = appointment.status.isNotEmpty
        ? appointment.status
        : 'Upcoming';

    return InkWell(
      onTap: () => JobDetailPage.open(context, appointment),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.isDark
                    ? theme.dashSurfaceTint
                    : AppColors.surfaceBlueTint,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                iconForTitle(title),
                size: 18.sp,
                color: theme.dashPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.dashMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            CompactScheduleStatusPill(label: status),
          ],
        ),
      ),
    );
  }
}

/// Compact PPM row matching [CompactScheduleJobCard].
class CompactSchedulePpmCard extends StatelessWidget {
  const CompactSchedulePpmCard({super.key, required this.task});

  final PpmJobTask task;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final title = task.jobType.isNotEmpty ? task.jobType : 'PPM Task';
    final subtitle = task.status.isNotEmpty ? task.status : 'Today';

    return InkWell(
      onTap: () => PpmJobDetailPage.open(context, task),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.isDark
                    ? theme.dashSurfaceTint
                    : AppColors.surfaceBlueTint,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.trendingUp,
                size: 18.sp,
                color: theme.dashPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.dashMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            CompactScheduleStatusPill(
              label: task.status.isNotEmpty ? task.status : 'Upcoming',
            ),
          ],
        ),
      ),
    );
  }
}

class CompactScheduleStatusPill extends StatelessWidget {
  const CompactScheduleStatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.dashSurfaceTint : const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: theme.dashMuted,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: theme.dashTitle,
            ),
          ),
        ],
      ),
    );
  }
}
