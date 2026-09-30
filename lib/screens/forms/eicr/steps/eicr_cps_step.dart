import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EicrCpsStep extends StatelessWidget {
  const EicrCpsStep({
    super.key,
    required this.theme,
    required this.cpsScheme,
    required this.schemeRegController,
    required this.partPController,
    required this.cpsConfirm,
    required this.reportNumberController,
    required this.reasonController,
    required this.inspectionDatesController,
    required this.issuerNameController,
    required this.issuerPositionController,
    required this.onCpsSchemeChanged,
    required this.onCpsConfirmChanged,
  });

  final DashboardTheme theme;
  final String? cpsScheme;
  final TextEditingController schemeRegController;
  final TextEditingController partPController;
  final bool cpsConfirm;
  final TextEditingController reportNumberController;
  final TextEditingController reasonController;
  final TextEditingController inspectionDatesController;
  final TextEditingController issuerNameController;
  final TextEditingController issuerPositionController;

  final ValueChanged<String?> onCpsSchemeChanged;
  final ValueChanged<bool?> onCpsConfirmChanged;

  static const cpsSchemes = ['NICEIC', 'NAPIT', 'ECA', 'Stroma', 'Other'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(theme, 'Competent Person Scheme registration'),
        Text(
          'Your Competent Person Scheme registration must be recorded before any test results.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Competent Person Scheme *',
          EicrFormHelpers.dropdown(
            theme,
            cpsScheme,
            cpsSchemes,
            onCpsSchemeChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Scheme registration number *',
          EicrFormHelpers.textField(
            theme,
            schemeRegController,
            'Your enrolment / membership number',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Part P registration number (dwellings)',
          EicrFormHelpers.textField(theme, partPController, 'Optional'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.checkbox(
          theme,
          cpsConfirm,
          onCpsConfirmChanged,
          'I confirm my Competent Person Scheme registration is current and covers the work I am about to carry out on this installation. *',
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Report details (Sections A & B)'),
        EicrFormHelpers.field(
          theme,
          'Report number',
          EicrFormHelpers.textField(
            theme,
            reportNumberController,
            'Report number',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Reason for producing this report (Section B)',
          EicrFormHelpers.textField(
            theme,
            reasonController,
            'Reason…',
            maxLines: 2,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Date(s) on which inspection and testing was carried out',
          EicrFormHelpers.textField(
            theme,
            inspectionDatesController,
            'e.g. 03 Aug 2026',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Issuer details - name',
          EicrFormHelpers.textField(theme, issuerNameController, 'Issuer name'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Issuer details - position',
          EicrFormHelpers.textField(
            theme,
            issuerPositionController,
            'Position',
          ),
        ),
      ],
    );
  }
}
