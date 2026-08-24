import 'package:chumley_navigator/components/calendar/calendar_bottom_sheet.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/pillar/home_job_filter.dart';
import 'package:chumley_navigator/screens/job_details/job_detail_page.dart';
import 'package:chumley_navigator/screens/job_details/ppm_job_detail_page.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({
    super.key,
    this.appointments = const [],
    this.ppmTasks = const [],
  });

  final List<Appointment> appointments;
  final List<PpmJobTask> ppmTasks;

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static const List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  List<_CalendarDay> _buildCalendarDays() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final int leadingBlanks = firstOfMonth.weekday % 7;
    final int trailingBlanks = 6 - (lastOfMonth.weekday % 7);

    final days = <_CalendarDay>[];

    for (int i = leadingBlanks; i > 0; i--) {
      days.add(_CalendarDay(
        date: firstOfMonth.subtract(Duration(days: i)),
        isCurrentMonth: false,
      ));
    }

    for (int d = 1; d <= lastOfMonth.day; d++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month, d),
        isCurrentMonth: true,
      ));
    }

    for (int i = 1; i <= trailingBlanks; i++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month + 1, i),
        isCurrentMonth: false,
      ));
    }

    return days;
  }

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  bool _isToday(DateTime date) => date == _today;
  bool _isSelected(DateTime date) =>
      _selectedDate != null && date == _selectedDate;

  bool _hasAppointment(DateTime date) {
    for (final appointment in widget.appointments) {
      final start = appointment.scheduledStart;
      if (start == null) continue;
      if (start.year == date.year &&
          start.month == date.month &&
          start.day == date.day) {
        return true;
      }
    }
    return false;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasPpmOn(DateTime date) =>
      widget.ppmTasks.isNotEmpty && _isSameDay(date, _today);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final calendarDays = _buildCalendarDays();

    final selectedDate = _selectedDate ?? _today;
    final isSelectedToday = selectedDate.year == _today.year &&
        selectedDate.month == _today.month &&
        selectedDate.day == _today.day;

    final scheduleTitle = isSelectedToday
        ? "Today's Schedule"
        : "Schedule for ${_shortMonthNames[selectedDate.month - 1]} ${_getDayWithSuffix(selectedDate.day)}";

    final filteredAppointments = widget.appointments.where((appointment) {
      return HomeJobFilter.showOnHome(
        status: appointment.status,
        scheduledStart: appointment.scheduledStart,
        selectedDay: selectedDate,
        today: _today,
      );
    }).toList();

    final filteredPpmTasks =
        _isSameDay(selectedDate, _today) ? widget.ppmTasks : const <PpmJobTask>[];
    final scheduleEmpty =
        filteredAppointments.isEmpty && filteredPpmTasks.isEmpty;

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Calendar',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashHeading,
                ),
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.90,
                      child: const DashboardBottomSheet(),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: theme.dashPrimaryCalendar,
                  ),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: theme.dashSurfaceTint,
              border: Border.all(color: theme.dashBorderLight, width: 1.25),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: theme.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.textShadow.withValues(alpha: 0.04),
                        offset: Offset(0, 2.h),
                        blurRadius: 8.r,
                      ),
                    ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      onTap: _prevMonth,
                      icon: Icon(Icons.arrow_back, color: theme.dashPrimary),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        key: ValueKey(
                          '${_focusedMonth.year}-${_focusedMonth.month}',
                        ),
                        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19.sp,
                          color: theme.dashTitle,
                        ),
                      ),
                    ),
                    _NavButton(
                      onTap: _nextMonth,
                      icon: Icon(Icons.arrow_forward, color: theme.dashPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: _weekDays.map((label) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: theme.dashPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 0,
                    childAspectRatio: 32 / 36,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (_, index) {
                    final day = calendarDays[index];
                    final isToday = _isToday(day.date);
                    final isSelected = _isSelected(day.date);
                    final hasAppointment = _hasAppointment(day.date);
                    final hasPpm = _hasPpmOn(day.date);

                    Color bgColor = Colors.transparent;
                    Color textColor = day.isCurrentMonth
                        ? theme.dashCalendarDay
                        : theme.dashCalendarDisabled;

                    if (isToday && !isSelected) bgColor = theme.dashTodayBg;

                    final decoration = isSelected
                        ? BoxDecoration(
                            color: theme.dashPrimary,
                            borderRadius: BorderRadius.circular(999.r),
                          )
                        : BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(999.r),
                          );
                    if (isSelected) textColor = AppColors.white;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day.date),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: 32.w,
                              height: 28.h,
                              decoration: decoration,
                              alignment: Alignment.center,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: textColor,
                                ),
                                child: Text('${day.date.day}'),
                              ),
                            ),
                            if ((hasAppointment || hasPpm) && day.isCurrentMonth)
                              Padding(
                                padding: EdgeInsets.only(top: 1.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasAppointment)
                                      Container(
                                        width: 4.w,
                                        height: 4.w,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.white
                                              : theme.dashPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (hasAppointment && hasPpm)
                                      SizedBox(width: 3.w),
                                    if (hasPpm)
                                      Container(
                                        width: 4.w,
                                        height: 4.w,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.ppmAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              scheduleTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: theme.dashHeading,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          if (scheduleEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.isDark ? theme.dashSurfaceTint : AppColors.surfaceLightBlue,
                border: Border.all(color: theme.dashBorderLight, width: 1.25),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.dashMuted,
                    size: 32.r,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No appointments scheduled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap on another day to see its schedule.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.dashMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            ...filteredAppointments.map((appointment) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () => JobDetailPage.open(context, appointment),
                  child: JobScheduleCard(appointment: appointment),
                ),
              );
            }),
            ...filteredPpmTasks.map((task) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () => PpmJobDetailPage.open(context, task),
                  child: PpmJobScheduleCard(task: task, date: _today),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CalendarDay {
  const _CalendarDay({required this.date, required this.isCurrentMonth});
  final DateTime date;
  final bool isCurrentMonth;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.onTap, required this.icon});
  final VoidCallback onTap;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: icon,
        ),
      ),
    );
  }
}

