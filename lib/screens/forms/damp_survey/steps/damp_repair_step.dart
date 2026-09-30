import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampRepairStep extends StatelessWidget {
  const DampRepairStep({
    super.key,
    required this.theme,
    required this.didMakeRepair,
    required this.beforeRepairPhotoDescController,
    required this.repairKind,
    required this.worksUndertakenController,
    required this.repairDurationController,
    required this.materialsUsedController,
    required this.boughtMaterials,
    required this.materialCostController,
    required this.afterRepairImageDescController,
    required this.onDidMakeRepairChanged,
    required this.onRepairKindChanged,
    required this.onBoughtMaterialsChanged,
  });

  final DashboardTheme theme;
  final String? didMakeRepair;
  final TextEditingController beforeRepairPhotoDescController;
  final String? repairKind;
  final TextEditingController worksUndertakenController;
  final TextEditingController repairDurationController;
  final TextEditingController materialsUsedController;
  final String? boughtMaterials;
  final TextEditingController materialCostController;
  final TextEditingController afterRepairImageDescController;

  final ValueChanged<String?> onDidMakeRepairChanged;
  final ValueChanged<String?> onRepairKindChanged;
  final ValueChanged<String?> onBoughtMaterialsChanged;

  static const yesNoOptions = ['Yes', 'No'];
  static const yesNoPartialOptions = ['Yes', 'No', 'Partial'];
  static const repairKindOptions = [
    'Temporary',
    'Permanent',
    'Make-safe',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Did you make the repair',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: didMakeRepair,
            items: yesNoPartialOptions,
            hint: 'Select option',
            onChanged: onDidMakeRepairChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description for photo — Before repairs done',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: beforeRepairPhotoDescController,
            hint: 'Describe the before-repair photo…',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'What kind of repair was done',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: repairKind,
            items: repairKindOptions,
            hint: 'Select repair type',
            onChanged: onRepairKindChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description of works undertaken',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: worksUndertakenController,
            hint: 'Describe works undertaken',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'How long it took to make the repairs',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: repairDurationController,
            hint: 'e.g. 2 hours',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Materials used during repairs',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: materialsUsedController,
            hint: 'List materials used',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Buy any materials to carry out repairs?',
          child: DampSurveyUiHelpers.simpleDropdown(
            theme: theme,
            value: boughtMaterials,
            items: yesNoOptions,
            hint: 'Select option',
            onChanged: onBoughtMaterialsChanged,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'How much material costed for repairs',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: materialCostController,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Description of image after repairs carried out',
          child: DampSurveyUiHelpers.expandableField(
            theme: theme,
            controller: afterRepairImageDescController,
            hint: 'Describe the after-repair image…',
          ),
        ),
      ],
    );
  }
}
