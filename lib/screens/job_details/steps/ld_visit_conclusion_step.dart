import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdVisitConclusionStep extends StatelessWidget {
  const LdVisitConclusionStep({
    super.key,
    required this.leakIdentified,
    required this.onLeakIdentifiedChanged,
    required this.sourceDescController,
    required this.repairedToday,
    required this.onRepairedTodayChanged,
    required this.repairDescController,
    required this.repairMethod,
    required this.onRepairMethodChanged,
    required this.repairTime,
    required this.onRepairTimeChanged,
    required this.postRepairVerification,
    required this.onPostRepairVerificationChanged,
    required this.dryingDiscussed,
    required this.onDryingDiscussedChanged,
    required this.dryingRequirements,
    required this.onDryingRequirementsChanged,
    required this.reinstatementDiscussed,
    required this.onReinstatementDiscussedChanged,
    required this.reinstatementScope,
    required this.onReinstatementScopeChanged,
    required this.conclusionNotesController,
    required this.capturedPhotos,
    required this.onPhotoChanged,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final String? leakIdentified;
  final ValueChanged<String?> onLeakIdentifiedChanged;
  final TextEditingController sourceDescController;
  final String? repairedToday;
  final ValueChanged<String?> onRepairedTodayChanged;
  final TextEditingController repairDescController;
  final String? repairMethod;
  final ValueChanged<String?> onRepairMethodChanged;
  final String? repairTime;
  final ValueChanged<String?> onRepairTimeChanged;
  final String? postRepairVerification;
  final ValueChanged<String?> onPostRepairVerificationChanged;
  final String? dryingDiscussed;
  final ValueChanged<String?> onDryingDiscussedChanged;
  final String? dryingRequirements;
  final ValueChanged<String?> onDryingRequirementsChanged;
  final String? reinstatementDiscussed;
  final ValueChanged<String?> onReinstatementDiscussedChanged;
  final String? reinstatementScope;
  final ValueChanged<String?> onReinstatementScopeChanged;
  final TextEditingController conclusionNotesController;
  final Map<String, String> capturedPhotos;
  final void Function(String key, String? path) onPhotoChanged;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.search,
          title: 'Visit conclusion + customer engagement',
          subtitle:
              'What was found, what was repaired, and what the customer was told.',
          children: [
            LdLabeled(
              'Has the leak been identified during this visit? *',
              LdDropdown(
                value: leakIdentified,
                items: const [
                  'Yes - definitive source identified',
                  'Partially - narrowed area',
                  'No - further investigation required',
                ],
                onChanged: onLeakIdentifiedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Identified source description',
              LdTextField(
                controller: sourceDescController,
                hint: 'Source description…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(sourceDescController)
                    : null,
                isListening:
                    isListeningFor?.call(sourceDescController) ?? false,
              ),
            ),
            const LdHint(
              "e.g. 'Kitchen ceiling NE corner - pinhole in hot supply elbow at first-floor bathroom basin trap'",
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Has the leak been repaired today? *',
              LdDropdown(
                value: repairedToday,
                items: const [
                  'Yes - full repair completed + tested',
                  'Temporary make-safe only',
                  'No - repair deferred',
                ],
                onChanged: onRepairedTodayChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Repair description (what was done)',
              LdTextField(
                controller: repairDescController,
                hint: 'Repair summary…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(repairDescController)
                    : null,
                isListening:
                    isListeningFor?.call(repairDescController) ?? false,
              ),
            ),
            const LdHint('Customer-facing summary.'),
            SizedBox(height: 12.h),
            LdLabeled(
              'Repair method',
              LdDropdown(
                value: repairMethod,
                items: const [
                  'Joint re-make (compression / push-fit)',
                  'Pipe section replacement',
                  'Clamp / temporary',
                  'N/A - not repaired',
                ],
                onChanged: onRepairMethodChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Time allocated to the repair',
              LdDropdown(
                value: repairTime,
                items: const [
                  'Under 15 minutes',
                  '15-30 minutes',
                  '30-60 minutes',
                  'Over 60 minutes',
                ],
                onChanged: onRepairTimeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Post-repair verification',
              LdDropdown(
                value: postRepairVerification,
                items: const [
                  'Pressure test passed - no further loss',
                  'Visual check only',
                  'Not verified',
                  'N/A',
                ],
                onChanged: onPostRepairVerificationChanged,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: ldFieldFill,
                borderRadius: BorderRadius.circular(6.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repair evidence photos',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: ldTextPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  JobPhotoSlot(
                    label: 'Leak location',
                    filePath: capturedPhotos['repair_location'],
                    onChanged: (path) =>
                        onPhotoChanged('repair_location', path),
                  ),
                  SizedBox(height: 8.h),
                  JobPhotoSlot(
                    label: 'Before repair (defect close-up)',
                    filePath: capturedPhotos['repair_before'],
                    onChanged: (path) => onPhotoChanged('repair_before', path),
                  ),
                  SizedBox(height: 8.h),
                  JobPhotoSlot(
                    label: 'After repair (completed fix)',
                    filePath: capturedPhotos['repair_after'],
                    onChanged: (path) => onPhotoChanged('repair_after', path),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            LdLabeled(
              'Discussed drying requirements with customer? *',
              LdDropdown(
                value: dryingDiscussed,
                items: const [
                  'Yes - drying requirements discussed',
                  'No - customer unavailable',
                  'N/A - dry / no damage',
                ],
                onChanged: onDryingDiscussedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Drying requirements indicated *',
              LdDropdown(
                value: dryingRequirements,
                items: const [
                  'Wet substrate / saturated finishes - drying contractor recommended',
                  'Natural drying adequate',
                  'None',
                ],
                onChanged: onDryingRequirementsChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Discussed reinstatement / making-good with customer? *',
              LdDropdown(
                value: reinstatementDiscussed,
                items: const [
                  'Yes - reinstatement requirements discussed',
                  'No',
                  'N/A',
                ],
                onChanged: onReinstatementDiscussedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Reinstatement scope indicated *',
              LdDropdown(
                value: reinstatementScope,
                items: const [
                  'Finishes damaged - full make-good required',
                  'Minor making-good',
                  'None',
                ],
                onChanged: onReinstatementScopeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Conclusion notes / customer briefing summary',
              LdTextField(
                controller: conclusionNotesController,
                hint: 'Final summary…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(conclusionNotesController)
                    : null,
                isListening:
                    isListeningFor?.call(conclusionNotesController) ?? false,
              ),
            ),
            const LdHint(
              'Final summary - what the engineer told the customer plus anything for the loss adjuster or insurance file.',
            ),
          ],
        ),
      ],
    );
  }
}
