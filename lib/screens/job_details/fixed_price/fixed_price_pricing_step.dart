import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPricePricingStep extends StatelessWidget {
  const FixedPricePricingStep({
    super.key,
    required this.theme,
    required this.collectionFeeApplicable,
    required this.onCollectionFeeApplicableChanged,
    required this.selectedListPriceService,
    required this.onListPriceServiceChanged,
    required this.listPriceServices,
    required this.materialCostOperativeController,
    required this.materialCostOperativeFocusNode,
    required this.materialCostOperativeFocused,
    required this.descriptionMaterialsOperativeController,
    required this.descriptionMaterialsOperativeFocusNode,
    required this.descriptionMaterialsOperativeFocused,
    required this.chargeDrainagePatches,
    required this.onChargeDrainagePatchesChanged,
    required this.materialCostAspectController,
    required this.materialCostAspectFocusNode,
    required this.materialCostAspectFocused,
    required this.descriptionMaterialsAspectController,
    required this.descriptionMaterialsAspectFocusNode,
    required this.descriptionMaterialsAspectFocused,
    required this.ulezChargeApplicable,
    required this.onUlezChargeApplicableChanged,
    required this.materialCostError,
  });

  final DashboardTheme theme;
  final bool? collectionFeeApplicable;
  final ValueChanged<bool?> onCollectionFeeApplicableChanged;
  final String? selectedListPriceService;
  final ValueChanged<String?> onListPriceServiceChanged;
  final List<Map<String, dynamic>> listPriceServices;
  final TextEditingController materialCostOperativeController;
  final FocusNode materialCostOperativeFocusNode;
  final bool materialCostOperativeFocused;
  final TextEditingController descriptionMaterialsOperativeController;
  final FocusNode descriptionMaterialsOperativeFocusNode;
  final bool descriptionMaterialsOperativeFocused;
  final bool chargeDrainagePatches;
  final ValueChanged<bool> onChargeDrainagePatchesChanged;
  final TextEditingController materialCostAspectController;
  final FocusNode materialCostAspectFocusNode;
  final bool materialCostAspectFocused;
  final TextEditingController descriptionMaterialsAspectController;
  final FocusNode descriptionMaterialsAspectFocusNode;
  final bool descriptionMaterialsAspectFocused;
  final bool? ulezChargeApplicable;
  final ValueChanged<bool?> onUlezChargeApplicableChanged;
  final String? Function(TextEditingController) materialCostError;

  @override
  Widget build(BuildContext context) {
    final listPriceLabels = listPriceServices
        .map((s) => s['label'] as String)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing & Materials',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 16.h),
              FixedPriceUiHelpers.buildRadioButtonSection<bool>(
                label: 'Collection Fee Applicable *',
                selectedValue: collectionFeeApplicable,
                options: const [
                  {'label': 'Yes', 'value': true},
                  {'label': 'No', 'value': false},
                ],
                onChanged: onCollectionFeeApplicableChanged,
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              FixedPriceUiHelpers.buildDropdownField(
                label: 'List Price Services *',
                value: selectedListPriceService != null
                    ? listPriceServices.firstWhere(
                        (s) => s['value'] == selectedListPriceService,
                        orElse: () => {'label': ''},
                      )['label']
                    : null,
                items: listPriceLabels,
                hintText: 'Select List Price Service',
                onChanged: (val) {
                  if (val != null) {
                    final match = listPriceServices.firstWhere(
                      (s) => s['label'] == val,
                      orElse: () => {'value': null},
                    );
                    onListPriceServiceChanged(match['value'] as String?);
                  } else {
                    onListPriceServiceChanged(null);
                  }
                },
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              FixedPriceUiHelpers.buildCurrencyField(
                label: 'Material Cost for Operative',
                controller: materialCostOperativeController,
                focusNode: materialCostOperativeFocusNode,
                isFocused: materialCostOperativeFocused,
                theme: theme,
                errorText: materialCostError(materialCostOperativeController),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildMultilineTextField(
                label: 'Description of Materials supplied by Operative',
                controller: descriptionMaterialsOperativeController,
                focusNode: descriptionMaterialsOperativeFocusNode,
                isFocused: descriptionMaterialsOperativeFocused,
                hintText: 'Describe materials...',
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              FixedPriceUiHelpers.buildToggleSwitch(
                label: 'Charge Drainage Patches',
                value: chargeDrainagePatches,
                onChanged: onChargeDrainagePatchesChanged,
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              FixedPriceUiHelpers.buildCurrencyField(
                label: 'Material Cost for Aspect',
                controller: materialCostAspectController,
                focusNode: materialCostAspectFocusNode,
                isFocused: materialCostAspectFocused,
                theme: theme,
                errorText: materialCostError(materialCostAspectController),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildMultilineTextField(
                label: 'Description of Materials supplied by Aspect',
                controller: descriptionMaterialsAspectController,
                focusNode: descriptionMaterialsAspectFocusNode,
                isFocused: descriptionMaterialsAspectFocused,
                hintText: 'Describe materials...',
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              FixedPriceUiHelpers.buildRadioButtonSection<bool>(
                label: 'ULEZ Charge Applicable *',
                selectedValue: ulezChargeApplicable,
                options: const [
                  {'label': 'Yes (£12.50)', 'value': true},
                  {'label': 'No', 'value': false},
                ],
                onChanged: onUlezChargeApplicableChanged,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
