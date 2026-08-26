import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AbsenceDayMark { absence, availability }

class AbsenceCalendar extends StatefulWidget {
  const AbsenceCalendar({
    super.key,
    this.markedDays = const {},
    this.onRangeChanged,
    this.initialStart,
    this.initialEnd,
  });

  final Map<DateTime, AbsenceDayMark> markedDays;
  final void Function(DateTime start, DateTime end)? onRangeChanged;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<AbsenceCalendar> createState() => _AbsenceCalendarState();
}

class _AbsenceCalendarState extends State<AbsenceCalendar> {
  late DateTime _focusedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

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
  static const _shortMonths = [
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

  @override
  void initState() {
    super.initState();
    final start = widget.initialStart ?? _today;
    final end = widget.initialEnd ?? start;
    _rangeStart = _normalize(start);
    _rangeEnd = _normalize(end);
    _focusedMonth = DateTime(_rangeStart!.year, _rangeStart!.month);
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  void _notify() {
    if (_rangeStart == null) return;
    widget.onRangeChanged?.call(
      _rangeStart!,
      _rangeEnd ?? _rangeStart!,
    );
  }

  void _onDayTap(DateTime date) {
    final day = _normalize(date);
    setState(() {
      if (_rangeStart == null ||
          (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = day;
        _rangeEnd = null;
      } else {
        if (day.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = day;
        } else {
          _rangeEnd = day;
        }
      }
    });
    _notify();
  }

  bool _inRange(DateTime day) {
    if (_rangeStart == null) return false;
    final end = _rangeEnd ?? _rangeStart!;
    return !day.isBefore(_rangeStart!) && !day.isAfter(end);
  }

  int get _selectedCount {
    if (_rangeStart == null) return 0;
    final end = _rangeEnd ?? _rangeStart!;
    return end.difference(_rangeStart!).inDays + 1;
  }

  String get _selectionLabel {
    if (_rangeStart == null) return 'Select dates';
    final start = _rangeStart!;
    final end = _rangeEnd ?? _rangeStart!;
    final count = _selectedCount;
    final dayWord = count == 1 ? 'day' : 'days';

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day} ${_shortMonths[start.month - 1]} · $count $dayWord selected';
    }
    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${_shortMonths[start.month - 1]} · $count $dayWord selected';
    }
    return '${start.day} ${_shortMonths[start.month - 1]} – ${end.day} ${_shortMonths[end.month - 1]} · $count $dayWord selected';
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
    final theme = DashboardTheme.of(context);
    final days = _buildDays();
    final hairline =
        theme.isDark ? theme.dashBorderLight : const Color(0xFFE2E7F0);

    return AbsenceFormCard(
      padding: EdgeInsets.fromLTRB(18.r, 18.r, 18.r, 16.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: theme.dashHeading,
                  ),
                ),
              ),
              _NavChip(
                icon: LucideIcons.chevronLeft,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
                }),
              ),
              SizedBox(width: 6.w),
              _NavChip(
                icon: LucideIcons.chevronRight,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      color: const Color(0xFF8A99B0),
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
              mainAxisSpacing: 4.h,
              crossAxisSpacing: 4.w,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (_, index) {
              final day = days[index];
              final normalized = _normalize(day.date);
              final selected = day.isCurrentMonth && _inRange(normalized);
              final mark = widget.markedDays[normalized];

              Color textColor;
              if (!day.isCurrentMonth) {
                textColor = const Color(0xFF8A99B0).withValues(alpha: 0.45);
              } else if (selected) {
                textColor = theme.dashHeading;
              } else {
                textColor = theme.dashCalendarDay;
              }

              return GestureDetector(
                onTap: day.isCurrentMonth ? () => _onDayTap(normalized) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentLime : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.date.day}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (mark != null && day.isCurrentMonth && !selected)
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: mark == AbsenceDayMark.absence
                                ? AppColors.errorText
                                : AppColors.successText,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: hairline),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 16.sp,
                color: theme.dashPrimary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _selectionLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.dashPrimary,
                  ),
                ),
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

class _NavChip extends StatelessWidget {
  const _NavChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: theme.isDark
              ? theme.dashSurfaceTint
              : const Color(0xFFE9EDF5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 17.sp,
          color: theme.dashSubtitle,
        ),
      ),
    );
  }
}
