import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/calendar/aspect_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobScheduleCard extends StatelessWidget {
  final Appointment appointment;

  const JobScheduleCard({super.key, required this.appointment});

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatTimeRange(DateTime? start) {
    if (start == null) return '--:--';
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    final endHour = (start.hour + 2).toString().padLeft(2, '0');
    return '$h:$m – $endHour:$m';
  }

  String _shortSite(String title) {
    final parts = title.split(' - ');
    if (parts.length >= 3) return parts[2];
    return 'Site Location';
  }

  String _customerName(String title) {
    final parts = title.split(' - ');
    if (parts.length > 1) return parts[1];
    return 'Customer';
  }

  String _jobTask(Appointment a) {
    if (a.type.isNotEmpty) return a.type;
    final parts = a.title.split(' - ');
    if (parts.isNotEmpty && !parts[0].startsWith('J-')) return parts[0];
    return 'EML Emergency Light Test';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF6728C8);
      case 'dispatched':
        return const Color(0xFF2563EB);
      case 'received':
        return const Color(0xFF0891B2);
      case 'in transit':
        return const Color(0xFFF59E0B);
      case 'on site':
        return const Color(0xFF10B981);
      case 'in progress':
        return const Color(0xFF8B5CF6);
      case 'job closure':
        return const Color(0xFF3B82F6);
      case 'visit complete':
      case 'job completed':
        return const Color(0xFF22C55E);
      case 'forms':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return LucideIcons.calendarClock;
      case 'dispatched':
        return LucideIcons.send;
      case 'received':
        return LucideIcons.checkCheck;
      case 'in transit':
        return LucideIcons.navigation;
      case 'on site':
        return LucideIcons.mapPin;
      case 'in progress':
        return LucideIcons.wrench;
      case 'job closure':
        return LucideIcons.clipboardCheck;
      case 'visit complete':
      case 'job completed':
        return LucideIcons.badgeCheck;
      case 'forms':
        return LucideIcons.clipboardList;
      default:
        return LucideIcons.send;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    final start = appointment.scheduledStart;
    final monthStr = start != null ? _shortMonthNames[start.month - 1] : '--';
    final dayStr = start != null
        ? AspectCalendarUtils.getDayWithSuffix(start.day)
        : '--';
    final timeRange = _formatTimeRange(start);

    final jobType = appointment.type.isNotEmpty ? appointment.type : 'Reactive';
    final jobNo = appointment.appointmentNumber.isNotEmpty
        ? appointment.appointmentNumber
        : 'SA-799913';
    final jobTitle = appointment.title.isNotEmpty
        ? appointment.title
        : 'J-410295 - Phil Harris - New Ashby Road - LE11 4EU';
    final jobStatus = appointment.status.isNotEmpty
        ? appointment.status
        : 'Received';
    final siteShort = _shortSite(jobTitle);
    final customer = _customerName(jobTitle);
    final taskLabel = _jobTask(appointment);

    final statusColor = _statusColor(jobStatus);
    final statusIcon = _statusIcon(jobStatus);

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.borderDefault;
    final headerBg = isDark ? AppColors.darkSurfaceDeep : AppColors.primaryBlue;

    final iconBoxBg = isDark
        ? AppColors.darkProgressTrack
        : AppColors.surfaceBlueTint;
    final iconColor = isDark ? AppColors.accentBlue : AppColors.primaryBlue;

    final dateBadgeBg = isDark ? AppColors.darkBase : AppColors.white;
    final dateBadgeBorder = isDark
        ? AppColors.darkBorder
        : AppColors.borderDefault;
    final dateMonColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.primaryBlue;
    final dateDayColor = isDark ? AppColors.darkText : AppColors.textDarkBlue;

    final statBoxBg = isDark ? AppColors.darkBase : AppColors.surfaceLightBlue;
    final statBoxBorder = isDark
        ? AppColors.darkBorder
        : AppColors.borderLightBlue;
    final statLabel = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;
    final statValue = isDark ? AppColors.darkText : AppColors.textDarkBlue;

    final customerRowBg = isDark
        ? AppColors.darkBase
        : AppColors.surfaceBlueTint;
    final customerRowBorder = isDark
        ? AppColors.darkBorder
        : AppColors.borderLightBlue;

    final pillBg = isDark
        ? statusColor.withValues(alpha: 0.15)
        : statusColor.withValues(alpha: 0.10);
    final pillBorder = statusColor.withValues(alpha: isDark ? 0.35 : 0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cardBorder, width: 0.5),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    offset: Offset(0, 2.h),
                    blurRadius: 6.r,
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: headerBg,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBoxBg,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.white.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.briefcase,
                      size: 20.sp,
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.white.withValues(alpha: 0.70),
                            height: 1.1,
                          ),
                        ),
                        Text(
                          jobNo,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.white,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? pillBg
                              : AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark
                                ? pillBorder
                                : AppColors.white.withValues(alpha: 0.35),
                            width: 0.75,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 11.sp,
                              color: isDark ? statusColor : AppColors.white,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              jobStatus,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? statusColor : AppColors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        constraints: BoxConstraints(minWidth: 44.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: dateBadgeBg,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: dateBadgeBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              monthStr.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: dateMonColor,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              dayStr,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: dateDayColor,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Stat Boxes
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
              child: Row(
                children: [
                  _StatBox(
                    theme: theme,
                    icon: LucideIcons.clock,
                    label: 'Time',
                    value: timeRange,
                    boxBg: statBoxBg,
                    border: statBoxBorder,
                    labelColor: statLabel,
                    valueColor: statValue,
                  ),
                  SizedBox(width: 8.w),
                  _StatBox(
                    theme: theme,
                    icon: LucideIcons.mapPin,
                    label: 'Site',
                    value: siteShort,
                    boxBg: statBoxBg,
                    border: statBoxBorder,
                    labelColor: statLabel,
                    valueColor: statValue,
                  ),
                  SizedBox(width: 8.w),
                  _StatBox(
                    theme: theme,
                    icon: LucideIcons.wrench,
                    label: 'Task',
                    value: taskLabel,
                    boxBg: statBoxBg,
                    border: statBoxBorder,
                    labelColor: statLabel,
                    valueColor: statValue,
                  ),
                ],
              ),
            ),
            // Customer row
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: customerRowBg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: customerRowBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 14.sp,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.primaryBlue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        customer,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textDarkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      jobTitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final DashboardTheme theme;
  final IconData icon;
  final String label;
  final String value;
  final Color boxBg;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  const _StatBox({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.boxBg,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 11.sp, color: labelColor),
                SizedBox(width: 4.w),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: labelColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
