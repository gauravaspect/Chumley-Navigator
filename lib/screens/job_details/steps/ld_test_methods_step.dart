import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdTestMethodsStep extends StatelessWidget {
  const LdTestMethodsStep({
    super.key,
    required this.testMethod,
    required this.onTestMethodChanged,
    required this.equipmentUsed,
    required this.onEquipmentUsedChanged,
    required this.equipmentCalibrated,
    required this.onEquipmentCalibratedChanged,
    required this.timeAllocated,
    required this.onTimeAllocatedChanged,
    required this.thermalAnomalies,
    required this.onThermalAnomaliesChanged,
    required this.anomalyTempController,
    required this.dryTempController,
    required this.anomalyPattern,
    required this.onAnomalyPatternChanged,
    required this.moistureVerified,
    required this.onMoistureVerifiedChanged,
    required this.testHelped,
    required this.onTestHelpedChanged,
    required this.leakClassification,
    required this.onLeakClassificationChanged,
    required this.suspectedSource,
    required this.onSuspectedSourceChanged,
    required this.testLocation,
    required this.onTestLocationChanged,
    required this.testDescController,
    required this.testBeforeSkipController,
    required this.testAfterSkipController,
    required this.capturedPhotos,
    required this.onPhotoChanged,
    required this.onSnippetSnack,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final String? testMethod;
  final ValueChanged<String?> onTestMethodChanged;
  final String? equipmentUsed;
  final ValueChanged<String?> onEquipmentUsedChanged;
  final String? equipmentCalibrated;
  final ValueChanged<String?> onEquipmentCalibratedChanged;
  final String? timeAllocated;
  final ValueChanged<String?> onTimeAllocatedChanged;
  final String? thermalAnomalies;
  final ValueChanged<String?> onThermalAnomaliesChanged;
  final TextEditingController anomalyTempController;
  final TextEditingController dryTempController;
  final String? anomalyPattern;
  final ValueChanged<String?> onAnomalyPatternChanged;
  final String? moistureVerified;
  final ValueChanged<String?> onMoistureVerifiedChanged;
  final String? testHelped;
  final ValueChanged<String?> onTestHelpedChanged;
  final String? leakClassification;
  final ValueChanged<String?> onLeakClassificationChanged;
  final String? suspectedSource;
  final ValueChanged<String?> onSuspectedSourceChanged;
  final String? testLocation;
  final ValueChanged<String?> onTestLocationChanged;
  final TextEditingController testDescController;
  final TextEditingController testBeforeSkipController;
  final TextEditingController testAfterSkipController;
  final Map<String, String> capturedPhotos;
  final void Function(String key, String? path) onPhotoChanged;
  final ValueChanged<String> onSnippetSnack;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  Widget _testCollapsedRow(BuildContext context, String title, String method) {
    final theme = DashboardTheme.of(context);

    return InkWell(
      onTap: () => onSnippetSnack('$title — expand coming soon'),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.surfaceDeep,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      height: 14 / 11,
                      letterSpacing: 0.1,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              size: 18.sp,
              color: theme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.thermometer,
          title: 'Test methods & measurements',
          subtitle:
              'Record each test method deployed - equipment, calibration, readings and whether it located the source.',
          isRequired: true,
          children: [
            LdLabeled(
              'Test method deployed *',
              LdDropdown(
                value: testMethod,
                items: const [
                  'Thermal imaging',
                  'Acoustic listening',
                  'Tracer gas',
                  'Moisture mapping',
                  'Visual + dye / leak-detection fluid',
                ],
                onChanged: onTestMethodChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Equipment used *',
              LdDropdown(
                value: equipmentUsed,
                items: const [
                  'FLIR C5 / C3 / E-series',
                  'Acoustic ground mic',
                  'Tracer gas kit',
                  'Protimeter / moisture meter',
                ],
                onChanged: onEquipmentUsedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Equipment calibrated and in working order? *',
              LdDropdown(
                value: equipmentCalibrated,
                items: const [
                  'Yes - calibration in date and working today',
                  'No - proceed with caveat',
                  'N/A',
                ],
                onChanged: onEquipmentCalibratedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Time allocated to this test *',
              LdDropdown(
                value: timeAllocated,
                items: const [
                  'Under 15 minutes',
                  '15-30 minutes',
                  '30-60 minutes',
                  'Over 60 minutes',
                ],
                onChanged: onTimeAllocatedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Thermal anomalies identified?',
              LdDropdown(
                value: thermalAnomalies,
                items: const [
                  'Yes - anomalies identified',
                  'No anomalies',
                  'Inconclusive',
                ],
                onChanged: onThermalAnomaliesChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Anomaly spot temperature (deg C)',
              LdTextField(controller: anomalyTempController, hint: 'e.g. 14.2'),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Dry reference spot temperature (deg C)',
              LdTextField(controller: dryTempController, hint: 'e.g. 19.8'),
            ),
            SizedBox(height: 4.h),
            const LdHint(
              'Same camera, on a DRY equivalent area. Delta-T is derived from the two.',
            ),
            SizedBox(height: 12.h),
            const LdInfoBanner(
              'Delta-T 5.6 deg C, cooler than the dry reference - consistent with a cold-water leak.',
              ldBadgeFill,
            ),
            SizedBox(height: 4.h),
            LdLabeled(
              'Anomaly direction and pattern',
              LdDropdown(
                value: anomalyPattern,
                items: const [
                  'Cooler in a linear pattern matching a pipe run',
                  'Localised cool spot',
                  'Warm anomaly',
                  'Diffuse / unclear',
                ],
                onChanged: onAnomalyPatternChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Verified the thermal anomaly with a moisture meter?',
              LdDropdown(
                value: moistureVerified,
                items: const [
                  'Yes - moisture meter confirmed the anomaly',
                  'No - not verified',
                  'N/A',
                ],
                onChanged: onMoistureVerifiedChanged,
              ),
            ),
            SizedBox(height: 4.h),
            const LdHint('Thermal indicates, moisture confirms.'),
            SizedBox(height: 12.h),
            LdLabeled(
              'Did this test help find the source of the leak? *',
              LdDropdown(
                value: testHelped,
                items: const [
                  'Yes - narrowed the search significantly',
                  'Partially helpful',
                  'No - inconclusive',
                ],
                onChanged: onTestHelpedChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Leak classification (for the seeded finding)',
              LdDropdown(
                value: leakClassification,
                items: const [
                  'Active leak - behind surface',
                  'Active leak - visible',
                  'Historic / dried',
                  'Condensation / non-leak',
                ],
                onChanged: onLeakClassificationChanged,
              ),
            ),
            SizedBox(height: 4.h),
            const LdHint(
              "Populates the finding's leak classification automatically. Pick what this test actually evidenced.",
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Suspected source (for the seeded finding)',
              LdDropdown(
                value: suspectedSource,
                items: const [
                  'Cold mains',
                  'Hot water',
                  'Central heating',
                  'Waste / drainage',
                  'Roof / external',
                ],
                onChanged: onSuspectedSourceChanged,
              ),
            ),
            SizedBox(height: 4.h),
            const LdHint(
              "Engineer's interpretation based on what this test evidenced. Mirrors into the seeded finding.",
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Location indicated by this test',
              LdDropdown(
                value: testLocation,
                items: const [
                  'Kitchen',
                  'Bathroom',
                  'Hallway',
                  'Loft',
                  'External',
                  'Other - specify',
                ],
                onChanged: onTestLocationChanged,
              ),
            ),
            SizedBox(height: 4.h),
            const LdHint(
              "Mirrors into the seeded finding's location. Use Other - specify for anywhere outside the list.",
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Brief test description (voice-to-text)',
              LdTextField(
                controller: testDescController,
                hint: 'What was tested…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(testDescController)
                    : null,
                isListening: isListeningFor?.call(testDescController) ?? false,
              ),
            ),
            const LdHint('What was tested and what was found.'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: ldFieldFill,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test evidence photos',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: ldTextPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  const LdHint(
                    "Mandatory per slot - either upload the photo or type a skip reason. The PDF collages these alongside this test's results.",
                  ),
                  SizedBox(height: 8.h),
                  JobPhotoSlot(
                    label: 'Test BEFORE - equipment + setup',
                    filePath: capturedPhotos['test_before'],
                    onChanged: (path) => onPhotoChanged('test_before', path),
                  ),
                  SizedBox(height: 8.h),
                  LdLabeled(
                    'Skip reason (optional)',
                    LdTextField(
                      controller: testBeforeSkipController,
                      hint: 'Or type a skip reason…',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  JobPhotoSlot(
                    label: 'Test AFTER - reading / result captured',
                    filePath: capturedPhotos['test_after'],
                    onChanged: (path) => onPhotoChanged('test_after', path),
                  ),
                  SizedBox(height: 8.h),
                  LdLabeled(
                    'Skip reason (optional)',
                    LdTextField(
                      controller: testAfterSkipController,
                      hint: 'Or type a skip reason…',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _testCollapsedRow(
              context,
              'Test 2',
              'Visual + dye / leak-detection fluid',
            ),
          ],
        ),
      ],
    );
  }
}
