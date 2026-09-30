import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampEstimateStep extends StatelessWidget {
  const DampEstimateStep({
    super.key,
    required this.theme,
    required this.furtherWorkRequired,
    required this.furtherWorksDescController,
    required this.onFurtherWorkRequiredChanged,
  });

  final DashboardTheme theme;
  final String? furtherWorkRequired;
  final TextEditingController furtherWorksDescController;
  final ValueChanged<String?> onFurtherWorkRequiredChanged;

  static const furtherWorkOptions = ['Yes', 'No', 'Monitor'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Further work required to restore area',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: furtherWorkRequired,
            items: furtherWorkOptions,
            hint: 'Select option',
            onChanged: onFurtherWorkRequiredChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description of further works required',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: furtherWorksDescController,
            hint: 'Describe further works…',
          ),
        ),
      ],
    );
  }
}
