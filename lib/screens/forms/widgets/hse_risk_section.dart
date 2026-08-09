import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared EICR-style Risk & HSE gatekeeper fields for engineer forms.
class HseRiskFormController {
  String? riskAssessment;
  String? workAtHeight;
  String? safeIsolation;
  String? clientBriefed;
  String? vulnerable;
  final riskNoteController = TextEditingController();

  static const riskAssessmentOptions = [
    'Yes - risk assessment completed, standard controls in place',
    'Yes - risk assessment completed, additional controls in place (note below)',
    'Yes - risk assessment identifies low-medium risk, work proceeds with controls',
    'STOP - risk cannot be safely controlled today, work not commenced',
  ];

  static const workAtHeightOptions = [
    'Yes - work at height in scope today',
    'No - task is ground-level only',
  ];

  static const safeIsolationOptions = [
    'Yes - locked off and proved dead',
    'Partial - supervised',
    'Not possible - STOP',
  ];

  static const clientBriefedOptions = [
    'Briefed and consent given',
    'Unable to contact - proceed per instruction',
    'Refused - STOP',
  ];

  static const vulnerableOptions = [
    'None present',
    'Present - arrangements made',
    'Present - STOP until arranged',
  ];

  void clear() {
    riskAssessment = null;
    workAtHeight = null;
    safeIsolation = null;
    clientBriefed = null;
    vulnerable = null;
    riskNoteController.clear();
  }

  void dispose() {
    riskNoteController.dispose();
  }
}

/// Renders the same Risk & HSE block used on the EICR form.
class HseRiskSection extends StatelessWidget {
  const HseRiskSection({
    super.key,
    required this.theme,
    required this.controller,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
    this.accentColor = AppColors.primaryBlue,
  });

  final DashboardTheme theme;
  final HseRiskFormController controller;
  final VoidCallback onChanged;
  final EdgeInsetsGeometry padding;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Property & installation details'),
          Text(
            'Property details will populate from the site record.',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('On-site risk assessment'),
          Text(
            'Confirm the on-site risk assessment is complete before you start work.',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
          SizedBox(height: 10.h),
          _labeled(
            'Has an on-site risk assessment been completed? *',
            _dropdown(
              value: controller.riskAssessment,
              items: HseRiskFormController.riskAssessmentOptions,
              onChanged: (v) {
                controller.riskAssessment = v;
                onChanged();
              },
            ),
          ),
          SizedBox(height: 12.h),
          _labeled(
            'Additional controls note',
            _textField(
              controller.riskNoteController,
              'Note (if required)…',
              maxLines: 3,
            ),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('Work at Height - pre-work'),
          Text(
            'WAHR 2005 reminder. Will today\'s task involve work where a fall could cause injury?',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
          SizedBox(height: 10.h),
          _labeled(
            'Will today\'s task involve work where a fall could cause injury? *',
            _dropdown(
              value: controller.workAtHeight,
              items: HseRiskFormController.workAtHeightOptions,
              onChanged: (v) {
                controller.workAtHeight = v;
                onChanged();
              },
            ),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('HSE gatekeeper checks'),
          _labeled(
            'Safe isolation procedure followed (High risk)',
            _dropdown(
              value: controller.safeIsolation,
              items: HseRiskFormController.safeIsolationOptions,
              onChanged: (v) {
                controller.safeIsolation = v;
                onChanged();
              },
            ),
          ),
          SizedBox(height: 12.h),
          _labeled(
            'Client briefed on power interruption (High risk)',
            _dropdown(
              value: controller.clientBriefed,
              items: HseRiskFormController.clientBriefedOptions,
              onChanged: (v) {
                controller.clientBriefed = v;
                onChanged();
              },
            ),
          ),
          SizedBox(height: 12.h),
          _labeled(
            'Vulnerable occupants considered (medical equipment, lifts) (High risk)',
            _dropdown(
              value: controller.vulnerable,
              items: HseRiskFormController.vulnerableOptions,
              onChanged: (v) {
                controller.vulnerable = v;
                onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: theme.dashHeading,
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.textBody,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: theme.surfaceDeep,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: theme.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: theme.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: accentColor, width: 1),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      decoration: _decoration().copyWith(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: _decoration().copyWith(
        contentPadding: EdgeInsets.only(right: 8.w),
      ),
      hint: Text(
        'Select…',
        style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.textMuted,
          size: 20.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 280.h,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
