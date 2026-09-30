import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdNotesStep extends StatelessWidget {
  const LdNotesStep({
    super.key,
    required this.jobNotesController,
    required this.officeNotesController,
    required this.showSuggestedTopics,
    required this.onToggleSuggestedTopics,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final TextEditingController jobNotesController;
  final TextEditingController officeNotesController;
  final bool showSuggestedTopics;
  final VoidCallback onToggleSuggestedTopics;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  static const jobNotesSuggestedTopics = [
    'Customer description of leak recorded; affected area photographed as first reported',
    'System isolated or pressure-tested to confirm the leak is active before detection',
    'Detection method(s) selected based on suspected leak type and substrate',
    'Thermal imaging scan performed with representative load applied',
    'Acoustic trace run with pipework under live pressure',
    'Tracer gas introduced at low pressure where other methods are inconclusive',
    'Moisture profile taken across affected surfaces to corroborate source',
    'Confirmed leak source photographed with detection method visible in frame',
    'Proposed access route photographed and annotated for the repair team',
    'Report issued with findings, detection method, and recommended access/repair',
  ];

  Widget _suggestedTopicRow(String topic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7.h),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: Color(0xFFC9DCF7),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            topic,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 19 / 13,
              color: ldTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.check,
          title: 'Engineer Job Notes',
          subtitle:
              'Customer-facing narrative. Anything the structured fields did not capture: unique situations, observations, customer context. Skip if it is already in the structured data.',
          children: [
            LdLabeled(
              'Describe in plain language. Chumley AI will polish this when you compile.',
              LdTextField(
                controller: jobNotesController,
                hint: 'Job notes…',
                maxLines: 6,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(jobNotesController)
                    : null,
                isListening: isListeningFor?.call(jobNotesController) ?? false,
              ),
            ),
            SizedBox(height: 6.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: jobNotesController,
              builder: (context, value, _) {
                final count = value.text.trim().length;
                final met = count >= 50;
                return Text(
                  '$count / 50 character minimum',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    height: 14 / 11,
                    letterSpacing: 0.1,
                    color: met ? const Color(0xFF15803D) : ldTextSecondary,
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: onToggleSuggestedTopics,
              child: Row(
                children: [
                  Icon(
                    showSuggestedTopics
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    showSuggestedTopics
                        ? 'Hide suggested topics (${jobNotesSuggestedTopics.length})'
                        : 'Show suggested topics (${jobNotesSuggestedTopics.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (showSuggestedTopics) ...[
              SizedBox(height: 12.h),
              for (var i = 0; i < jobNotesSuggestedTopics.length; i++) ...[
                if (i > 0) SizedBox(height: 9.h),
                _suggestedTopicRow(jobNotesSuggestedTopics[i]),
              ],
            ],
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          icon: LucideIcons.building2,
          title: 'Office notes',
          subtitle:
              'For the office only. NOT shown to the customer. Use this to flag actions, callbacks and dispatch updates.',
          children: [
            LdLabeled(
              'Office notes (optional)',
              LdTextField(
                controller: officeNotesController,
                hint: 'Internal notes…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(officeNotesController)
                    : null,
                isListening:
                    isListeningFor?.call(officeNotesController) ?? false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
