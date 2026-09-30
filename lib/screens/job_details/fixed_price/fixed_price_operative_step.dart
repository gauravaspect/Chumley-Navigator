import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceOperativeStep extends StatelessWidget {
  const FixedPriceOperativeStep({
    super.key,
    required this.theme,
    required this.durationHoursController,
    required this.durationHoursFocusNode,
    required this.durationHoursFocused,
    required this.durationHours,
    required this.selectedLabourRate,
    required this.onLabourRateChanged,
    required this.listPriceServiceCost,
    required this.materialsCharge,
    required this.attendanceFee,
    required this.ulezCharge,
    required this.collectionFee,
    required this.chargeDrainagePatches,
    required this.drainagePatchesFee,
    required this.totalCustomerCharges,
  });

  final DashboardTheme theme;
  final TextEditingController durationHoursController;
  final FocusNode durationHoursFocusNode;
  final bool durationHoursFocused;
  final double? durationHours;
  final String? selectedLabourRate;
  final ValueChanged<String> onLabourRateChanged;
  final double listPriceServiceCost;
  final double materialsCharge;
  final double attendanceFee;
  final double ulezCharge;
  final double collectionFee;
  final bool chargeDrainagePatches;
  final double drainagePatchesFee;
  final double totalCustomerCharges;

  @override
  Widget build(BuildContext context) {
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
                'Operative Summary',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildSummaryIndicatorRow(
                'This site is in Zone A',
                theme,
              ),
              FixedPriceUiHelpers.buildSummaryIndicatorRow(
                '10% Zonal Discount has been applied to the Trade Rate Card.',
                theme,
              ),
              FixedPriceUiHelpers.buildSummaryIndicatorRow(
                'Discount based on Dog: 0%',
                theme,
              ),
              FixedPriceUiHelpers.buildSummaryIndicatorRow(
                'Job Duration Discount: 0%',
                theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Duration',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildDecimalField(
                label: 'Duration (hours) *',
                controller: durationHoursController,
                focusNode: durationHoursFocusNode,
                isFocused: durationHoursFocused,
                hintText: 'e.g. 2.83',
                theme: theme,
                errorText:
                    durationHours == null &&
                        durationHoursController.text.trim().isNotEmpty
                    ? 'Enter a valid duration greater than 0.'
                    : durationHours == null &&
                          durationHoursController.text.trim().isEmpty
                    ? 'Duration is required.'
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Labour Rate',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildRadioButtonSection<String>(
                label: 'Select One *',
                selectedValue: selectedLabourRate,
                options: const [
                  {
                    'label': 'Rate 1 (£80.00/hr)',
                    'value': 'Rate 1',
                    'subtitle': 'Standard daytime rate',
                  },
                  {
                    'label': 'Rate 2 (£90.00/hr)',
                    'value': 'Rate 2',
                    'subtitle': 'Evening/Saturday rate',
                  },
                  {
                    'label': 'Rate 3 (£100.00/hr)',
                    'value': 'Rate 3',
                    'subtitle': 'Night/Sunday rate',
                  },
                ],
                onChanged: onLabourRateChanged,
                theme: theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Charges',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildChargeRow(
                'List Price Services',
                listPriceServiceCost,
                theme,
              ),
              FixedPriceUiHelpers.buildChargeRow(
                'Materials Charge',
                materialsCharge,
                theme,
              ),
              FixedPriceUiHelpers.buildChargeRow(
                'Labour',
                attendanceFee,
                theme,
              ),
              FixedPriceUiHelpers.buildChargeRow(
                'ULEZ Charge',
                ulezCharge,
                theme,
              ),
              FixedPriceUiHelpers.buildChargeRow(
                'Collection Fee',
                collectionFee,
                theme,
              ),
              if (chargeDrainagePatches)
                FixedPriceUiHelpers.buildChargeRow(
                  'Drainage Patches Charge',
                  drainagePatchesFee,
                  theme,
                ),
              Divider(color: theme.border, height: 16.h),
              FixedPriceUiHelpers.buildChargeRow(
                'Total Customer Charges',
                totalCustomerCharges,
                theme,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
