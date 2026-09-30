import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdWorkAtHeightStep extends StatelessWidget {
  const LdWorkAtHeightStep({
    super.key,
    required this.workAtHeight,
    required this.onWorkAtHeightChanged,
    required this.accessMethod,
    required this.onAccessMethodChanged,
    required this.equipmentInspection,
    required this.onEquipmentInspectionChanged,
    required this.exclusionZone,
    required this.onExclusionZoneChanged,
    required this.weatherWindow,
    required this.onWeatherWindowChanged,
    required this.loneWorking,
    required this.onLoneWorkingChanged,
    required this.engineerTraining,
    required this.onEngineerTrainingChanged,
    required this.wahrDeclaration,
    required this.onWahrDeclarationChanged,
  });

  final String? workAtHeight;
  final ValueChanged<String?> onWorkAtHeightChanged;
  final String? accessMethod;
  final ValueChanged<String?> onAccessMethodChanged;
  final String? equipmentInspection;
  final ValueChanged<String?> onEquipmentInspectionChanged;
  final String? exclusionZone;
  final ValueChanged<String?> onExclusionZoneChanged;
  final String? weatherWindow;
  final ValueChanged<String?> onWeatherWindowChanged;
  final String? loneWorking;
  final ValueChanged<String?> onLoneWorkingChanged;
  final String? engineerTraining;
  final ValueChanged<String?> onEngineerTrainingChanged;
  final bool wahrDeclaration;
  final ValueChanged<bool?> onWahrDeclarationChanged;

  static const workAtHeightOptions = [
    'Yes - work at height in scope today',
    'No - task is ground-level only',
  ];

  static const accessMethodOptions = [
    'Avoid - drone / pole camera (no person at height)',
    'Prevent - MEWP / scaffold with edge protection',
    'Minimise - ladder with three points of contact',
  ];

  static const equipmentInspectionOptions = [
    'Within 6 months - certificate on person or vehicle',
    'Overdue - STOP until inspected',
    'N/A - no height access equipment in use',
  ];

  static const exclusionZoneOptions = [
    'Established - pedestrian barrier and signage',
    'Not required - no public exposure',
    'Unable to establish - STOP',
  ];

  static const weatherWindowOptions = [
    'Dry, calm - within tolerance',
    'Marginal - proceed with caution',
    'Unsafe - postpone',
  ];

  static const loneWorkingOptions = [
    'Alone - lone-worker check-in protocol active',
    'Paired / supervised',
    'STOP - lone working not permitted for this task',
  ];

  static const engineerTrainingOptions = [
    'Current - IPAF (MEWP)',
    'Current - PASMA',
    'Current - harness / rescue',
    'Expired - STOP',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LdInfoBanner(
          'WAHR 2005 reminder. "Work at height" means any place where, if measures were not taken, a person could fall a distance liable to cause personal injury. The 2-metre threshold was repealed in 2005 - height alone is not the test.',
          Color(0xFFFEF6E7),
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          icon: LucideIcons.shieldCheck,
          title: 'Work at height - pre-work',
          subtitle:
              'Confirm whether this visit involves work where a fall could cause injury',
          children: [
            LdLabeled(
              'Will today’s task involve work where a fall could cause injury?',
              LdDropdown(
                value: workAtHeight,
                items: workAtHeightOptions,
                onChanged: onWorkAtHeightChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Access method (avoid, prevent, minimise)',
              LdDropdown(
                value: accessMethod,
                items: accessMethodOptions,
                onChanged: onAccessMethodChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Equipment inspection currency',
              LdDropdown(
                value: equipmentInspection,
                items: equipmentInspectionOptions,
                onChanged: onEquipmentInspectionChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Falling-objects exclusion zone (WAHR s.9)',
              LdDropdown(
                value: exclusionZone,
                items: exclusionZoneOptions,
                onChanged: onExclusionZoneChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Weather and working window',
              LdDropdown(
                value: weatherWindow,
                items: weatherWindowOptions,
                onChanged: onWeatherWindowChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Lone working',
              LdDropdown(
                value: loneWorking,
                items: loneWorkingOptions,
                onChanged: onLoneWorkingChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Engineer training currency (IPAF / PASMA / harness)',
              LdDropdown(
                value: engineerTraining,
                items: engineerTrainingOptions,
                onChanged: onEngineerTrainingChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdDeclarationTile(
              checked: wahrDeclaration,
              onChanged: onWahrDeclarationChanged,
              text:
                  'I confirm I am trained and competent for the access method recorded above, my equipment is in inspection date, the rescue and exclusion arrangements are in place, and the work-at-height controls are appropriate to today\'s task. This declaration is recorded against my engineer ID under WAHR 2005.',
            ),
          ],
        ),
      ],
    );
  }
}
