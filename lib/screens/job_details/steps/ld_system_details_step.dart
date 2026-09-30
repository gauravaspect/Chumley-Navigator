import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdSystemDetailsStep extends StatelessWidget {
  const LdSystemDetailsStep({
    super.key,
    required this.plumbingSubSystem,
    required this.onPlumbingSubSystemChanged,
    required this.pipeMaterial,
    required this.onPipeMaterialChanged,
    required this.pipeAge,
    required this.onPipeAgeChanged,
    required this.lastMaintenance,
    required this.onLastMaintenanceChanged,
    required this.previousLeaks,
    required this.onPreviousLeaksChanged,
    required this.systemNotesController,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final String? plumbingSubSystem;
  final ValueChanged<String?> onPlumbingSubSystemChanged;
  final String? pipeMaterial;
  final ValueChanged<String?> onPipeMaterialChanged;
  final String? pipeAge;
  final ValueChanged<String?> onPipeAgeChanged;
  final String? lastMaintenance;
  final ValueChanged<String?> onLastMaintenanceChanged;
  final String? previousLeaks;
  final ValueChanged<String?> onPreviousLeaksChanged;
  final TextEditingController systemNotesController;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.wrench,
          title: 'System details (per leak type)',
          subtitle: 'Fields follow the leak type selected in Context.',
          isRequired: true,
          children: [
            LdLabeled(
              'Plumbing sub-system',
              LdDropdown(
                value: plumbingSubSystem,
                items: const [
                  'Cold mains supply (incoming and distribution)',
                  'Hot water circuit',
                  'Central heating',
                  'Waste / drainage',
                ],
                onChanged: onPlumbingSubSystemChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Supply pipework material (visible)',
              LdDropdown(
                value: pipeMaterial,
                items: const [
                  'Copper',
                  'Plastic (PEX / MDPE)',
                  'Lead',
                  'Mixed / unknown',
                ],
                onChanged: onPipeMaterialChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Pipework age band',
              LdDropdown(
                value: pipeAge,
                items: const [
                  '<10 yrs',
                  '10-20 yrs',
                  '20-40 yrs',
                  '40+ yrs',
                  'Unknown',
                ],
                onChanged: onPipeAgeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Last known maintenance / service date *',
              LdDropdown(
                value: lastMaintenance,
                items: const [
                  'Within 12 months',
                  '1-3 years',
                  'Over 3 years / unknown',
                  'No record',
                ],
                onChanged: onLastMaintenanceChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Has this property had previous leaks in this area? *',
              LdDropdown(
                value: previousLeaks,
                items: const [
                  'Yes - previous leak in same area (repeat issue)',
                  'Yes - different area',
                  'No known previous leaks',
                  'Unknown',
                ],
                onChanged: onPreviousLeaksChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'System details notes',
              LdTextField(
                controller: systemNotesController,
                hint: 'System notes…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(systemNotesController)
                    : null,
                isListening:
                    isListeningFor?.call(systemNotesController) ?? false,
              ),
            ),
            const LdHint(
              'Anything specific about the system that informs the investigation',
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const LdInfoBanner(
          'These fields follow the leak type chosen in step 3. Plumbing is selected, so the plumbing sub-system fields are shown.',
          ldFieldFill,
        ),
      ],
    );
  }
}
