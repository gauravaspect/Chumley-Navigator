import 'package:chumley_navigator/components/common/aspect_branding.dart';
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

  /// Matches mockup empty state; replace with API data when wired.
  static const List<MyAbsenceRecord> _myAbsences = [];

  static const _absencesLoadFailed = true;

  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;
  bool _wholeDay = false;
  TimeOfDay? _startTime = _defaultStart;
  TimeOfDay? _endTime = _defaultEnd;
  DateTime? _selectedDate;

  late final Map<DateTime, AbsenceDayMark> _calendarMarks;

  bool get _canSubmit => _selectedReason != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;
    _calendarMarks = {};
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: theme.dashPrimary,
            ),
          ),
          child: Scaffold(
            backgroundColor: theme.base,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 112.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AspectBranding(),
                    SizedBox(height: 16.h),
                    FadeSlideIn(
                      child: AbsenceCalendar(
                        markedDays: _calendarMarks,
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
                                    time: _wholeDay ? null : _startTime,
                                    enabled: !_wholeDay,
                                    onTap: () => _pickTime(isStart: true),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: AbsenceTimeField(
                                    label: 'End Time:',
                                    time: _wholeDay ? null : _endTime,
                                    enabled: !_wholeDay,
                                    onTap: () => _pickTime(isStart: false),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            AbsenceWholeDaySwitch(
                              value: _wholeDay,
                              onChanged: (val) => setState(() {
                                _wholeDay = val;
                                if (val) {
                                  _startTime = null;
                                  _endTime = null;
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            _absenceReasonDropdown(theme),
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
                            _descriptionField(theme),
                            SizedBox(height: 16.h),
                            Opacity(
                              opacity: _canSubmit ? 1 : 0.5,
                              child: PrimaryCtaButton(
                                label: 'Submit absence',
                                icon: LucideIcons.calendar_check,
                                borderRadius: 8.r,
                                height: 48.h,
                                backgroundColor: theme.dashPrimary,
                                onTap: _canSubmit ? () {} : null,
                              ),
                            ),
                            if (_absencesLoadFailed) ...[
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
                      child: MyAbsencesSection(
                        records: _myAbsences,
                        loadFailed: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputBorder _fieldBorder(DashboardTheme theme, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: focused ? theme.dashPrimary : theme.dashBorderLight,
        width: 1,
      ),
    );
  }

  Widget _absenceReasonDropdown(DashboardTheme theme) {
    return DropdownButtonFormField2<String>(
      value: _selectedReason,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.dashCardBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        border: _fieldBorder(theme),
        enabledBorder: _fieldBorder(theme),
        focusedBorder: _fieldBorder(theme, focused: true),
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

  Widget _descriptionField(DashboardTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _descriptionFocused
              ? theme.dashPrimary
              : theme.dashBorderLight,
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
