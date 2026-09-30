import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AspectCalendarDay {
  const AspectCalendarDay({required this.date, required this.isCurrentMonth});

  final DateTime date;
  final bool isCurrentMonth;
}

class AspectCalendarUtils {
  static const List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> fullWeekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> monthNames = [
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
  static const List<String> shortMonthNames = [
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

  static String getDayWithSuffix(int day) {
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

  static List<AspectCalendarDay> buildCalendarDays(DateTime focusedMonth) {
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final int leadingBlanks = firstOfMonth.weekday % 7;
    final int trailingBlanks = 6 - (lastOfMonth.weekday % 7);

    final days = <AspectCalendarDay>[];

    for (int i = leadingBlanks; i > 0; i--) {
      days.add(
        AspectCalendarDay(
          date: firstOfMonth.subtract(Duration(days: i)),
          isCurrentMonth: false,
        ),
      );
    }

    for (int d = 1; d <= lastOfMonth.day; d++) {
      days.add(
        AspectCalendarDay(
          date: DateTime(focusedMonth.year, focusedMonth.month, d),
          isCurrentMonth: true,
        ),
      );
    }

    for (int i = 1; i <= trailingBlanks; i++) {
      days.add(
        AspectCalendarDay(
          date: DateTime(focusedMonth.year, focusedMonth.month + 1, i),
          isCurrentMonth: false,
        ),
      );
    }

    return days;
  }
}

class AspectCalendarView extends StatelessWidget {
  const AspectCalendarView({
    super.key,
    required this.focusedMonth,
    required this.dayBuilder,
    this.onPrevMonth,
    this.onNextMonth,
    this.weekDays = AspectCalendarUtils.weekDays,
    this.showNavigationHeader = true,
    this.gridSpacing,
  });

  final DateTime focusedMonth;
  final Widget Function(BuildContext context, AspectCalendarDay day) dayBuilder;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final List<String> weekDays;
  final bool showNavigationHeader;
  final double? gridSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final days = AspectCalendarUtils.buildCalendarDays(focusedMonth);
    final monthTitle =
        '${AspectCalendarUtils.monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showNavigationHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: theme.text,
                ),
              ),
              Row(
                children: [
                  _navButton(
                    icon: LucideIcons.chevronLeft,
                    onTap: onPrevMonth,
                    theme: theme,
                  ),
                  SizedBox(width: 8.w),
                  _navButton(
                    icon: LucideIcons.chevronRight,
                    onTap: onNextMonth,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
        ],
        Row(
          children: weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textMuted,
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
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: gridSpacing ?? 6.h,
            crossAxisSpacing: gridSpacing ?? 4.w,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) => dayBuilder(context, days[index]),
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required VoidCallback? onTap,
    required DashboardTheme theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: theme.isDark
                ? AppColors.darkSurface
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16.sp, color: theme.text),
        ),
      ),
    );
  }
}
