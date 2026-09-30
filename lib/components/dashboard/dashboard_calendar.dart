import 'package:chumley_navigator/components/calendar/calendar_bottom_sheet.dart';
import 'package:chumley_navigator/components/dashboard/compact_schedule_job_card.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/shimmers/schedule_shimmer.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/calendar/aspect_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'package:chumley_navigator/components/dashboard/appointment_schedule_card.dart'
    show JobScheduleCard;

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({
    super.key,
    this.appointments = const [],
    this.ppmTasks = const [],
    this.showHeader = true,
    this.isLoading = false,
  });

  final List<Appointment> appointments;
  final List<PpmJobTask> ppmTasks;

  /// When false, hides the "My Calendar / See All" row (e.g. full-screen page).
  final bool showHeader;

  final bool isLoading;

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

  List<AspectCalendarDay> _buildCalendarDays() =>
      AspectCalendarUtils.buildCalendarDays(_focusedMonth);

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

  bool _hasPpmOn(DateTime date) => false;

  /// Jobs for the focused month, grouped by calendar day (ascending).
  List<_DayScheduleGroup> _monthDaySchedules() {
    final groups = <DateTime, _DayScheduleGroup>{};

    for (final appointment in widget.appointments) {
      final start = appointment.scheduledStart;
      if (start == null) continue;
      if (start.year != _focusedMonth.year ||
          start.month != _focusedMonth.month) {
        continue;
      }
      final key = DateTime(start.year, start.month, start.day);
      final group = groups.putIfAbsent(key, () => _DayScheduleGroup(date: key));
      group.appointments.add(appointment);
    }

    final sorted = groups.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (final group in sorted) {
      group.appointments.sort((a, b) {
        final aStart = a.scheduledStart ?? DateTime(0);
        final bStart = b.scheduledStart ?? DateTime(0);
        return aStart.compareTo(bStart);
      });
    }
    return sorted;
  }

  String _daySectionTitle(DateTime date) {
    final weekday = AspectCalendarUtils.fullWeekDays[date.weekday - 1];
    final month = AspectCalendarUtils.shortMonthNames[date.month - 1];
    if (_isSameDay(date, _today)) {
      return 'Today · $weekday $month ${AspectCalendarUtils.getDayWithSuffix(date.day)}';
    }
    return '$weekday $month ${AspectCalendarUtils.getDayWithSuffix(date.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final calendarDays = _buildCalendarDays();
    final monthSchedules = _monthDaySchedules();
    final scheduleEmpty = monthSchedules.isEmpty;
    final monthLabel =
        '${AspectCalendarUtils.monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader)
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
                          monthLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.sp,
                            color: theme.dashTitle,
                          ),
                        ),
                      ),
                      _NavButton(
                        onTap: _nextMonth,
                        icon: Icon(
                          Icons.arrow_forward,
                          color: theme.dashPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: AspectCalendarUtils.weekDays.map((label) {
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              if ((hasAppointment || hasPpm) &&
                                  day.isCurrentMonth)
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
              '$monthLabel schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: theme.dashHeading,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          if (widget.isLoading)
            CalendarScheduleShimmer(theme: theme)
          else if (scheduleEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.isDark
                    ? theme.dashSurfaceTint
                    : AppColors.surfaceLightBlue,
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
                    'No appointments this month',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Jobs for $monthLabel will appear here day by day.',
                    style: TextStyle(fontSize: 12.sp, color: theme.dashMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              decoration: theme.dashCardDecoration(radius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var g = 0; g < monthSchedules.length; g++) ...[
                    if (g > 0) SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                      child: Text(
                        _daySectionTitle(monthSchedules[g].date),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.dashPrimary,
                        ),
                      ),
                    ),
                    for (
                      var i = 0;
                      i < monthSchedules[g].appointments.length;
                      i++
                    ) ...[
                      if (i > 0)
                        Divider(height: 1, color: theme.dashBorderLight),
                      CompactScheduleJobCard(
                        appointment: monthSchedules[g].appointments[i],
                      ),
                    ],
                    for (
                      var i = 0;
                      i < monthSchedules[g].ppmTasks.length;
                      i++
                    ) ...[
                      if (monthSchedules[g].appointments.isNotEmpty || i > 0)
                        Divider(height: 1, color: theme.dashBorderLight),
                      CompactSchedulePpmCard(
                        task: monthSchedules[g].ppmTasks[i],
                      ),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayScheduleGroup {
  _DayScheduleGroup({required this.date});

  final DateTime date;
  final List<Appointment> appointments = [];
  final List<PpmJobTask> ppmTasks = [];
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
        child: SizedBox(width: 32.w, height: 32.w, child: icon),
      ),
    );
  }
}
