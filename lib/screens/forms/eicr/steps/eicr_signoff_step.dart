import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EicrSignoffStep extends StatelessWidget {
  const EicrSignoffStep({
    super.key,
    required this.theme,
    required this.section1Items,
    required this.otherInspectionSections,
    required this.section1Outcomes,
    required this.sectionOutcomes,
    required this.partsUsed,
    required this.photos,
    required this.officeNotesController,
    required this.signatureController,
    required this.customerPresent,
    required this.declReg,
    required this.declBs7671,
    required this.declPartP,
    required this.onSection1OutcomeChanged,
    required this.onSectionOutcomeChanged,
    required this.onPartsUsedChanged,
    required this.onPhotoChanged,
    required this.onCustomerPresentChanged,
    required this.onDeclRegChanged,
    required this.onDeclBs7671Changed,
    required this.onDeclPartPChanged,
    required this.onAddManualObservation,
    required this.onAddPhotoSlot,
  });

  final DashboardTheme theme;
  final List<String> section1Items;
  final List<String> otherInspectionSections;
  final Map<String, String?> section1Outcomes;
  final Map<String, String?> sectionOutcomes;
  final bool partsUsed;
  final Map<String, String> photos;
  final TextEditingController officeNotesController;
  final TextEditingController signatureController;
  final String? customerPresent;
  final bool declReg;
  final bool declBs7671;
  final bool declPartP;

  final void Function(String item, String? value) onSection1OutcomeChanged;
  final void Function(String section, String? value) onSectionOutcomeChanged;
  final ValueChanged<bool> onPartsUsedChanged;
  final void Function(String title, String? path) onPhotoChanged;
  final ValueChanged<String?> onCustomerPresentChanged;
  final ValueChanged<bool?> onDeclRegChanged;
  final ValueChanged<bool?> onDeclBs7671Changed;
  final ValueChanged<bool?> onDeclPartPChanged;
  final VoidCallback onAddManualObservation;
  final VoidCallback onAddPhotoSlot;

  static const inspectionCodes = [
    '✓',
    'C1',
    'C2',
    'C3',
    'FI',
    'LIM',
    'N/A',
    'N/V',
  ];

  static const yesNo = ['Yes', 'No'];
  static const customerPresentOptions = [
    'Yes - customer on site',
    'No - customer not present',
  ];

  static const photoTemplates = [
    (
      'Distribution board - overall',
      'Full DB with cover removed, all ways visible',
    ),
    (
      'Distribution board - labelling',
      'Close-up of circuit chart & engineer label',
    ),
    ('Origin of supply', 'Cut-out, meter, and tails visible'),
    (
      'Defect(s) logged as observations',
      'Per observation row - use 1 photo per C1/C2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(theme, 'Schedule of Inspections (Appendix 6)'),
        Text(
          'Walk every item and assign an outcome. Anything not ✓ or N/A creates an observation.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        Text(
          '1. Intake Equipment (visual inspection only)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: theme.text,
          ),
        ),
        SizedBox(height: 8.h),
        for (final item in section1Items) ...[
          EicrFormHelpers.field(
            theme,
            item,
            EicrFormHelpers.dropdown(
              theme,
              section1Outcomes[item],
              inspectionCodes,
              (v) => onSection1OutcomeChanged(item, v),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        for (final section in otherInspectionSections) ...[
          EicrFormHelpers.field(
            theme,
            section,
            EicrFormHelpers.dropdown(
              theme,
              sectionOutcomes[section],
              inspectionCodes,
              (v) => onSectionOutcomeChanged(section, v),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 8.h),
        EicrFormHelpers.title(theme, 'Findings & observations'),
        OutlinedButton.icon(
          onPressed: onAddManualObservation,
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add manual observation (not auto-flagged)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: EicrFormHelpers.accent,
            side: BorderSide(
              color: EicrFormHelpers.accent.withValues(alpha: 0.5),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Parts used'),
        EicrFormHelpers.field(
          theme,
          'Have any parts been used during your visit?',
          EicrFormHelpers.dropdown(
            theme,
            partsUsed ? 'Yes' : 'No',
            yesNo,
            (v) => onPartsUsedChanged(v == 'Yes'),
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Photographic evidence'),
        for (final p in photoTemplates) ...[
          JobPhotoSlot(
            label: '${p.$1} · ${p.$2}',
            filePath: photos[p.$1],
            onChanged: (path) => onPhotoChanged(p.$1, path),
          ),
          SizedBox(height: 8.h),
        ],
        TextButton.icon(
          onPressed: onAddPhotoSlot,
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add another photo'),
          style: TextButton.styleFrom(foregroundColor: EicrFormHelpers.accent),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Office notes'),
        EicrFormHelpers.field(
          theme,
          'Office notes (optional)',
          EicrFormHelpers.textField(
            theme,
            officeNotesController,
            'For the office only…',
            maxLines: 3,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Signatures & sign-off'),
        EicrFormHelpers.field(
          theme,
          'Engineer signature *',
          EicrFormHelpers.textField(
            theme,
            signatureController,
            'Sign here (type full name)',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Is the customer present at the end of the visit?',
          EicrFormHelpers.dropdown(
            theme,
            customerPresent,
            customerPresentOptions,
            onCustomerPresentChanged,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Engineer competency declaration'),
        EicrFormHelpers.checkbox(
          theme,
          declReg,
          onDeclRegChanged,
          'I confirm my Competent Person Scheme registration (number recorded above) is valid and current, and that it covers the installation type I tested or inspected today. *',
        ),
        EicrFormHelpers.checkbox(
          theme,
          declBs7671,
          onDeclBs7671Changed,
          'I confirm the electrical work performed today was tested and verified in accordance with BS 7671:2018+A4:2026 (or the latest applicable amendment) and IET Guidance Note 3. *',
        ),
        EicrFormHelpers.checkbox(
          theme,
          declPartP,
          onDeclPartPChanged,
          'Where notifiable under Building Regulations Part P (dwellings), I confirm the work will be notified via my CPS scheme within the statutory window. *',
        ),
      ],
    );
  }
}
