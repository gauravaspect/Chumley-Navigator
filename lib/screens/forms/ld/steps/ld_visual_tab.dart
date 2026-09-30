import 'package:chumley_navigator/screens/forms/ld/widgets/ld_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compulsory Visual Inspection Tab for LD Form — Description, Findings, Weather.
class LdVisualTab extends StatelessWidget {
  final DashboardTheme theme;
  final TextEditingController visualImageDescController;
  final TextEditingController visualFindingsController;
  final TextEditingController weatherOtherController;
  final String? selectedWeather;
  final List<String> weatherOptions;
  final ValueChanged<String?> onWeatherChanged;

  const LdVisualTab({
    super.key,
    required this.theme,
    required this.visualImageDescController,
    required this.visualFindingsController,
    required this.weatherOtherController,
    required this.selectedWeather,
    required this.weatherOptions,
    required this.onWeatherChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Description for visual inspection image',
          child: LdFormHelpers.buildExpandableField(
            theme: theme,
            controller: visualImageDescController,
            hint: 'Describe the visual inspection image…',
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Findings from visual inspection',
          child: LdFormHelpers.buildExpandableField(
            theme: theme,
            controller: visualFindingsController,
            hint: 'Record findings from the visual inspection…',
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'How is the weather during survey',
          child: LdFormHelpers.buildSimpleDropdown(
            theme: theme,
            value: selectedWeather,
            items: weatherOptions,
            hint: 'Select weather',
            onChanged: onWeatherChanged,
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Weather other details',
          child: LdFormHelpers.buildExpandableField(
            theme: theme,
            controller: weatherOtherController,
            hint: 'Additional weather details…',
          ),
        ),
      ],
    );
  }
}
