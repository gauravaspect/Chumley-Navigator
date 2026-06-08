import 'package:chumley_navigator/components/calendar/calendar_bottom_sheet.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

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

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final calendarDays = _buildCalendarDays();

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
                    childAspectRatio: 32 / 28,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (_, index) {
                    final day = calendarDays[index];
                    final isToday = _isToday(day.date);
                    final isSelected = _isSelected(day.date);

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
                        child: AnimatedContainer(
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
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
