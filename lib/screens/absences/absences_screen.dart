import 'package:chumley_navigator/components/common/aspect_branding.dart';
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
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/primary_cta_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  static const _defaultStart = TimeOfDay(hour: 9, minute: 0);
  static const _defaultEnd = TimeOfDay(hour: 21, minute: 0);

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

  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;
  bool _wholeDay = false;
  TimeOfDay? _startTime = _defaultStart;
  TimeOfDay? _endTime = _defaultEnd;
  DateTime? _selectedDate;
  late final AbsencesCubit _cubit;
  bool _showErrors = false;

  bool _isTimeValid() {
    if (_wholeDay) return true;
    if (_startTime == null || _endTime == null) return false;
    final startMin = _startTime!.hour * 60 + _startTime!.minute;
    final endMin = _endTime!.hour * 60 + _endTime!.minute;
    return endMin > startMin;
  }

  bool _validate() {
    setState(() {
      _showErrors = true;
    });

    if (_selectedReason == null) return false;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (!_wholeDay) {
      if (_startTime == null || _endTime == null) return false;
      if (!_isTimeValid()) return false;
    }
    return true;
  }


  final _scrollController = ScrollController();

  /// 0.0 = expanded, 1.0 = collapsed — updated every scroll frame.
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  static double _easedCollapseProgress(double offset) {
    final raw = (offset / _scrollThreshold).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  void _onScroll() {
    final progress = _easedCollapseProgress(_scrollController.offset);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _descriptionController.addListener(() {
      if (_showErrors) {
        setState(() {});
      }
    });
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;
    _cubit = AppDependencies.createAbsencesCubit()..load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
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

  String _formatDateRange(AbsenceItem item) {
    final startDt = DateTime.tryParse(item.start);
    final endDt = DateTime.tryParse(item.end);
    if (startDt == null || endDt == null) {
      return '${item.start} - ${item.end}';
    }

    const months = [
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
      'Dec'
    ];
    String fmtDate(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';
    String fmtTime(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    final sameDay = startDt.year == endDt.year &&
        startDt.month == endDt.month &&
        startDt.day == endDt.day;

    final isWholeDay = startDt.hour == 0 &&
        startDt.minute == 0 &&
        endDt.hour == 23 &&
        endDt.minute == 59;

    if (sameDay) {
      if (isWholeDay) {
        return fmtDate(startDt);
      } else {
        return '${fmtDate(startDt)}, ${fmtTime(startDt)} - ${fmtTime(endDt)}';
      }
    } else {
      if (isWholeDay) {
        return '${fmtDate(startDt)} - ${fmtDate(endDt)}';
      } else {
        return '${fmtDate(startDt)}, ${fmtTime(startDt)} - ${fmtDate(endDt)}, ${fmtTime(endDt)}';
      }
    }
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
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: theme.dashPrimary,
                  ),
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
                    _selectedReason = null;
                    _descriptionController.clear();
                    _wholeDay = false;
                    _startTime = _defaultStart;
                    _endTime = _defaultEnd;
                    final now = DateTime.now();
                    _selectedDate = DateTime(now.year, now.month, now.day);
                    _showErrors = false;
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
                final showShimmer = state is AbsencesInitial ||
                    (state is AbsencesLoading && absences.isEmpty);
                final loadFailed = state is AbsencesError && response == null;
                final isSubmitting =
                    state is AbsencesLoaded && state.isSubmitting;

                // Compute calendar marks dynamically from absences
                final Map<DateTime, AbsenceDayMark> calendarMarks = {};
                for (final item in absences) {
                  final startDateTime = DateTime.tryParse(item.start);
                  final endDateTime = DateTime.tryParse(item.end);
                  if (startDateTime != null && endDateTime != null) {
                    var current = DateTime(startDateTime.year,
                        startDateTime.month, startDateTime.day);
                    final targetEnd = DateTime(
                        endDateTime.year, endDateTime.month, endDateTime.day);
                    while (current.isBefore(targetEnd) ||
                        current.isAtSameMomentAs(targetEnd)) {
                      calendarMarks[current] = AbsenceDayMark.absence;
                      current = current.add(const Duration(days: 1));
                    }
                  }
                }

                // Map absences to records
                final List<MyAbsenceRecord> records = absences.map((item) {
                  final isApproved = item.approved == true ||
                      item.status.toLowerCase() == 'approved';
                  final isRejected =
                      item.status.toLowerCase() == 'rejected' ||
                          item.status.toLowerCase() == 'cancelled';

                  Color statusColor;
                  Color statusBackground;
                  String statusText;
                  if (isApproved) {
                    statusText = 'Approved';
                    statusColor = theme.dashSuccessFg;
                    statusBackground = theme.dashSuccessBg;
                  } else if (isRejected) {
                    statusText = 'Rejected';
                    statusColor = AppColors.errorText;
                    statusBackground = AppColors.errorBackground;
                  } else {
                    statusText = 'Pending';
                    statusColor = AppColors.pendingText;
                    statusBackground = AppColors.pendingBackground;
                  }

                  return MyAbsenceRecord(
                    reason: item.type.isNotEmpty ? item.type : 'Absence',
                    dateRange: _formatDateRange(item),
                    status: statusText,
                    statusColor: statusColor,
                    statusBackground: statusBackground,
                  );
                }).toList();

                return Scaffold(
                  backgroundColor: theme.base,
                  body: SafeArea(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          color: theme.dashPrimary,
                          onRefresh: _cubit.refresh,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: _brandingExpandedHeight + 28,
                              bottom: 112.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ValueListenableBuilder<double>(
                                  valueListenable: _collapseProgress,
                                  builder: (context, progress, _) {
                                    return Opacity(
                                      opacity: (1.0 - progress).clamp(0.0, 1.0),
                                      child: Text(
                                        'Absences',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.6,
                                          color: theme.dashTitle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 14.h),
                                FadeSlideIn(
                                  child: AbsenceCalendar(
                                    markedDays: calendarMarks,
                                    initialSelected: _selectedDate,
                                    onDateSelected: (date) =>
                                        setState(() => _selectedDate = date),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 60),
                                  child: AbsenceFormCard(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 20.h,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Please enter your start and end time',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: theme.dashTitle,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AbsenceTimeField(
                                                label: 'Start Time:',
                                                time: _startTime,
                                                enabled: !_wholeDay,
                                                hasError: _showErrors &&
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
                                                label: 'End Time:',
                                                time: _endTime,
                                                enabled: !_wholeDay,
                                                hasError: _showErrors &&
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
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select both start and end times',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ] else if (!_isTimeValid()) ...[
                                            SizedBox(height: 6.h),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'End time must be after start time',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                        SizedBox(height: 16.h),
                                        AbsenceWholeDaySwitch(
                                          value: _wholeDay,
                                          onChanged: (val) => setState(() {
                                            _wholeDay = val;
                                            if (val) {
                                              _startTime = const TimeOfDay(hour: 0, minute: 0);
                                              _endTime = const TimeOfDay(hour: 23, minute: 59);
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
                                SizedBox(height: 16.h),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 100),
                                  child: AbsenceFormCard(
                                    showShadow: true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Submit an Absence',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: theme.dashTitle,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Please choose from the below reasons',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w400,
                                            color: theme.dashSubtitle,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        _absenceReasonDropdown(theme,
                                            hasError: _showErrors &&
                                                _selectedReason == null),
                                        if (_showErrors &&
                                            _selectedReason == null) ...[
                                          SizedBox(height: 6.h),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an absence reason',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 16.h),
                                        Text(
                                          'Detailed Description',
                                          style: TextStyle(
                                            color: theme.dashSubtitle,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        _descriptionField(theme,
                                            hasError: _showErrors &&
                                                _descriptionController
                                                    .text
                                                    .trim()
                                                    .isEmpty),
                                        if (_showErrors &&
                                            _descriptionController.text
                                                .trim()
                                                .isEmpty) ...[
                                          SizedBox(height: 6.h),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please enter a detailed description',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 16.h),
                                        Opacity(
                                          opacity: !isSubmitting ? 1 : 0.5,
                                          child: PrimaryCtaButton(
                                            label: isSubmitting
                                                ? 'Submitting...'
                                                : 'Submit absence',
                                            icon: isSubmitting
                                                ? null
                                                : LucideIcons.calendar_check,
                                            borderRadius: 8.r,
                                            height: 48.h,
                                            onTap: !isSubmitting
                                                ? () {
                                                    if (_validate()) {
                                                      _cubit.submitAbsence(
                                                        type:
                                                            _selectedReason!,
                                                        description:
                                                            _descriptionController
                                                                .text,
                                                        date: _selectedDate ??
                                                            DateTime.now(),
                                                        startTime: _startTime,
                                                        endTime: _endTime,
                                                        wholeDay: _wholeDay,
                                                      );
                                                    }
                                                  }
                                                : null,
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
                                SizedBox(height: 24.h),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 140),
                                  child: showShimmer
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'My Absences',
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w600,
                                                color: theme.dashHeading,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            ThemedShimmerBox(
                                                theme: theme,
                                                height: 64.h,
                                                radius: 12),
                                            SizedBox(height: 8.h),
                                            ThemedShimmerBox(
                                                theme: theme,
                                                height: 64.h,
                                                radius: 12),
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
                        ValueListenableBuilder<double>(
                          valueListenable: _collapseProgress,
                          builder: (context, progress, _) {
                            return Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: AspectBranding(
                                progress: progress,
                                expandedHeight: _brandingExpandedHeight,
                                collapsedHeight: _brandingCollapsedHeight,
                                theme: theme,
                                title: Text(
                                  'Absences',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: theme.dashTitle,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  InputBorder _fieldBorder(DashboardTheme theme, {bool focused = false, bool hasError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: hasError
            ? Colors.red
            : (focused ? theme.dashPrimary : theme.dashBorderLight),
        width: 1,
      ),
    );
  }

  Widget _absenceReasonDropdown(DashboardTheme theme, {bool hasError = false}) {
    return DropdownButtonFormField2<String>(
      value: _selectedReason,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.dashCardBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        border: _fieldBorder(theme, hasError: hasError),
        enabledBorder: _fieldBorder(theme, hasError: hasError),
        focusedBorder: _fieldBorder(theme, focused: true, hasError: hasError),
      ),
      hint: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.dashSubtitle,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Reason',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.dashSubtitle,
            ),
          ),
        ],
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.dashSubtitle,
          size: 18.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: 8,
        decoration: BoxDecoration(
          color: theme.dashCardBg,
          border: Border.all(
            color: theme.dashBorderLight.withValues(alpha: 0.8),
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: ElevatedSurface.softShadows(),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 44.h,
      ),
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: theme.dashTitle,
      ),
      items: _absenceReasons
          .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedReason = val),
    );
  }

  Widget _descriptionField(DashboardTheme theme, {bool hasError = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: hasError
              ? Colors.red
              : (_descriptionFocused
                  ? theme.dashPrimary
                  : theme.dashBorderLight),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        onTap: () => setState(() => _descriptionFocused = true),
        onTapOutside: (_) => setState(() => _descriptionFocused = false),
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: theme.dashTitle,
        ),
        decoration: InputDecoration(
          hintText: 'Please describe the reason for your absence...',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: theme.dashMuted,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        ),
      ),
    );
  }
}
