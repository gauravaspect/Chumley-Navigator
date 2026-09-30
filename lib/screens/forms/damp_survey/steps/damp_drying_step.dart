import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampDryingStep extends StatelessWidget {
  const DampDryingStep({
    super.key,
    required this.theme,
    required this.dryingRequired,
    required this.dryingOption,
    required this.onDryingRequiredChanged,
    required this.onDryingOptionChanged,
  });

  final DashboardTheme theme;
  final String? dryingRequired;
  final String? dryingOption;
  final ValueChanged<String?> onDryingRequiredChanged;
  final ValueChanged<String?> onDryingOptionChanged;

  static const dryingRequiredOptions = ['Yes', 'No'];
  static const dryingMethodOptions = [
    'Dehumidifier',
    'Fans',
    'Natural ventilation',
    'Specialist drying',
    'Not applicable',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Does the area require drying',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: dryingRequired,
            items: dryingRequiredOptions,
            hint: 'Select option',
            onChanged: onDryingRequiredChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Please select the relevant options',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: dryingOption,
            items: dryingMethodOptions,
            hint: 'Select drying option',
            onChanged: onDryingOptionChanged,
          ),
        ),
      ],
    );
  }
}
