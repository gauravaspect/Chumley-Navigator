import 'package:chumley_navigator/components/calendar/calendar_bottom_sheet.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({
    super.key,
    this.appointments = const [],
  });

  final List<Appointment> appointments;

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
      final start = appointment.scheduledStart;
      if (start == null) return false;
      return start.year == selectedDate.year &&
          start.month == selectedDate.month &&
          start.day == selectedDate.day;
    }).toList();

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
                            if (hasAppointment && day.isCurrentMonth)
                              Container(
                                margin: EdgeInsets.only(top: 1.h),
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : theme.dashPrimary,
                                  shape: BoxShape.circle,
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
          if (filteredAppointments.isEmpty)
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
          else
            ...filteredAppointments.map((appointment) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: JobScheduleCard(appointment: appointment),
              );
            }),
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

  static const List<String> _shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorderColor = isDark ? AppColors.darkBorder : AppColors.accentBlue;
    final headerBgColor = isDark ? AppColors.darkSurfaceDeep : AppColors.accentBlue;
    
    final iconBgColor = isDark ? AppColors.darkProgressTrack : AppColors.accentLime;
    final iconBorderColor = isDark ? AppColors.darkBorder : AppColors.primaryBlue;
    final iconColor = isDark ? AppColors.accentBlue : AppColors.primaryBlue;

    final dateBoxBgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final dateBoxBorderColor = isDark ? AppColors.darkBorder : AppColors.primaryBlue;
    final dateBoxMonthColor = isDark ? AppColors.darkTextMuted : AppColors.textDarkBlue;
    final dateBoxDayColor = isDark ? AppColors.darkText : AppColors.textDarkBlue;

    final detailBoxBgColor = isDark ? AppColors.darkSurfaceDeep : AppColors.surfaceLightBlue;
    final detailBoxBorderColor = isDark ? AppColors.darkBorder : AppColors.borderLightBlue;
    final detailLabelColor = isDark ? AppColors.darkTextMuted : AppColors.primaryBlue;
    final detailValueColor = isDark ? AppColors.darkText : AppColors.textDarkBlue;

    final statusPillBgColor = isDark ? AppColors.darkProgressTrack : AppColors.chartFillBlue;
    final statusPillTextColor = isDark ? AppColors.accentBlue : AppColors.primaryBlue;

    final start = appointment.scheduledStart;
    final monthStr = start != null ? _shortMonthNames[start.month - 1] : '--';
    final dayStr = start != null ? _getDayWithSuffix(start.day) : '--';
    final timeStr = _formatTime(start);

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(
            color: cardBorderColor,
            width: 0.5.w,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0x0A323843),
                    offset: Offset(0, 2.h),
                    blurRadius: 4.r,
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: headerBgColor,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          border: Border.all(
                            color: iconBorderColor,
                            width: 0.25.w,
                          ),
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: BriefcaseIcon(
                          size: 20.w,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            jobNo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: AppColors.white,
                              height: 1.1,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 50.w),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: dateBoxBgColor,
                      border: Border.all(
                        color: dateBoxBorderColor,
                        width: 0.5.w,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          monthStr.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 7.sp,
                            color: dateBoxMonthColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          dayStr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: dateBoxDayColor,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Body (Three columns)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // Box 1: Time
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: detailBoxBgColor,
                        border: Border.all(
                          color: detailBoxBorderColor,
                          width: 0.6.w,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              border: Border.all(
                                color: iconBorderColor,
                                width: 0.25.w,
                              ),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: DocumentIcon(
                              size: 12.w,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 7.sp,
                                    color: detailLabelColor,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8.sp,
                                    color: detailValueColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Box 2: Task
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: detailBoxBgColor,
                        border: Border.all(
                          color: detailBoxBorderColor,
                          width: 0.6.w,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              border: Border.all(
                                color: iconBorderColor,
                                width: 0.25.w,
                              ),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: LocationIcon(
                              size: 12.w,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Task',
                                  style: TextStyle(
                                    fontSize: 7.sp,
                                    color: detailLabelColor,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  jobTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8.sp,
                                    color: detailValueColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Box 3: Status
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: detailBoxBgColor,
                        border: Border.all(
                          color: detailBoxBorderColor,
                          width: 0.6.w,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              border: Border.all(
                                color: iconBorderColor,
                                width: 0.25.w,
                              ),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: UserIcon(
                              size: 12.w,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 7.sp,
                                    color: detailLabelColor,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusPillBgColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    jobStatus,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.sp,
                                      color: statusPillTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom gradient indicator line
            Container(
              height: 2.5.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
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

class BriefcaseIcon extends StatelessWidget {
  final double size;
  final Color color;
  const BriefcaseIcon({super.key, this.size = 20, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BriefcasePainter(color),
      ),
    );
  }
}

class _BriefcasePainter extends CustomPainter {
  final Color color;
  _BriefcasePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.scale(scaleX, scaleY);

    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 7, 18, 13),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    final handlePath = Path()
      ..moveTo(8, 7)
      ..lineTo(8, 5)
      ..arcToPoint(const Offset(10, 3), radius: const Radius.circular(2))
      ..lineTo(14, 3)
      ..arcToPoint(const Offset(16, 5), radius: const Radius.circular(2))
      ..lineTo(16, 7);
    canvas.drawPath(handlePath, paint);

    canvas.drawLine(const Offset(12, 12), const Offset(12, 14), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DocumentIcon extends StatelessWidget {
  final double size;
  final Color color;
  const DocumentIcon({super.key, this.size = 12, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DocumentPainter(color),
      ),
    );
  }
}

class _DocumentPainter extends CustomPainter {
  final Color color;
  _DocumentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.scale(scaleX, scaleY);

    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 18, 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    canvas.drawLine(const Offset(9, 8), const Offset(15, 8), paint);
    canvas.drawLine(const Offset(9, 12), const Offset(15, 12), paint);
    canvas.drawLine(const Offset(9, 16), const Offset(12, 16), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LocationIcon extends StatelessWidget {
  final double size;
  final Color color;
  const LocationIcon({super.key, this.size = 12, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LocationPainter(color),
      ),
    );
  }
}

class _LocationPainter extends CustomPainter {
  final Color color;
  _LocationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(12, 2)
      ..cubicTo(8.13, 2, 5, 5.13, 5, 9)
      ..cubicTo(5, 14.25, 12, 22, 12, 22)
      ..cubicTo(12, 22, 19, 14.25, 19, 9)
      ..cubicTo(19, 5.13, 15.87, 2, 12, 2)
      ..close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(const Offset(12, 9), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UserIcon extends StatelessWidget {
  final double size;
  final Color color;
  const UserIcon({super.key, this.size = 12, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _UserPainter(color),
      ),
    );
  }
}

class _UserPainter extends CustomPainter {
  final Color color;
  _UserPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.scale(scaleX, scaleY);

    canvas.drawCircle(const Offset(12, 8), 4, paint);

    final path = Path()
      ..moveTo(4, 20)
      ..cubicTo(4, 16, 8, 14, 12, 14)
      ..cubicTo(16, 14, 20, 16, 20, 20);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
