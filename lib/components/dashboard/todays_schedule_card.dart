import 'package:chumley_navigator/components/dashboard/compact_schedule_job_card.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/calendar_full_screen.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact weekly schedule card for the dashboard home.
class TodaysScheduleCard extends StatefulWidget {
  const TodaysScheduleCard({
    super.key,
    this.appointments = const [],
    this.ppmTasks = const [],
  });

  final List<Appointment> appointments;
  final List<PpmJobTask> ppmTasks;

  @override
  State<TodaysScheduleCard> createState() => _TodaysScheduleCardState();
}

class _TodaysScheduleCardState extends State<TodaysScheduleCard> {
  static const _weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late DateTime _selectedDate;
  String _filter = 'All';

  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
  }

  DateTime get _weekStart {
    return _today.subtract(Duration(days: _today.weekday - 1));
  }

  List<DateTime> get _weekDays {
    return List.generate(7, (i) => _weekStart.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasAppointment(DateTime date) {
    for (final appointment in widget.appointments) {
      final start = appointment.scheduledStart;
      if (start == null) continue;
      if (_isSameDay(start, date)) return true;
    }
    return false;
  }

  bool _hasPpm(DateTime date) =>
      widget.ppmTasks.isNotEmpty && _isSameDay(date, _today);

  List<Appointment> get _dayAppointments {
    return widget.appointments.where((a) {
      final start = a.scheduledStart;
      if (start == null) return false;
      if (!_isSameDay(start, _selectedDate)) return false;
      if (_filter == 'All') return true;
      final type = a.type.isNotEmpty
          ? a.type
          : CompactScheduleJobCard.jobTitle(a);
      return type == _filter;
    }).toList();
  }

  List<PpmJobTask> get _dayPpmTasks {
    if (!_isSameDay(_selectedDate, _today)) return const [];
    if (_filter != 'All' && _filter != 'PPM') return const [];
    return widget.ppmTasks;
  }

  List<String> get _filterOptions {
    final types = <String>{'All'};
    for (final a in widget.appointments) {
      final type = a.type.isNotEmpty ? a.type : null;
      if (type != null && type.isNotEmpty) types.add(type);
    }
    if (widget.ppmTasks.isNotEmpty) types.add('PPM');
    return types.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final appointments = _dayAppointments;
    final ppmTasks = _dayPpmTasks;
    final empty = appointments.isEmpty && ppmTasks.isEmpty;
    final isToday = _isSameDay(_selectedDate, _today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isToday ? "Today's schedule" : 'Schedule',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashHeading,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => CalendarFullScreen.open(
                context,
                appointments: widget.appointments,
                ppmTasks: widget.ppmTasks,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.dashPrimaryCalendar,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18.sp,
                    color: theme.dashPrimaryCalendar,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          decoration: theme.dashCardDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < _weekDays.length; i++) ...[
                    if (i > 0) SizedBox(width: 6.w),
                    Expanded(child: _dayPill(_weekDays[i], theme)),
                  ],
                ],
              ),
              SizedBox(height: 14.h),
              _filterBar(theme),
              SizedBox(height: 8.h),
              if (empty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      'No jobs scheduled',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.dashMuted,
                      ),
                    ),
                  ),
                )
              else ...[
                for (var i = 0; i < appointments.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: theme.dashBorderLight),
                  CompactScheduleJobCard(appointment: appointments[i]),
                ],
                for (var i = 0; i < ppmTasks.length; i++) ...[
                  if (appointments.isNotEmpty || i > 0)
                    Divider(height: 1, color: theme.dashBorderLight),
                  CompactSchedulePpmCard(task: ppmTasks[i]),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _dayPill(DateTime date, DashboardTheme theme) {
    final selected = _isSameDay(date, _selectedDate);
    final hasEvent = _hasAppointment(date) || _hasPpm(date);
    final label = _weekDayLabels[date.weekday - 1];

    final bg = selected
        ? AppColors.accentLime
        : (theme.isDark ? theme.dashSurfaceTint : const Color(0xFFF1F3F8));
    final dayColor = selected
        ? AppColors.textDarkBlue
        : theme.dashMuted;
    final dateColor = selected
        ? AppColors.textDarkBlue
        : theme.dashTitle;
    final dotColor = selected
        ? AppColors.textDarkBlue
        : theme.dashPrimary;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: dayColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: dateColor,
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              height: 6.h,
              child: hasEvent
                  ? Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterBar(DashboardTheme theme) {
    final options = _filterOptions;
    return Material(
      color: theme.isDark ? theme.dashSurfaceTint : const Color(0xFFF1F3F8),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => _openFilterSheet(options),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _filter,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.dashTitle,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronDown,
                size: 18.sp,
                color: theme.dashMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(List<String> options) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final opt in options)
                ListTile(
                  title: Text(opt),
                  trailing: opt == _filter
                      ? Icon(LucideIcons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () => Navigator.pop(context, opt),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _filter = selected);
  }
}
