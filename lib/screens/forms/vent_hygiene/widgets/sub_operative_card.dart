import 'package:chumley_navigator/screens/forms/vent_hygiene/models/sub_operative_controllers.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene/widgets/vent_hygiene_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubOperativeCard extends StatelessWidget {
  const SubOperativeCard({
    super.key,
    required this.theme,
    required this.controllers,
    required this.index,
  });

  final DashboardTheme theme;
  final SubOperativeControllers controllers;
  final int index;

  @override
  Widget build(BuildContext context) {
    final n = index + 1;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sub-operative $n',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
          SizedBox(height: 10.h),
          VentHygieneUiHelpers.labeledField(
            theme: theme,
            label: 'Sub-operative $n',
            child: VentHygieneUiHelpers.textField(
              theme: theme,
              controller: controllers.name,
              hint: 'Name',
            ),
          ),
          SizedBox(height: 10.h),
          VentHygieneUiHelpers.labeledField(
            theme: theme,
            label: 'Time Travel to Site (Hours)',
            child: VentHygieneUiHelpers.numberField(
              theme: theme,
              controller: controllers.travelHours,
              hint: 'e.g. 1.5',
              allowDecimal: true,
            ),
          ),
          SizedBox(height: 10.h),
          VentHygieneUiHelpers.labeledField(
            theme: theme,
            label: 'Total Cost of Operative',
            child: VentHygieneUiHelpers.numberField(
              theme: theme,
              controller: controllers.totalCost,
              hint: '0.00',
              allowDecimal: true,
            ),
          ),
        ],
      ),
    );
  }
}
