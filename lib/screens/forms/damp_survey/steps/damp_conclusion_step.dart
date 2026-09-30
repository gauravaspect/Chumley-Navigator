import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampConclusionStep extends StatelessWidget {
  const DampConclusionStep({
    super.key,
    required this.theme,
    required this.conclusion,
    required this.leakDescriptionController,
    required this.briefImageDescController,
    required this.furtherVisitRequired,
    required this.furtherVisitOtherController,
    required this.leakPresentController,
    required this.diagnosisMethods,
    required this.onConclusionChanged,
    required this.onFurtherVisitRequiredChanged,
    required this.onToggleDiagnosisMethod,
  });

  final DashboardTheme theme;
  final String? conclusion;
  final TextEditingController leakDescriptionController;
  final TextEditingController briefImageDescController;
  final String? furtherVisitRequired;
  final TextEditingController furtherVisitOtherController;
  final TextEditingController leakPresentController;
  final Set<String> diagnosisMethods;

  final ValueChanged<String?> onConclusionChanged;
  final ValueChanged<String?> onFurtherVisitRequiredChanged;
  final ValueChanged<String> onToggleDiagnosisMethod;

  static const conclusionOptions = [
    'Rising damp',
    'Penetrating damp',
    'Condensation',
    'Plumbing leak',
    'Combination',
    'Inconclusive',
  ];

  static const furtherVisitOptions = ['Yes', 'No', 'Monitor only', 'Other'];

  static const diagnosisMethodOptions = [
    'Thermal imaging',
    'Moisture profiling',
    'Trace dye',
    'Salt analysis',
    'Camera inspection',
    'Pressure test',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Following investigation what conclusion?',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: conclusion,
            items: conclusionOptions,
            hint: 'Select conclusion',
            onChanged: onConclusionChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description of the leak',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: leakDescriptionController,
            hint: 'Describe the leak…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Brief image description',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: briefImageDescController,
            hint: 'Brief description',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Why is a further visit required',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: furtherVisitRequired,
            items: furtherVisitOptions,
            hint: 'Select option',
            onChanged: onFurtherVisitRequiredChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Further visit required other',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: furtherVisitOtherController,
            hint: 'Other reasons for further visit…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Investigation leads to a leak be present',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: leakPresentController,
            hint: 'Describe investigation findings…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Method of diagnosis for next visit',
          child: DampSurveyUiHelpers.multiSelectChips(
            theme: theme,
            options: diagnosisMethodOptions,
            selected: diagnosisMethods,
            onToggle: onToggleDiagnosisMethod,
          ),
        ),
      ],
    );
  }
}
