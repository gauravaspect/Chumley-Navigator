import 'package:chumley_navigator/components/calendar/calendar_bottom_sheet.dart';
import 'package:chumley_navigator/utils/colors.dart';
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

  /// Returns all cells to display: trailing days of prev month,
  /// all days of focused month, leading days of next month.
  List<_CalendarDay> _buildCalendarDays() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastOfMonth  = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // Sunday = 0 in DateTime.weekday is 7, so:
    final int leadingBlanks = firstOfMonth.weekday % 7; // Sun→0, Mon→1 … Sat→6
    final int trailingBlanks = 6 - (lastOfMonth.weekday % 7);

    final days = <_CalendarDay>[];

    // Prev-month overflow
    for (int i = leadingBlanks; i > 0; i--) {
      days.add(_CalendarDay(
        date: firstOfMonth.subtract(Duration(days: i)),
        isCurrentMonth: false,
      ));
    }

    // Current month
    for (int d = 1; d <= lastOfMonth.day; d++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month, d),
        isCurrentMonth: true,
      ));
    }

    // Next-month overflow
    for (int i = 1; i <= trailingBlanks; i++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month + 1, i),
        isCurrentMonth: false,
      ));
    }

    return days;
  }

  void _prevMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  bool _isToday(DateTime date) => date == _today;
  bool _isSelected(DateTime date) =>
      _selectedDate != null && date == _selectedDate;

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays();

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Calendar',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlueDark,
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
                    color: AppColors.primaryBlueCalendar,
                  ),
                ),
              ),
            ],
          ),

          // ── Calendar card ──────────────────────────────────────
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              border: Border.all(color: AppColors.borderLightBlue, width: 1.25),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textShadow.withOpacity(0.04),
                  offset: Offset(0, 2.h),
                  blurRadius: 4.r,
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Month navigation ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      onTap: _prevMonth,
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text(
                      '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19.sp,
                        color: AppColors.textDarkBlue,
                      ),
                    ),
                    _NavButton(
                      onTap: _nextMonth,
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // ── Weekday headers ──────────────────────────────
                Row(
                  children: _weekDays.map((label) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 8.h),

                // ── Day grid ─────────────────────────────────────
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 0,
                    childAspectRatio: 32 / 28, // mirrors w-[32px] h-[28px]
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (_, index) {
                    final day = calendarDays[index];
                    final isToday    = _isToday(day.date);
                    final isSelected = _isSelected(day.date);

                    Color bgColor     = Colors.transparent;
                    Color textColor   = day.isCurrentMonth
                        ? AppColors.textCalendarDay
                        : AppColors.textCalendarDisabled;

                    if (isToday)    bgColor = AppColors.borderLightBlue;
                    if (isSelected) bgColor = AppColors.primaryBlue;
                    if (isSelected) textColor = Colors.white;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day.date),
                      child: Center(
                        child: Container(
                          width: 32.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.date.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _CalendarDay {
  const _CalendarDay({required this.date, required this.isCurrentMonth});
  final DateTime date;
  final bool isCurrentMonth;
}

// ── Navigation button ─────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({required this.onTap, required this.icon});
  final VoidCallback onTap;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: icon,
      ),
    );
  }
}

