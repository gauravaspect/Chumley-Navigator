import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdRiskAssessmentStep extends StatelessWidget {
  const LdRiskAssessmentStep({
    super.key,
    required this.equipmentController,
    required this.siteEntryController,
    required this.riskAssessment,
    required this.onRiskAssessmentChanged,
    required this.competencyDeclaration,
    required this.onCompetencyDeclarationChanged,
    required this.leakContained,
    required this.onLeakContainedChanged,
    required this.ventilation,
    required this.onVentilationChanged,
    required this.customerDescRecorded,
    required this.onCustomerDescRecordedChanged,
    required this.systemIsolated,
    required this.onSystemIsolatedChanged,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final TextEditingController equipmentController;
  final TextEditingController siteEntryController;
  final String? riskAssessment;
  final ValueChanged<String?> onRiskAssessmentChanged;
  final bool competencyDeclaration;
  final ValueChanged<bool?> onCompetencyDeclarationChanged;
  final String? leakContained;
  final ValueChanged<String> onLeakContainedChanged;
  final String? ventilation;
  final ValueChanged<String> onVentilationChanged;
  final bool customerDescRecorded;
  final ValueChanged<bool?> onCustomerDescRecordedChanged;
  final bool systemIsolated;
  final ValueChanged<bool?> onSystemIsolatedChanged;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  static const riskAssessmentOptions = [
    'Yes - risk assessment completed, standard controls in place',
    'Yes - risk assessment completed, additional controls in place (note below)',
    'Yes - risk assessment identifies low-medium risk, work proceeds with controls',
    'STOP - risk cannot be safely controlled today, work not commenced',
  ];

  static const leakContainedOptions = [
    'Contained',
    'Active flow - isolate first',
    'STOP - electrics compromised, isolate circuit',
  ];

  static const ventilationOptions = [
    'Adequate',
    'Restricted - use acoustic or thermal instead',
    'N/A - not using tracer gas',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.key500,
          title: 'Access',
          subtitle: 'Confirm the access equipment and how you got on site.',
          children: [
            LdLabeled(
              'Equipment *',
              LdTextField(
                controller: equipmentController,
                hint: 'Equipment notes…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(equipmentController)
                    : null,
                isListening: isListeningFor?.call(equipmentController) ?? false,
              ),
              icon: LucideIcons.toolbox500,
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Site entry *',
              LdTextField(
                controller: siteEntryController,
                hint: 'Site entry notes…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(siteEntryController)
                    : null,
                isListening: isListeningFor?.call(siteEntryController) ?? false,
              ),
              icon: LucideIcons.key500,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          icon: LucideIcons.shieldCheck,
          title: 'On-site risk assessment',
          subtitle:
              'Confirm the on-site risk assessment is complete before you start work',
          children: [
            LdLabeled(
              'Has an on-site risk assessment been completed?',
              LdDropdown(
                value: riskAssessment,
                items: riskAssessmentOptions,
                onChanged: onRiskAssessmentChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdDeclarationTile(
              checked: competencyDeclaration,
              onChanged: onCompetencyDeclarationChanged,
              text:
                  'I confirm I am a competent person for this trade, I hold current public liability insurance, and I have completed the on-site risk assessment above. This declaration is recorded against my engineer ID and forms part of the contract evidence for this visit.',
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          icon: LucideIcons.triangleAlert,
          title: 'HSE gatekeeper checks',
          subtitle: 'Trade-specific stop/go checks for this work type',
          children: [
            LdChipGroup(
              label: 'Leak contained - no electrical risk from water ingress',
              hint: 'High risk',
              options: leakContainedOptions,
              value: leakContained,
              onChanged: onLeakContainedChanged,
            ),
            SizedBox(height: 14.h),
            LdChipGroup(
              label: 'Ventilation adequate for tracer gas use',
              hint: 'Medium risk',
              options: ventilationOptions,
              value: ventilation,
              onChanged: onVentilationChanged,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          title: 'Before you start',
          children: [
            LdDeclarationTile(
              checked: customerDescRecorded,
              onChanged: onCustomerDescRecordedChanged,
              text:
                  'Customer description of leak recorded, affected area photographed as first reported',
            ),
            SizedBox(height: 8.h),
            LdDeclarationTile(
              checked: systemIsolated,
              onChanged: onSystemIsolatedChanged,
              text:
                  'System isolated or pressure-tested to confirm the leak is active',
            ),
          ],
        ),
      ],
    );
  }
}
