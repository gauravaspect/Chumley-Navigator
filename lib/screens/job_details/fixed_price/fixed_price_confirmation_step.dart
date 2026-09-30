import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceConfirmationStep extends StatelessWidget {
  const FixedPriceConfirmationStep({
    super.key,
    required this.theme,
    required this.scopeOfWorkText,
    required this.scopeScrollController,
    required this.totalCustomerCharges,
    required this.customerConfirmationChoice,
    required this.onCustomerConfirmationChoiceChanged,
  });

  final DashboardTheme theme;
  final String scopeOfWorkText;
  final ScrollController scopeScrollController;
  final double totalCustomerCharges;
  final String? customerConfirmationChoice;
  final ValueChanged<String> onCustomerConfirmationChoiceChanged;

  @override
  Widget build(BuildContext context) {
    final subtotal = totalCustomerCharges;
    final vat = subtotal * 0.20;
    final total = subtotal + vat;
    final deposit = total * 0.50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Scope of Work',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 160.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Scrollbar(
            controller: scopeScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scopeScrollController,
              padding: EdgeInsets.all(12.r),
              physics: const BouncingScrollPhysics(),
              child: Text(
                scopeOfWorkText,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: theme.text,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing Summary',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildPricingSummaryItem(
                'Subtotal',
                '£${subtotal.toStringAsFixed(2)}',
                theme,
              ),
              FixedPriceUiHelpers.buildPricingSummaryItem(
                'VAT',
                '£${vat.toStringAsFixed(2)}',
                theme,
              ),
              Divider(color: theme.border, height: 16.h),
              FixedPriceUiHelpers.buildPricingSummaryItem(
                'Total incl. VAT',
                '£${total.toStringAsFixed(2)}',
                theme,
                isTotal: true,
              ),
              Divider(color: theme.border, height: 16.h),
              FixedPriceUiHelpers.buildPricingSummaryItem(
                'Deposit Required',
                '£${deposit.toStringAsFixed(2)}',
                theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please confirm Customer's choice",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildRadioButtonSection<String>(
                label: 'Choice *',
                selectedValue: customerConfirmationChoice,
                options: const [
                  {
                    'label': 'Send Estimate to Customer',
                    'value': 'Send Estimate to Customer',
                  },
                  {'label': 'Reject', 'value': 'Reject'},
                ],
                onChanged: onCustomerConfirmationChoiceChanged,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
