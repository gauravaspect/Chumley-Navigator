import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:chumley_navigator/widgets/calendar/aspect_calendar_view.dart';
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
    widget.onRangeChanged?.call(_rangeStart!, _rangeEnd ?? _rangeStart!);
  }

  void _onDayTap(DateTime date) {
    final day = _normalize(date);
    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
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
    final shortMonths = AspectCalendarUtils.shortMonthNames;

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day} ${shortMonths[start.month - 1]} · $count $dayWord selected';
    }
    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${shortMonths[start.month - 1]} · $count $dayWord selected';
    }
    return '${start.day} ${shortMonths[start.month - 1]} – ${end.day} ${shortMonths[end.month - 1]} · $count $dayWord selected';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final days = AspectCalendarUtils.buildCalendarDays(_focusedMonth);
    final hairline = theme.isDark
        ? theme.dashBorderLight
        : const Color(0xFFE2E7F0);

    return AbsenceFormCard(
      padding: EdgeInsets.fromLTRB(18.r, 18.r, 18.r, 16.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AspectCalendarUtils.monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
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
            children: AspectCalendarUtils.weekDays.map((d) {
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
                textColor = theme.dashHeading;
              }

              final isToday = day.isCurrentMonth && normalized == _today;

              return InkWell(
                onTap: day.isCurrentMonth ? () => _onDayTap(day.date) : null,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isToday
                        ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.date.day}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: selected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      if (mark != null && day.isCurrentMonth)
                        Positioned(
                          bottom: 4.h,
                          child: Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mark == AbsenceDayMark.absence
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Container(height: 1, color: hairline),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectionLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.dashHeading,
                  ),
                ),
              ),
              if (_rangeStart != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _rangeStart = null;
                      _rangeEnd = null;
                    });
                    _notify();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(44.w, 24.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
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

class _NavChip extends StatelessWidget {
  const _NavChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
          alignment: Alignment.center,
          child: Icon(icon, size: 16.sp, color: const Color(0xFF8A99B0)),
        ),
      ),
    );
  }
}
