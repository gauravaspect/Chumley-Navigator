import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdContextStep extends StatelessWidget {
  const LdContextStep({
    super.key,
    required this.leakType,
    required this.onLeakTypeChanged,
    required this.premisesCategory,
    required this.onPremisesCategoryChanged,
    required this.leakBehaviour,
    required this.onLeakBehaviourChanged,
    required this.waterClarity,
    required this.onWaterClarityChanged,
    required this.waterTemperature,
    required this.onWaterTemperatureChanged,
    required this.premisesSubType,
    required this.onPremisesSubTypeChanged,
    required this.propertyAge,
    required this.onPropertyAgeChanged,
    required this.occupantPresent,
    required this.onOccupantPresentChanged,
    required this.hasWaterMeter,
    required this.onHasWaterMeterChanged,
    required this.insuranceClaim,
    required this.onInsuranceClaimChanged,
    required this.claimRefController,
    required this.scopeNotesController,
    required this.scopeLimitations,
    required this.onScopeLimitationsChanged,
    required this.limitationsDescController,
    this.onToggleDictation,
    this.isListeningFor,
  });

  final String? leakType;
  final ValueChanged<String?> onLeakTypeChanged;
  final String? premisesCategory;
  final ValueChanged<String?> onPremisesCategoryChanged;
  final String? leakBehaviour;
  final ValueChanged<String?> onLeakBehaviourChanged;
  final String? waterClarity;
  final ValueChanged<String?> onWaterClarityChanged;
  final String? waterTemperature;
  final ValueChanged<String?> onWaterTemperatureChanged;
  final String? premisesSubType;
  final ValueChanged<String?> onPremisesSubTypeChanged;
  final String? propertyAge;
  final ValueChanged<String?> onPropertyAgeChanged;
  final String? occupantPresent;
  final ValueChanged<String?> onOccupantPresentChanged;
  final String? hasWaterMeter;
  final ValueChanged<String?> onHasWaterMeterChanged;
  final String? insuranceClaim;
  final ValueChanged<String?> onInsuranceClaimChanged;
  final TextEditingController claimRefController;
  final TextEditingController scopeNotesController;
  final String? scopeLimitations;
  final ValueChanged<String?> onScopeLimitationsChanged;
  final TextEditingController limitationsDescController;
  final void Function(TextEditingController)? onToggleDictation;
  final bool Function(TextEditingController)? isListeningFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.droplet,
          title: 'Context + property profile',
          isRequired: true,
          subtitle:
              'Capture the leak type, property profile and insurance-claim context before starting the investigation.',
          children: [
            LdLabeled(
              'Type of leak detection *',
              LdDropdown(
                value: leakType,
                items: const [
                  'Plumbing',
                  'Central heating',
                  'Drainage',
                  'Roof / external',
                ],
                onChanged: onLeakTypeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Premises category *',
              LdDropdown(
                value: premisesCategory,
                items: const ['Domestic', 'Commercial', 'Communal / MDU'],
                onChanged: onPremisesCategoryChanged,
              ),
            ),
            SizedBox(height: 4.h),
            const LdHint('Broad category. The next question narrows it down.'),
            SizedBox(height: 12.h),
            LdLabeled(
              'Leak behaviour (triage) *',
              LdDropdown(
                value: leakBehaviour,
                items: const [
                  'Worse when a fixture is running (tap, shower, appliance)',
                  'Continuous regardless of fixtures',
                  'Intermittent / weather-related',
                  'Unknown / not observed',
                ],
                onChanged: onLeakBehaviourChanged,
              ),
            ),
            const LdHint(
              'Options are tailored to the leak detection type chosen above.',
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Water clarity / contamination',
              LdDropdown(
                value: waterClarity,
                items: const [
                  'Clear / clean - typical of fresh supply',
                  'Discoloured / dirty',
                  'Odorous / contaminated',
                  'Not observed',
                ],
                onChanged: onWaterClarityChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Water temperature (where felt)',
              LdDropdown(
                value: waterTemperature,
                items: const [
                  'Ambient / cold - typical of cold supply or external',
                  'Warm / hot - heating or HW circuit',
                  'Not felt',
                ],
                onChanged: onWaterTemperatureChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Premises sub-type *',
              LdDropdown(
                value: premisesSubType,
                items: const [
                  'Owner-occupied (single household)',
                  'Tenanted / private rental',
                  'Social housing',
                  'Holiday let / short stay',
                ],
                onChanged: onPremisesSubTypeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Property age band *',
              LdDropdown(
                value: propertyAge,
                items: const [
                  'Pre-1919 - traditional',
                  '1919-1944',
                  '1945-1980 - modern (cavity wall era)',
                  '1981-2000',
                  'Post-2000',
                ],
                onChanged: onPropertyAgeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Occupant present during visit *',
              LdDropdown(
                value: occupantPresent,
                items: const [
                  'Yes - occupant present and briefed',
                  'No - vacant / keyholder only',
                  'Partial - arrived mid-visit',
                ],
                onChanged: onOccupantPresentChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Does the property have a water meter? *',
              LdDropdown(
                value: hasWaterMeter,
                items: const [
                  'Yes - water meter present and accessible',
                  'Yes - present but inaccessible',
                  'No meter',
                  'Unknown',
                ],
                onChanged: onHasWaterMeterChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Insurance claim related? *',
              LdDropdown(
                value: insuranceClaim,
                items: const [
                  'Yes - customer is claiming on insurance',
                  'No - not an insurance claim',
                  'Unknown / not disclosed',
                ],
                onChanged: onInsuranceClaimChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Insurance claim reference (if available)',
              LdTextField(
                controller: claimRefController,
                hint: 'Claim reference…',
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Scope notes - customer’s reported symptom + history',
              LdTextField(
                controller: scopeNotesController,
                hint: 'Scope notes…',
                maxLines: 4,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(scopeNotesController)
                    : null,
                isListening:
                    isListeningFor?.call(scopeNotesController) ?? false,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Were there any scope or access limitations on this visit? *',
              LdDropdown(
                value: scopeLimitations,
                items: const [
                  'Yes - limitations recorded below',
                  'No - full access',
                ],
                onChanged: onScopeLimitationsChanged,
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Describe the scope / access limitations',
              LdTextField(
                controller: limitationsDescController,
                hint: 'Limitations…',
                maxLines: 3,
                onToggleDictation: onToggleDictation != null
                    ? () => onToggleDictation!(limitationsDescController)
                    : null,
                isListening:
                    isListeningFor?.call(limitationsDescController) ?? false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
