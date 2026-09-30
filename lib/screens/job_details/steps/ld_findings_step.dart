import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdFindingsStep extends StatelessWidget {
  const LdFindingsStep({
    super.key,
    required this.findingsSummaryController,
    required this.findingSeverity,
    required this.onFindingSeverityChanged,
    required this.leakClassification,
    required this.onLeakClassificationChanged,
    required this.suspectedSource,
    required this.onSuspectedSourceChanged,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final TextEditingController findingsSummaryController;
  final String? findingSeverity;
  final ValueChanged<String?> onFindingSeverityChanged;
  final String? leakClassification;
  final ValueChanged<String?> onLeakClassificationChanged;
  final String? suspectedSource;
  final ValueChanged<String?> onSuspectedSourceChanged;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.searchCheck,
          title: 'Findings',
          subtitle: 'Seeded from tests and visit conclusion. Edit if needed.',
          children: [
            LdLabeled(
              'Finding summary',
              LdTextField(
                controller: findingsSummaryController,
                hint: 'Finding summary…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(findingsSummaryController)
                    : null,
                isListening:
                    isListeningFor?.call(findingsSummaryController) ?? false,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Severity',
              LdDropdown(
                value: findingSeverity,
                items: const ['Low', 'Medium', 'High', 'Critical'],
                onChanged: onFindingSeverityChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Classification',
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
            SizedBox(height: 12.h),
            LdLabeled(
              'Suspected source',
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
          ],
        ),
      ],
    );
  }
}
