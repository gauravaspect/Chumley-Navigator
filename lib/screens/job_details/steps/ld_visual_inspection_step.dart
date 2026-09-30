import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdVisualInspectionStep extends StatelessWidget {
  const LdVisualInspectionStep({
    super.key,
    required this.visibleSigns,
    required this.onVisibleSignsChanged,
    required this.affectedExtent,
    required this.onAffectedExtentChanged,
    required this.leakActive,
    required this.onLeakActiveChanged,
    required this.reportedPattern,
    required this.onReportedPatternChanged,
    required this.firstImpressionController,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final String? visibleSigns;
  final ValueChanged<String?> onVisibleSignsChanged;
  final String? affectedExtent;
  final ValueChanged<String?> onAffectedExtentChanged;
  final String? leakActive;
  final ValueChanged<String?> onLeakActiveChanged;
  final String? reportedPattern;
  final ValueChanged<String?> onReportedPatternChanged;
  final TextEditingController firstImpressionController;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.eye,
          title: 'Visual inspection (baseline)',
          isRequired: true,
          children: [
            LdLabeled(
              'Visible signs of leak *',
              LdDropdown(
                value: visibleSigns,
                items: const [
                  'Wet patch / surface dampness (no active drip)',
                  'Active drip / running water',
                  'Staining only (dry)',
                  'No visible signs',
                ],
                onChanged: onVisibleSignsChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Affected area extent *',
              LdDropdown(
                value: affectedExtent,
                items: const [
                  'Localised (<0.5 m2)',
                  'Moderate (0.5-2 m2)',
                  'Extensive (>2 m2)',
                  'Multiple rooms',
                ],
                onChanged: onAffectedExtentChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Is the leak active during the visit? *',
              LdDropdown(
                value: leakActive,
                items: const [
                  'Yes - active wetness, no visible drip',
                  'Yes - visible active flow',
                  'No - dry at time of visit',
                  'Intermittent',
                ],
                onChanged: onLeakActiveChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Customer’s reported leak pattern *',
              LdDropdown(
                value: reportedPattern,
                items: const [
                  'Continuous - present at all times',
                  'Only when fixtures used',
                  'Weather / rain related',
                  'Unknown',
                ],
                onChanged: onReportedPatternChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Engineer’s first impression (voice-to-text)',
              LdTextField(
                controller: firstImpressionController,
                hint: 'What you noted on arrival…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(firstImpressionController)
                    : null,
                isListening:
                    isListeningFor?.call(firstImpressionController) ?? false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
