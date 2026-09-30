import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/list_absence_model.dart';
import 'package:chumley_navigator/screens/absences/cubit/absences_cubit.dart';
import 'package:chumley_navigator/screens/absences/cubit/absences_state.dart';
import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/absences/absence_calendar.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:chumley_navigator/widgets/absences/absence_time_field.dart';
import 'package:chumley_navigator/widgets/absences/absence_whole_day_switch.dart';
import 'package:chumley_navigator/widgets/absences/cupertino_time_picker_sheet.dart';
import 'package:chumley_navigator/widgets/absences/my_absence_card.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  static const _defaultStart = TimeOfDay(hour: 9, minute: 0);
  static const _defaultEnd = TimeOfDay(hour: 17, minute: 0);

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

  final List<String> _absenceReasons = [
    'Holiday',
    'Sick/ Unplanned Absence',
    'Approved Late start',
    'Early Finish',
    'Late Leaving Home',
    'Material Collection',
    'Office',
    'Paperwork',
    'Project',
    'AWOL',
  ];

  String? _selectedReason = 'Holiday';
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;
  bool _wholeDay = false;
  TimeOfDay? _startTime = _defaultStart;
  TimeOfDay? _endTime = _defaultEnd;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  late final AbsencesCubit _cubit;
  bool _showErrors = false;
  int _calendarEpoch = 0;

  bool _isTimeValid() {
    if (_wholeDay) return true;
    if (_startTime == null || _endTime == null) return false;
    if (_rangeStart != _rangeEnd) return true;
    final startMin = _startTime!.hour * 60 + _startTime!.minute;
    final endMin = _endTime!.hour * 60 + _endTime!.minute;
    return endMin > startMin;
  }

  bool _validate() {
    setState(() => _showErrors = true);
    if (_selectedReason == null) return false;
    if (!_wholeDay) {
      if (_startTime == null || _endTime == null) return false;
      if (!_isTimeValid()) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _rangeStart = today;
    _rangeEnd = today;
    _cubit = AppDependencies.createAbsencesCubit()..load();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? _defaultStart)
        : (_endTime ?? _defaultEnd);
    final picked = await showCupertinoTimePickerSheet(
      context: context,
      initialTime: initial,
      title: isStart ? 'Start time' : 'End time',
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  int _dayCount(DateTime start, DateTime end) =>
      end.difference(start).inDays + 1;

  String _reasonTitle(AbsenceItem item) {
    final type = item.type.trim().isEmpty ? 'Absence' : item.type.trim();
    final start = DateTime.tryParse(item.start);
    final end = DateTime.tryParse(item.end);
    if (start == null || end == null) return type;
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final days = _dayCount(startDay, endDay);
    if (days <= 1 &&
        !(start.hour == 0 &&
            start.minute == 0 &&
            end.hour == 23 &&
            end.minute == 59)) {
      return type;
    }
    final dayWord = days == 1 ? 'day' : 'days';
    return '$type · $days $dayWord';
  }

  String _submittedLabel(AbsenceItem item) {
    final raw = item.sentForApprovalAt.isNotEmpty
        ? item.sentForApprovalAt
        : item.start;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Submitted';
    return 'Submitted ${dt.day} ${_shortMonths[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ListenableBuilder(
        listenable: ThemeScope.of(context),
        builder: (context, _) {
          final theme = DashboardTheme.of(context);

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: theme.dashPrimary),
            ),
            child: BlocConsumer<AbsencesCubit, AbsencesState>(
              listener: (context, state) {
                if (state is AbsencesLoaded && state.submitSuccess) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Absence submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  setState(() {
                    _selectedReason = 'Holiday';
                    _descriptionController.clear();
                    _wholeDay = false;
                    _startTime = _defaultStart;
                    _endTime = _defaultEnd;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    _rangeStart = today;
                    _rangeEnd = today;
                    _showErrors = false;
                    _descriptionFocused = false;
                    _calendarEpoch++;
                  });
                  _cubit.resetSubmitStatus();
                } else if (state is AbsencesLoaded &&
                    state.submitError != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.submitError!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  _cubit.resetSubmitStatus();
                } else if (state is AbsencesError &&
                    state.cachedAbsences == null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              builder: (context, state) {
                final response = state.responseOrNull;
                final absences = response?.absences ?? const <AbsenceItem>[];
                final showShimmer =
                    state is AbsencesInitial ||
                    (state is AbsencesLoading && absences.isEmpty);
                final loadFailed = state is AbsencesError && response == null;
                final isSubmitting =
                    state is AbsencesLoaded && state.isSubmitting;

                final calendarMarks = <DateTime, AbsenceDayMark>{};
                for (final item in absences) {
                  final startDateTime = DateTime.tryParse(item.start);
                  final endDateTime = DateTime.tryParse(item.end);
                  if (startDateTime != null && endDateTime != null) {
                    var current = DateTime(
                      startDateTime.year,
                      startDateTime.month,
                      startDateTime.day,
                    );
                    final targetEnd = DateTime(
                      endDateTime.year,
                      endDateTime.month,
                      endDateTime.day,
                    );
                    while (!current.isAfter(targetEnd)) {
                      calendarMarks[current] = AbsenceDayMark.absence;
                      current = current.add(const Duration(days: 1));
                    }
                  }
                }

                final records = absences.map((item) {
                  final approved =
                      item.approved == true ||
                      item.status.toLowerCase() == 'approved';
                  return MyAbsenceRecord(
                    reason: _reasonTitle(item),
                    subtitle: _submittedLabel(item),
                    status: absenceStatusLabel(item.status, approved: approved),
                    statusColor: absenceStatusFg(
                      item.status,
                      approved: approved,
                    ),
                    statusBackground: absenceStatusBg(
                      item.status,
                      approved: approved,
                    ),
                    icon: absenceTypeIcon(item.type),
                  );
                }).toList();

                final fieldFill = theme.isDark
                    ? theme.dashSurfaceTint
                    : const Color(0xFFE9EDF5);
                final hairline = theme.isDark
                    ? theme.dashBorderLight
                    : const Color(0xFFE2E7F0);

                return Scaffold(
                  backgroundColor: theme.base,
                  body: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: theme.isDark
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF4F9FF),
                                Color(0xFFEDF4FE),
                                Color(0xFFE2ECFA),
                              ],
                              stops: [0, 0.55, 1],
                            ),
                      color: theme.isDark ? theme.base : null,
                    ),
                    child: SafeArea(
                      child: RefreshIndicator(
                        color: theme.dashPrimary,
                        onRefresh: _cubit.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
                          children: [
                            Text(
                              'Absence',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7,
                                color: theme.dashHeading,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Book time off and track requests',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: theme.dashMuted,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            FadeSlideIn(
                              child: AbsenceCalendar(
                                key: ValueKey(_calendarEpoch),
                                markedDays: calendarMarks,
                                initialStart: _rangeStart,
                                initialEnd: _rangeEnd,
                                onRangeChanged: (start, end) {
                                  setState(() {
                                    _rangeStart = start;
                                    _rangeEnd = end;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 12.h),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 40),
                              child: AbsenceFormCard(
                                padding: EdgeInsets.all(18.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: theme.dashHeading,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AbsenceTimeField(
                                            label: 'Start time',
                                            time: _startTime,
                                            enabled: !_wholeDay,
                                            hasError:
                                                _showErrors &&
                                                !_wholeDay &&
                                                (_startTime == null ||
                                                    !_isTimeValid()),
                                            onTap: () =>
                                                _pickTime(isStart: true),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: AbsenceTimeField(
                                            label: 'End time',
                                            time: _endTime,
                                            enabled: !_wholeDay,
                                            hasError:
                                                _showErrors &&
                                                !_wholeDay &&
                                                (_endTime == null ||
                                                    !_isTimeValid()),
                                            onTap: () =>
                                                _pickTime(isStart: false),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_showErrors && !_wholeDay) ...[
                                      if (_startTime == null ||
                                          _endTime == null) ...[
                                        SizedBox(height: 6.h),
                                        Text(
                                          'Please select both start and end times',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ] else if (!_isTimeValid()) ...[
                                        SizedBox(height: 6.h),
                                        Text(
                                          'End time must be after start time',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                    SizedBox(height: 16.h),
                                    Divider(height: 1, color: hairline),
                                    SizedBox(height: 16.h),
                                    AbsenceWholeDaySwitch(
                                      value: _wholeDay,
                                      onChanged: (val) => setState(() {
                                        _wholeDay = val;
                                        if (val) {
                                          _startTime = const TimeOfDay(
                                            hour: 0,
                                            minute: 0,
                                          );
                                          _endTime = const TimeOfDay(
                                            hour: 23,
                                            minute: 59,
                                          );
                                        } else {
                                          _startTime = _defaultStart;
                                          _endTime = _defaultEnd;
                                        }
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 80),
                              child: AbsenceFormCard(
                                padding: EdgeInsets.all(18.r),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Reason for absence',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: theme.dashHeading,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        color: theme.dashSubtitle,
                                      ),
                                    ),
                                    SizedBox(height: 7.h),
                                    DropdownButtonFormField2<String>(
                                      value: _selectedReason,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: fieldFill,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 4.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: hairline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                _showErrors &&
                                                    _selectedReason == null
                                                ? Colors.red
                                                : hairline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.dashPrimary,
                                            width: 1.25,
                                          ),
                                        ),
                                      ),
                                      hint: Text(
                                        'Select',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: theme.dashHeading,
                                        ),
                                      ),
                                      iconStyleData: IconStyleData(
                                        icon: Icon(
                                          LucideIcons.chevronDown,
                                          color: const Color(0xFF8A99B0),
                                          size: 18.sp,
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          color: theme.dashCardBg,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(color: hairline),
                                        ),
                                      ),
                                      menuItemStyleData: MenuItemStyleData(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                        ),
                                        height: 42.h,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: theme.dashHeading,
                                      ),
                                      items: _absenceReasons
                                          .map(
                                            (cat) => DropdownMenuItem<String>(
                                              value: cat,
                                              child: Text(cat),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedReason = val),
                                    ),
                                    if (_showErrors &&
                                        _selectedReason == null) ...[
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Please select an absence reason',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Note',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        color: theme.dashSubtitle,
                                      ),
                                    ),
                                    SizedBox(height: 7.h),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: fieldFill,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: _descriptionFocused
                                              ? theme.dashPrimary
                                              : hairline,
                                          width: _descriptionFocused ? 1.25 : 1,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _descriptionController,
                                        maxLines: 3,
                                        onTap: () => setState(
                                          () => _descriptionFocused = true,
                                        ),
                                        onTapOutside: (_) => setState(
                                          () => _descriptionFocused = false,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          height: 1.45,
                                          color: theme.dashHeading,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Add a note (optional)…',
                                          hintStyle: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF8A99B0),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(
                                            14.w,
                                            13.h,
                                            14.w,
                                            40.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Opacity(
                                      opacity: isSubmitting ? 0.55 : 1,
                                      child: PressableScale(
                                        onTap: isSubmitting
                                            ? null
                                            : () {
                                                if (!_validate()) return;
                                                _cubit.submitAbsence(
                                                  type: _selectedReason!,
                                                  description:
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                  startDate: _rangeStart,
                                                  endDate: _rangeEnd,
                                                  startTime: _startTime,
                                                  endTime: _endTime,
                                                  wholeDay: _wholeDay,
                                                );
                                              },
                                        scale: 0.98,
                                        child: Container(
                                          width: double.infinity,
                                          height: 44.h,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.accentLime,
                                            borderRadius: BorderRadius.circular(
                                              14.r,
                                            ),
                                          ),
                                          child: Text(
                                            isSubmitting
                                                ? 'Submitting...'
                                                : 'Submit absence',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDarkBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (loadFailed) ...[
                                      SizedBox(height: 12.h),
                                      Text(
                                        'Could not load your absences.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: theme.accent,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 120),
                              child: showShimmer
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pending requests',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: theme.dashHeading,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        ThemedShimmerBox(
                                          theme: theme,
                                          height: 180.h,
                                          radius: 20,
                                        ),
                                      ],
                                    )
                                  : MyAbsencesSection(
                                      records: records,
                                      loadFailed: loadFailed,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
