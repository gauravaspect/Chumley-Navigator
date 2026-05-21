import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/absences/absence_calendar.dart';
import 'package:chumley_navigator/widgets/absences/absence_form_card.dart';
import 'package:chumley_navigator/widgets/absences/absence_time_field.dart';
import 'package:chumley_navigator/widgets/absences/absence_whole_day_switch.dart';
import 'package:chumley_navigator/widgets/absences/cupertino_time_picker_sheet.dart';
import 'package:chumley_navigator/widgets/absences/my_absence_card.dart';
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

  static final List<MyAbsenceRecord> _myAbsences = [
    MyAbsenceRecord(
      reason: 'Holiday',
      dateRange: '12 May 2026 – 16 May 2026',
      status: 'Approved',
      statusColor: AppColors.successText,
      statusBackground: AppColors.successBackground,
    ),
    MyAbsenceRecord(
      reason: 'Sick / Unplanned Absence',
      dateRange: '3 Apr 2026 · 09:00 – 13:00',
      status: 'Pending',
      statusColor: AppColors.pendingText,
      statusBackground: AppColors.pendingBackground,
    ),
    MyAbsenceRecord(
      reason: 'Early Finish',
      dateRange: '28 Mar 2026 · 14:00 – 17:00',
      status: 'Approved',
      statusColor: AppColors.successText,
      statusBackground: AppColors.successBackground,
    ),
  ];

  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;
  bool _wholeDay = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _selectedDate;

  late final Map<DateTime, AbsenceDayMark> _calendarMarks;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;
    _calendarMarks = {
      today.add(const Duration(days: 2)): AbsenceDayMark.absence,
      today.add(const Duration(days: 5)): AbsenceDayMark.absence,
      today.add(const Duration(days: 8)): AbsenceDayMark.availability,
      today.add(const Duration(days: 12)): AbsenceDayMark.absence,
      today.add(const Duration(days: 15)): AbsenceDayMark.availability,
    };
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please enter your start and end time',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkBlue,
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _formatSelectedDate(_selectedDate!),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      AbsenceTimeField(
                        label: 'Start Time',
                        time: _wholeDay ? null : _startTime,
                        enabled: !_wholeDay,
                        onTap: () => _pickTime(isStart: true),
                      ),
                      SizedBox(height: 12.h),
                      AbsenceTimeField(
                        label: 'End Time',
                        time: _wholeDay ? null : _endTime,
                        enabled: !_wholeDay,
                        onTap: () => _pickTime(isStart: false),
                      ),
                      SizedBox(height: 16.h),
                      AbsenceWholeDaySwitch(
                        value: _wholeDay,
                        onChanged: (val) => setState(() {
                          _wholeDay = val;
                          if (val) {
                            _startTime = null;
                            _endTime = null;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit an Absence',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkBlue,
                        ),
                      ),
                      Text(
                        'Please choose from the below reasons',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBodyMuted,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _absenceReasonDropdown(),
                      SizedBox(height: 16.h),
                      Text(
                        'Detailed Description',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _descriptionField(),
                      SizedBox(height: 20.h),
                      PrimaryCtaButton(
                        label: 'Submit Absence',
                        icon: LucideIcons.calendar_check,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: MyAbsencesSection(records: _myAbsences),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Selected: ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  InputBorder _fieldBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: focused
            ? AppColors.accentBlue.withValues(alpha: 0.65)
            : AppColors.chartFillBlue.withValues(alpha: 0.55),
        width: focused ? 1 : 0.5,
      ),
    );
  }

  Widget _absenceReasonDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedReason,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceLightBlue.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(focused: true),
      ),
      hint: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            'Reason',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textDarkBlue,
          size: 22.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: 8,
        decoration: BoxDecoration(
          color: ElevatedSurface.tintedFill,
          border: Border.all(
            color: AppColors.borderDefault.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: ElevatedSurface.softShadows(),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 44.h,
      ),
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textDarkBlue,
      ),
      items: _absenceReasons
          .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedReason = val),
    );
  }

  Widget _descriptionField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _descriptionFocused
              ? AppColors.accentBlue.withValues(alpha: 0.55)
              : AppColors.chartFillBlue.withValues(alpha: 0.5),
          width: _descriptionFocused ? 1 : 0.5,
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        onTap: () => setState(() => _descriptionFocused = true),
        onTapOutside: (_) => setState(() => _descriptionFocused = false),
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.45,
          color: AppColors.textDarkBlue,
        ),
        decoration: InputDecoration(
          hintText: 'Add any additional details…',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPlaceholder,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14.r),
        ),
      ),
    );
  }
}