class JobScheduleCard extends StatelessWidget {
  final Appointment appointment;

  const JobScheduleCard({
    super.key,
    required this.appointment,
  });

  // ── Helpers ────────────────────────────────────────────────────

  static const List<String> _shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  String _formatTimeRange(DateTime? start) {
    if (start == null) return '--:--';
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    final endHour = (start.hour + 2).toString().padLeft(2, '0');
    return '$h:$m – $endHour:$m';
  }

  // Return a short version of the site from the job title string
  // "J-410295 - Phil Harris - New Ashby Road - LE11 4EU" → "New Ashby Road"
  String _shortSite(String title) {
    final parts = title.split(' - ');
    if (parts.length >= 3) return parts[2];
    return title;
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

  // Status → colour mapping  (mirrors the 8-state lifecycle from JobDetailPage)
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':   return const Color(0xFF6728C8);
      case 'dispatched':  return const Color(0xFF2563EB);
      case 'received':    return const Color(0xFF0891B2);
      case 'in transit':  return const Color(0xFFF59E0B);
      case 'on site':     return const Color(0xFF10B981);
      case 'in progress': return const Color(0xFF8B5CF6);
      case 'forms':       return const Color(0xFFEC4899);
      case 'job completed': return const Color(0xFF22C55E);
      default:            return const Color(0xFF2563EB); // fallback = blue
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':     return LucideIcons.calendarClock;
      case 'dispatched':    return LucideIcons.send;
      case 'received':      return LucideIcons.checkCheck;
      case 'in transit':    return LucideIcons.navigation;
      case 'on site':       return LucideIcons.mapPin;
      case 'in progress':   return LucideIcons.wrench;
      case 'forms':         return LucideIcons.clipboardList;
      case 'job completed': return LucideIcons.badgeCheck;
      default:              return LucideIcons.send;
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    final start     = appointment.scheduledStart;
    final monthStr  = start != null ? _shortMonthNames[start.month - 1] : '--';
    final dayStr    = start != null ? _getDayWithSuffix(start.day) : '--';
    final timeRange = _formatTimeRange(start);

    final jobType  = appointment.type.isNotEmpty ? appointment.type : 'Reactive';
    final jobNo    = appointment.appointmentNumber.isNotEmpty
        ? appointment.appointmentNumber
        : 'SA-799913';
    final jobTitle  = appointment.title.isNotEmpty
        ? appointment.title
        : 'J-410295 - Phil Harris - New Ashby Road - LE11 4EU';
    final jobStatus = appointment.status.isNotEmpty ? appointment.status : 'Received';
    final siteShort = _shortSite(jobTitle);
    final customer  = _customerName(jobTitle);
    final taskLabel = _jobTask(appointment);

    final statusColor = _statusColor(jobStatus);
    final statusIcon  = _statusIcon(jobStatus);

    // ── Theme tokens ──────────────────────────────────────────────
    final cardBg      = isDark ? AppColors.darkSurface          : AppColors.white;
    final cardBorder  = isDark ? AppColors.darkBorder           : AppColors.borderDefault;
    final headerBg    = isDark ? AppColors.darkSurfaceDeep      : AppColors.primaryBlue;

    final iconBoxBg   = isDark ? AppColors.darkProgressTrack    : AppColors.surfaceBlueTint;
    final iconColor   = isDark ? AppColors.accentBlue           : AppColors.primaryBlue;

    final dateBadgeBg       = isDark ? AppColors.darkBase    : AppColors.white;
    final dateBadgeBorder   = isDark ? AppColors.darkBorder  : AppColors.borderDefault;
    final dateMonColor      = isDark ? AppColors.darkTextMuted  : AppColors.primaryBlue;
    final dateDayColor      = isDark ? AppColors.darkText       : AppColors.textDarkBlue;

    final statBoxBg     = isDark ? AppColors.darkBase           : AppColors.surfaceLightBlue;
    final statBoxBorder = isDark ? AppColors.darkBorder         : AppColors.borderLightBlue;
    final statLabel     = isDark ? AppColors.darkTextMuted      : AppColors.textSecondary;
    final statValue     = isDark ? AppColors.darkText           : AppColors.textDarkBlue;

    final customerRowBg     = isDark ? AppColors.darkBase       : AppColors.surfaceBlueTint;
    final customerRowBorder = isDark ? AppColors.darkBorder     : AppColors.borderLightBlue;

    // Status pill colours
    final pillBg     = isDark
        ? statusColor.withValues(alpha: 0.15)
        : statusColor.withValues(alpha: 0.10);
    final pillBorder = statusColor.withValues(alpha: isDark ? 0.35 : 0.25);
    // On the blue header (light) the pill has white text; on dark surface use colour

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

            // ── HEADER ─────────────────────────────────────────────
            Container(
              color: headerBg,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // Briefcase icon box
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
                    child: Icon(LucideIcons.briefcase, size: 20.sp, color: iconColor),
                  ),
                  SizedBox(width: 12.w),

                  // Job type + number
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
                            color: isDark ? AppColors.darkText : AppColors.white,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status pill + date badge — right side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status pill
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isDark ? pillBg : AppColors.white.withValues(alpha: 0.15),
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

                      // Date badge
                      Container(
                        constraints: BoxConstraints(minWidth: 44.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: dateBadgeBg,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: dateBadgeBorder, width: 0.5),
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

            // ── THREE STAT BOXES ────────────────────────────────────
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
                    boxBorder: statBoxBorder,
                    iconBg: iconBoxBg,
                    iconColor: iconColor,
                    labelColor: statLabel,
                    valueColor: statValue,
                  ),
                  SizedBox(width: 8.w),
                  _StatBox(
                    theme: theme,
                    icon: LucideIcons.fileText,
                    label: 'Task',
                    value: taskLabel,
                    boxBg: statBoxBg,
                    boxBorder: statBoxBorder,
                    iconBg: iconBoxBg,
                    iconColor: iconColor,
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
                    boxBorder: statBoxBorder,
                    iconBg: iconBoxBg,
                    iconColor: iconColor,
                    labelColor: statLabel,
                    valueColor: statValue,
                  ),
                ],
              ),
            ),

            // ── CUSTOMER ROW ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: customerRowBg,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: customerRowBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.user,
                        size: 15.sp, color: iconColor),
                    SizedBox(width: 8.w),
                    Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: statLabel,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        customer,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statValue,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(LucideIcons.chevronRight,
                        size: 13.sp, color: statLabel),
                  ],
                ),
              ),
            ),

            // ── BOTTOM STRIPE ───────────────────────────────────────
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.darkBorder,
                          AppColors.accentBlue,
                          AppColors.darkBorder,
                        ]
                      : [
                          AppColors.accentBlue,
                          AppColors.accentBlueGradientEnd,
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
  final Color boxBorder;
  final Color iconBg;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const _StatBox({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.boxBg,
    required this.boxBorder,
    required this.iconBg,
    required this.iconColor,
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
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: boxBorder, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.18),
                  width: 0.5,
                ),
              ),
              child: Icon(icon, size: 12.sp, color: iconColor),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: labelColor,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value.isNotEmpty ? value : '—',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PpmJobScheduleCard extends StatelessWidget {
  const PpmJobScheduleCard({
    super.key,
    required this.task,
    required this.date,
  });

  final PpmJobTask task;
  final DateTime date;

  static const List<String> _shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  String _formatHour(int hour) =>
      '${hour.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;
    final monthStr = _shortMonthNames[date.month - 1];
    final dayStr = _getDayWithSuffix(date.day);
    final timeRange =
        '${_formatHour(task.startHour)} – ${_formatHour(task.endHour)}';
    final jobType =
        task.jobType.isNotEmpty ? task.jobType : 'PPM';
    final jobNo = task.appointmentNumber.isNotEmpty
        ? task.appointmentNumber
        : task.id;
    final subject =
        task.subject.isNotEmpty ? task.subject : 'PPM Job';
    final status =
        task.status.isNotEmpty ? task.status : 'Scheduled';

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorder = AppColors.ppmAccent.withValues(alpha: isDark ? 0.45 : 0.35);
    final headerBg = isDark ? const Color(0xFF134E4A) : AppColors.ppmAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cardBorder, width: 1),
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
                      color: isDark
                          ? AppColors.darkProgressTrack
                          : AppColors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      LucideIcons.clipboardCheck,
                      size: 20.sp,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'PPM',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              jobType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: AppColors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          jobNo,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.white,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBase : AppColors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              monthStr.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ppmAccent,
                              ),
                            ),
                            Text(
                              dayStr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.textDarkBlue,
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
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 14.sp,
                        color: AppColors.ppmAccent,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.dashMuted,
                        ),
                      ),
                      if (task.postcode.isNotEmpty) ...[
                        SizedBox(width: 12.w),
                        Icon(
                          LucideIcons.mapPin,
                          size: 14.sp,
                          color: AppColors.ppmAccent,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          task.postcode,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.dashMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (task.workTypeName.isNotEmpty ||
                      task.tradeGroup.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      [
                        if (task.tradeGroup.isNotEmpty) task.tradeGroup,
                        if (task.workTypeName.isNotEmpty) task.workTypeName,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.dashMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

