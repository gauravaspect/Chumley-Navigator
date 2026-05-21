import 'package:chumley_navigator/utils/colors.dart';
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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _selectedDate = widget.initialSelected ?? _today;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  AbsenceDayMark? _markFor(DateTime date) {
    return widget.markedDays[_normalize(date)];
  }

  ({Color bg, Color fg, Color? border, bool showDot}) _dayColors({
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required AbsenceDayMark? mark,
  }) {
    if (isSelected) {
      return (
        bg: AppColors.primaryBlue,
        fg: AppColors.white,
        border: null,
        showDot: false,
      );
    }

    if (mark == AbsenceDayMark.absence && isCurrentMonth) {
      return (
        bg: AppColors.vcrWarningBackground,
        fg: AppColors.vcrWarningText,
        border: AppColors.streakOrange.withValues(alpha: 0.45),
        showDot: true,
      );
    }

    if (mark == AbsenceDayMark.availability && isCurrentMonth) {
      return (
        bg: AppColors.successBackground,
        fg: AppColors.successText,
        border: AppColors.successText.withValues(alpha: 0.35),
        showDot: true,
      );
    }

    if (isToday && isCurrentMonth) {
      return (
        bg: AppColors.borderLightBlue.withValues(alpha: 0.35),
        fg: AppColors.textCalendarDay,
        border: AppColors.borderLightBlue,
        showDot: false,
      );
    }

    return (
      bg: Colors.transparent,
      fg: isCurrentMonth
          ? AppColors.textCalendarDay
          : AppColors.textCalendarDisabled,
      border: null,
      showDot: false,
    );
  }

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
    final days = _buildDays();

    return AbsenceFormCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Absences & Availability',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkBlue,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tap a date to view or plan time off',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textBodyMuted,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavIcon(icon: Icons.chevron_left_rounded, onTap: () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                });
              }),
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDarkBlue,
                ),
              ),
              _NavIcon(icon: Icons.chevron_right_rounded, onTap: () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6.h,
              childAspectRatio: 0.92,
            ),
            itemCount: days.length,
            itemBuilder: (_, index) {
              final day = days[index];
              final normalized = _normalize(day.date);
              final isToday = normalized == _today;
              final isSelected = _selectedDate != null &&
                  normalized == _normalize(_selectedDate!);
              final mark = day.isCurrentMonth ? _markFor(day.date) : null;
              final colors = _dayColors(
                isCurrentMonth: day.isCurrentMonth,
                isToday: isToday,
                isSelected: isSelected,
                mark: mark,
              );
              final dotColor = mark == AbsenceDayMark.absence
                  ? AppColors.streakOrange
                  : AppColors.successText;

              return GestureDetector(
                onTap: day.isCurrentMonth
                    ? () {
                        setState(() => _selectedDate = normalized);
                        widget.onDateSelected?.call(normalized);
                      }
                    : null,
                child: Center(
                  child: SizedBox(
                    width: 36.w,
                    height: 36.h,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 32.w,
                          height: 28.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.bg,
                            borderRadius: BorderRadius.circular(999.r),
                            border: colors.border != null
                                ? Border.all(
                                    color: colors.border!,
                                    width: 0.75,
                                  )
                                : null,
                          ),
                          child: Text(
                            '${day.date.day}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.fg,
                            ),
                          ),
                        ),
                        if (colors.showDot && mark != null)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dotColor,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 1.25,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              const _LegendDot(
                color: AppColors.streakOrange,
                label: 'Absence',
              ),
              SizedBox(width: 16.w),
              const _LegendDot(
                color: AppColors.successText,
                label: 'Available',
              ),
            ],
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 24.sp, color: AppColors.primaryBlue),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textBodyMuted,
          ),
        ),
      ],
    );
  }
}
