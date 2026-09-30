import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DampCustomerStep extends StatelessWidget {
  const DampCustomerStep({
    super.key,
    required this.theme,
    required this.selectedOperative,
    required this.operativeSearchController,
    required this.frontOfPropertyController,
    required this.surveyDateTime,
    required this.dateTimeError,
    required this.onOperativeChanged,
    required this.onPickDate,
    required this.onPickTime,
  });

  final DashboardTheme theme;
  final String? selectedOperative;
  final TextEditingController operativeSearchController;
  final TextEditingController frontOfPropertyController;
  final DateTime? surveyDateTime;
  final String? dateTimeError;
  final ValueChanged<String?> onOperativeChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  static const people = [
    'Alex Morgan',
    'Jordan Lee',
    'Sam Patel',
    'Taylor Brooks',
    'Casey Nguyen',
  ];

  static const _months = [
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
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String formatDate(DateTime dt) {
    return '${_weekdays[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = surveyDateTime == null
        ? 'Select date'
        : formatDate(surveyDateTime!);
    final timeLabel = surveyDateTime == null
        ? 'Select time'
        : formatTime(surveyDateTime!);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Operative Name',
          child: DampSurveyUiHelpers.searchableDropdown(
            theme: theme,
            value: selectedOperative,
            items: people,
            hint: 'Search People',
            searchController: operativeSearchController,
            onChanged: onOperativeChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description for image — Front of Property',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: frontOfPropertyController,
            hint: 'Describe the front-of-property image…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Survey Date / Time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DampSurveyUiHelpers.pickerButton(
                      theme: theme,
                      icon: LucideIcons.calendar,
                      label: dateLabel,
                      onTap: onPickDate,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: DampSurveyUiHelpers.pickerButton(
                      theme: theme,
                      icon: LucideIcons.clock,
                      label: timeLabel,
                      onTap: onPickTime,
                    ),
                  ),
                ],
              ),
              if (dateTimeError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  dateTimeError!,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.errorText),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
