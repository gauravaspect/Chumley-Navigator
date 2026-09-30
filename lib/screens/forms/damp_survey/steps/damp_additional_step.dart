import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampAdditionalStep extends StatelessWidget {
  const DampAdditionalStep({
    super.key,
    required this.theme,
    required this.needAdditionalComments,
    required this.additionalCommentsController,
    required this.onNeedAdditionalCommentsChanged,
  });

  final DashboardTheme theme;
  final String? needAdditionalComments;
  final TextEditingController additionalCommentsController;
  final ValueChanged<String?> onNeedAdditionalCommentsChanged;

  static const yesNoOptions = ['Yes', 'No'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Do you need to add additional comments',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: needAdditionalComments,
            items: yesNoOptions,
            hint: 'Select option',
            onChanged: onNeedAdditionalCommentsChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Additional feedbacks / comments',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: additionalCommentsController,
            hint: 'Enter additional comments…',
          ),
        ),
      ],
    );
  }
}
