import 'package:chumley_navigator/screens/forms/ld/widgets/ld_form_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Customer Details Tab for LD Form — Operative Name, Property Image Description, Survey Date/Time.
class LdCustomerTab extends StatelessWidget {
  final DashboardTheme theme;
  final TextEditingController frontOfPropertyController;
  final TextEditingController operativeSearchController;
  final String? selectedOperative;
  final List<String> people;
  final DateTime? surveyDateTime;
  final String? dateTimeError;
  final ValueChanged<String?> onOperativeChanged;
  final VoidCallback onPickSurveyDate;
  final VoidCallback onPickSurveyTime;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const LdCustomerTab({
    super.key,
    required this.theme,
    required this.frontOfPropertyController,
    required this.operativeSearchController,
    required this.selectedOperative,
    required this.people,
    required this.surveyDateTime,
    required this.dateTimeError,
    required this.onOperativeChanged,
    required this.onPickSurveyDate,
    required this.onPickSurveyTime,
    required this.formatDate,
    required this.formatTime,
  });

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
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Operative Name',
          child: LdFormHelpers.buildSearchableDropdown(
            theme: theme,
            value: selectedOperative,
            items: people,
            hint: 'Search People',
            searchController: operativeSearchController,
            onChanged: onOperativeChanged,
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Description for image — Front of Property',
          child: LdFormHelpers.buildExpandableField(
            theme: theme,
            controller: frontOfPropertyController,
            hint: 'Describe the front-of-property image…',
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Survey Date / Time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: LdFormHelpers.buildPickerButton(
                      theme: theme,
                      icon: LucideIcons.calendar,
                      label: dateLabel,
                      onTap: onPickSurveyDate,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: LdFormHelpers.buildPickerButton(
                      theme: theme,
                      icon: LucideIcons.clock,
                      label: timeLabel,
                      onTap: onPickSurveyTime,
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
