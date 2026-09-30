import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardBottomSheet extends StatefulWidget {
  const DashboardBottomSheet({super.key});

  @override
  State<DashboardBottomSheet> createState() => _DashboardBottomSheetState();
}

class _DashboardBottomSheetState extends State<DashboardBottomSheet> {
  int _selectedTab = 0; // 0 = Weekly, 1 = Daily
  DateTime _weekStart = _mondayOf(DateTime.now());
  DateTime _selectedDay = DateTime.now();

  // ── Static data ────────────────────────────────────────────────────────────

  static const _dayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _monthNames = [
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _mondayOf(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
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

  // Weekly: "11 May – 17 May 2026"
  String get _weekLabel {
    final end = _weekStart.add(const Duration(days: 6));
    return '${_weekStart.day} ${_monthNames[_weekStart.month - 1]}'
        ' – ${end.day} ${_monthNames[end.month - 1]} ${end.year}';
  }

  // Daily: "Saturday, 16 May 2026"
  String get _dayLabel {
    final name = _dayFull[_selectedDay.weekday - 1];
    final month = _monthNames[_selectedDay.month - 1];
    return '$name, ${_selectedDay.day} $month ${_selectedDay.year}';
  }

  bool get _isWeekly => _selectedTab == 0;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border(
          top: BorderSide(color: theme.border, width: 0.5),
          left: BorderSide(color: theme.border, width: 0.5),
          right: BorderSide(color: theme.border, width: 0.5),
        ),
        boxShadow: theme.isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.textDarkBlue.withValues(alpha: 0.45),
                  offset: Offset(0, 20.h),
                  blurRadius: 50.r,
                  spreadRadius: -10.r,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(theme),
          Divider(height: 0, thickness: 0.5, color: theme.border),
          _controls(theme),
          Flexible(child: _body(theme)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _header(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 20.h,
        bottom: 12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Schedule',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.text,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                // ← subtitle changes with tab
                Text(
                  _isWeekly
                      ? 'Jobs and absences for the selected week.'
                      : 'Jobs and absences for the selected day.',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                shape: BoxShape.circle,
                border: Border.all(color: theme.border, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab toggle + navigation ────────────────────────────────────────────────

  Widget _controls(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly / Daily pill
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: theme.surfaceDeep,
              border: Border.all(color: theme.border, width: 0.5),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tabButton(theme: theme, label: 'Weekly', index: 0),
                _tabButton(theme: theme, label: 'Daily', index: 1),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Navigation row — label changes per tab
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(
                theme: theme,
                icon: Icons.chevron_left_rounded,
                onTap: _isWeekly
                    ? () => setState(
                        () => _weekStart = _weekStart.subtract(
                          const Duration(days: 7),
                        ),
                      )
                    : () => setState(
                        () => _selectedDay = _selectedDay.subtract(
                          const Duration(days: 1),
                        ),
                      ),
              ),
              Text(
                _isWeekly ? _weekLabel : _dayLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: theme.text,
                ),
              ),
              _navButton(
                theme: theme,
                icon: Icons.chevron_right_rounded,
                onTap: _isWeekly
                    ? () => setState(
                        () => _weekStart = _weekStart.add(
                          const Duration(days: 7),
                        ),
                      )
                    : () => setState(
                        () => _selectedDay = _selectedDay.add(
                          const Duration(days: 1),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton({required DashboardTheme theme, required String label, required int index}) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: active
                ? Colors.white
                : (theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _navButton({required DashboardTheme theme, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(icon, size: 22.sp, color: theme.text),
      ),
    );
  }

  // ── Scrollable body ────────────────────────────────────────────────────────

  Widget _body(DashboardTheme theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _errorBanner(),
          SizedBox(height: 12.h),
          _isWeekly ? _weeklyContent(theme) : _dailyContent(theme),
        ],
      ),
    );
  }

  // ── Error banner ───────────────────────────────────────────────────────────

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        border: Border.all(color: AppColors.errorBorder, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        "Couldn't load schedule: No ServiceResource linked to this user",
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.errorText,
        ),
      ),
    );
  }

  // ── Weekly content: list of 7 day rows ────────────────────────────────────

  Widget _weeklyContent(DashboardTheme theme) {
    return Column(
      children: List.generate(7, (i) {
        final day = _weekStart.add(Duration(days: i));
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _dayRow(theme: theme, day: day),
        );
      }),
    );
  }

  Widget _dayRow({required DashboardTheme theme, required DateTime day}) {
    final today = _isToday(day);
    final shortName = _dayShort[day.weekday - 1];
    final monthName = _monthNames[day.month - 1];
    final label =
        '$shortName ${_ordinal(day.day)} $monthName'
        '${today ? ' · Today' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: today ? AppColors.accentBlue : theme.text,
              ),
            ),
            Text(
              'Rest day',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Nothing scheduled.',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
        ),
      ],
    );
  }

  // ── Daily content: appointment card ───────────────────────────────────────

  Widget _dailyContent(DashboardTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Blue header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            color: AppColors.accentBlue,
            alignment: Alignment.center,
            child: Text(
              'No appointments scheduled for this day.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Gradient divider line
          Container(
            height: 2.5.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueGradientEnd],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
