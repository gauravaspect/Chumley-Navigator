import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceScopeStep extends StatelessWidget {
  const FixedPriceScopeStep({
    super.key,
    required this.theme,
    required this.selectedTradeName,
    required this.selectedCategoryName,
    required this.selectedWorkTypeName,
    required this.scopeOfWorkController,
    required this.scopeOfWorkFocusNode,
    required this.scopeOfWorkFocused,
    required this.additionalScope2Controller,
    required this.additionalScope2FocusNode,
    required this.additionalScope2Focused,
    required this.additionalScope3Controller,
    required this.additionalScope3FocusNode,
    required this.additionalScope3Focused,
  });

  final DashboardTheme theme;
  final String selectedTradeName;
  final String selectedCategoryName;
  final String selectedWorkTypeName;
  final TextEditingController scopeOfWorkController;
  final FocusNode scopeOfWorkFocusNode;
  final bool scopeOfWorkFocused;
  final TextEditingController additionalScope2Controller;
  final FocusNode additionalScope2FocusNode;
  final bool additionalScope2Focused;
  final TextEditingController additionalScope3Controller;
  final FocusNode additionalScope3FocusNode;
  final bool additionalScope3Focused;

  @override
  Widget build(BuildContext context) {
    final hasScopeError =
        scopeOfWorkController.text.trim().isNotEmpty &&
        scopeOfWorkController.text.split('\n').length < 5;

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
                'Selected Work Type',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildInfoRow(
                'Trade:',
                selectedTradeName,
                theme,
              ),
              FixedPriceUiHelpers.buildInfoRow(
                'Group:',
                selectedCategoryName,
                theme,
              ),
              FixedPriceUiHelpers.buildInfoRow(
                'Work Type:',
                selectedWorkTypeName,
                theme,
              ),
              Divider(color: theme.border, height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Approval Limit',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    '£50,000',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.streakOrange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Your estimate may be priced over this value and accepted by the customer. If it is not accepted via the app it will automatically be sent to the Trade Manager before becoming available to the customer.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        FixedPriceUiHelpers.buildMultilineTextField(
          label: 'Scope of Work',
          controller: scopeOfWorkController,
          focusNode: scopeOfWorkFocusNode,
          isFocused: scopeOfWorkFocused,
          hintText: 'Enter scope of work...',
          theme: theme,
          isRequired: true,
          errorText: hasScopeError
              ? 'Scope of work must be at least 5 lines.'
              : null,
        ),
        SizedBox(height: 12.h),
        FixedPriceUiHelpers.buildMultilineTextField(
          label: 'Additional Scope of Work 2',
          controller: additionalScope2Controller,
          focusNode: additionalScope2FocusNode,
          isFocused: additionalScope2Focused,
          hintText: 'Enter additional scope of work (optional)...',
          theme: theme,
        ),
        SizedBox(height: 12.h),
        FixedPriceUiHelpers.buildMultilineTextField(
          label: 'Additional Scope of Work 3',
          controller: additionalScope3Controller,
          focusNode: additionalScope3FocusNode,
          isFocused: additionalScope3Focused,
          hintText: 'Enter additional scope of work (optional)...',
          theme: theme,
        ),
      ],
    );
  }
}
