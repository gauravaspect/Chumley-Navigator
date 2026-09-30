import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampVisualStep extends StatelessWidget {
  const DampVisualStep({
    super.key,
    required this.theme,
    required this.visualImageDescController,
    required this.visualFindingsController,
    required this.weather,
    required this.weatherOtherController,
    required this.accessType,
    required this.accessLocation,
    required this.accessMadeOtherController,
    required this.whatAccessed,
    required this.whatAccessedOtherController,
    required this.afterAccessImageDescController,
    required this.onWeatherChanged,
    required this.onAccessTypeChanged,
    required this.onAccessLocationChanged,
    required this.onWhatAccessedChanged,
  });

  final DashboardTheme theme;
  final TextEditingController visualImageDescController;
  final TextEditingController visualFindingsController;
  final String? weather;
  final TextEditingController weatherOtherController;
  final String? accessType;
  final String? accessLocation;
  final TextEditingController accessMadeOtherController;
  final String? whatAccessed;
  final TextEditingController whatAccessedOtherController;
  final TextEditingController afterAccessImageDescController;

  final ValueChanged<String?> onWeatherChanged;
  final ValueChanged<String?> onAccessTypeChanged;
  final ValueChanged<String?> onAccessLocationChanged;
  final ValueChanged<String?> onWhatAccessedChanged;

  static const weatherOptions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Windy',
    'Foggy',
    'Other',
  ];

  static const accessTypeOptions = ['Internal', 'External', 'Both'];
  static const accessLocationOptions = [
    'Roof space',
    'Floor void',
    'Wall cavity',
    'Under stairs',
    'Cupboard',
    'Other',
  ];
  static const whatAccessedOptions = [
    'Pipework',
    'Tank',
    'Radiator',
    'Floorboards',
    'Ceiling',
    'Wall',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description for visual inspection image',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: visualImageDescController,
            hint: 'Describe the visual inspection image…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Findings from visual inspection',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: visualFindingsController,
            hint: 'Record findings…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'How is the weather during survey',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: weather,
            items: weatherOptions,
            hint: 'Select weather',
            onChanged: onWeatherChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Weather other details',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: weatherOtherController,
            hint: 'Additional weather details…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Was the access internal or external',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: accessType,
            items: accessTypeOptions,
            hint: 'Select access type',
            onChanged: onAccessTypeChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Where was this access made',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: accessLocation,
            items: accessLocationOptions,
            hint: 'Select location',
            onChanged: onAccessLocationChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Access made other',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: accessMadeOtherController,
            hint: 'Other access details',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'What was accessed',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: whatAccessed,
            items: whatAccessedOptions,
            hint: 'Select what was accessed',
            onChanged: onWhatAccessedChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'What was accessed other',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: whatAccessedOtherController,
            hint: 'Other details',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description of image after access has been made',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: afterAccessImageDescController,
            hint: 'Describe the image after access…',
          ),
        ),
      ],
    );
  }
}
