import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EicrRiskStep extends StatelessWidget {
  const EicrRiskStep({
    super.key,
    required this.theme,
    required this.riskAssessment,
    required this.workAtHeight,
    required this.safeIsolation,
    required this.clientBriefed,
    required this.vulnerable,
    required this.riskNoteController,
    required this.onRiskAssessmentChanged,
    required this.onWorkAtHeightChanged,
    required this.onSafeIsolationChanged,
    required this.onClientBriefedChanged,
    required this.onVulnerableChanged,
  });

  final DashboardTheme theme;
  final String? riskAssessment;
  final String? workAtHeight;
  final String? safeIsolation;
  final String? clientBriefed;
  final String? vulnerable;
  final TextEditingController riskNoteController;

  final ValueChanged<String?> onRiskAssessmentChanged;
  final ValueChanged<String?> onWorkAtHeightChanged;
  final ValueChanged<String?> onSafeIsolationChanged;
  final ValueChanged<String?> onClientBriefedChanged;
  final ValueChanged<String?> onVulnerableChanged;

  static const riskAssessmentOptions = [
    'Yes - risk assessment completed, standard controls in place',
    'Yes - risk assessment completed, additional controls in place (note below)',
    'Yes - risk assessment identifies low-medium risk, work proceeds with controls',
    'STOP - risk cannot be safely controlled today, work not commenced',
  ];

  static const workAtHeightOptions = [
    'Yes - work at height in scope today',
    'No - task is ground-level only',
  ];

  static const safeIsolationOptions = [
    'Yes - locked off and proved dead',
    'Partial - supervised',
    'Not possible - STOP',
  ];

  static const clientBriefedOptions = [
    'Briefed and consent given',
    'Unable to contact - proceed per instruction',
    'Refused - STOP',
  ];

  static const vulnerableOptions = [
    'None present',
    'Present - arrangements made',
    'Present - STOP until arranged',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(theme, 'Property & installation details'),
        Text(
          'Property details will populate from the site record.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'On-site risk assessment'),
        EicrFormHelpers.field(
          theme,
          'Has an on-site risk assessment been completed? *',
          EicrFormHelpers.dropdown(
            theme,
            riskAssessment,
            riskAssessmentOptions,
            onRiskAssessmentChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Additional controls note',
          EicrFormHelpers.textField(
            theme,
            riskNoteController,
            'Note (if required)…',
            maxLines: 3,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Work at Height - pre-work'),
        EicrFormHelpers.field(
          theme,
          'Will today\'s task involve work where a fall could cause injury? *',
          EicrFormHelpers.dropdown(
            theme,
            workAtHeight,
            workAtHeightOptions,
            onWorkAtHeightChanged,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'HSE gatekeeper checks'),
        EicrFormHelpers.field(
          theme,
          'Safe isolation procedure followed (High risk)',
          EicrFormHelpers.dropdown(
            theme,
            safeIsolation,
            safeIsolationOptions,
            onSafeIsolationChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Client briefed on power interruption (High risk)',
          EicrFormHelpers.dropdown(
            theme,
            clientBriefed,
            clientBriefedOptions,
            onClientBriefedChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Vulnerable occupants considered (medical equipment, lifts) (High risk)',
          EicrFormHelpers.dropdown(
            theme,
            vulnerable,
            vulnerableOptions,
            onVulnerableChanged,
          ),
        ),
      ],
    );
  }
}
