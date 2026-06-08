import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AbsenceDayMark { absence, availability }

class AbsenceCalendar extends StatefulWidget {
  const AbsenceCalendar({
    super.key,
    this.markedDays = const {},
    this.onDateSelected,
    this.initialSelected,
  });

  final Map<DateTime, AbsenceDayMark> markedDays;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? initialSelected;

  @override
  State<AbsenceCalendar> createState() => _AbsenceCalendarState();
}

class _AbsenceCalendarState extends State<AbsenceCalendar> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _selectedDate = widget.initialSelected ?? _today;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<_CalendarDay> _buildDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final leading = first.weekday % 7;
    final trailing = 6 - (last.weekday % 7);
    final days = <_CalendarDay>[];

    for (var i = leading; i > 0; i--) {
      days.add(_CalendarDay(
        date: first.subtract(Duration(days: i)),
        isCurrentMonth: false,
      ));
    }
    for (var d = 1; d <= last.day; d++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month, d),
        isCurrentMonth: true,
      ));
    }
    for (var i = 1; i <= trailing; i++) {
      days.add(_CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month + 1, i),
        isCurrentMonth: false,
      ));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final days = _buildDays();

    return AbsenceFormCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                color: theme.dashTitle,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
                }),
              ),
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              _NavButton(
                color: theme.dashTitle,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  );
                }),
                isForward: true,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.dashPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (_, index) {
              final day = days[index];
              final normalized = _normalize(day.date);
              final isToday = normalized == _today;
              final isSelected = _selectedDate != null &&
                  normalized == _normalize(_selectedDate!);

              Color bgColor = Colors.transparent;
              Color textColor = day.isCurrentMonth
                  ? theme.dashCalendarDay
                  : theme.dashCalendarDisabled;
              FontWeight fontWeight = FontWeight.w600;

              late final BoxDecoration decoration;
              if (isSelected && day.isCurrentMonth) {
                decoration = BoxDecoration(
                  color: theme.dashPrimary,
                  shape: BoxShape.circle,
                );
                textColor = AppColors.white;
              } else {
                decoration = BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                );
              }

              if (isToday && day.isCurrentMonth && !isSelected) {
                textColor = theme.dashPrimary;
                fontWeight = FontWeight.w700;
              }

              return GestureDetector(
                onTap: day.isCurrentMonth
                    ? () {
                        setState(() => _selectedDate = normalized);
                        widget.onDateSelected?.call(normalized);
                      }
                    : null,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 28.w,
                    height: 28.w,
                    alignment: Alignment.center,
                    decoration: decoration,
                    child: Text(
                      '${day.date.day}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: fontWeight,
                        color: textColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              );
            },
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
  const _NavButton({
    required this.onTap,
    required this.color,
    this.isForward = false,
  });

  final VoidCallback onTap;
  final Color color;
  final bool isForward;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Padding(
          padding: EdgeInsets.all(4.r),
          child: Icon(
            isForward ? Icons.chevron_right : Icons.chevron_left,
            size: 16.sp,
            color: color,
          ),
        ),
      ),
    );
  }
}
