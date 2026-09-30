import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdSignOffStep extends StatelessWidget {
  const LdSignOffStep({
    super.key,
    required this.stepTitles,
    required this.onGoToStep,
    required this.confirmDeclaration,
    required this.onConfirmDeclarationChanged,
    required this.engineerNameController,
    required this.signOffDateController,
  });

  final List<String> stepTitles;
  final ValueChanged<int> onGoToStep;
  final bool confirmDeclaration;
  final ValueChanged<bool> onConfirmDeclarationChanged;
  final TextEditingController engineerNameController;
  final TextEditingController signOffDateController;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          title: 'Review your report',
          subtitle: '10 of 10 complete',
          children: [
            for (var i = 0; i < 10; i++) ...[
              if (i > 0) Divider(height: 1, color: theme.border),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  '${i + 1} — ${stepTitles[i]}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 16.sp,
                  color: theme.textMuted,
                ),
                onTap: () => onGoToStep(i),
              ),
            ],
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          title: 'Declaration',
          children: [
            Text(
              'I, having exercised reasonable skill and care during this leak investigation, declare that the findings within this report reflect the source and character of the leak as established by the detection methods deployed on the date of investigation. Concealed services or leaks arising after this investigation are outside the scope of this report.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 19 / 13,
                color: theme.textMuted,
              ),
            ),
            SizedBox(height: 14.h),
            Material(
              color: confirmDeclaration ? AppColors.primaryBlue : theme.surfaceDeep,
              borderRadius: BorderRadius.circular(500.r),
              child: InkWell(
                onTap: () => onConfirmDeclarationChanged(!confirmDeclaration),
                borderRadius: BorderRadius.circular(500.r),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 40.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500.r),
                    border: confirmDeclaration
                        ? null
                        : Border.all(color: theme.border, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (confirmDeclaration) ...[
                        Icon(
                          LucideIcons.check,
                          size: 15.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        'I confirm this declaration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: confirmDeclaration
                              ? FontWeight.w500
                              : FontWeight.w400,
                          height: 19 / 13,
                          color: confirmDeclaration
                              ? Colors.white
                              : theme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        LdSectionCard(
          icon: LucideIcons.penLine,
          title: 'Sign off',
          children: [
            LdLabeled(
              'Engineer name',
              LdTextField(controller: engineerNameController, hint: 'Name'),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Date and time',
              LdTextField(
                controller: signOffDateController,
                hint: 'Date and time',
              ),
            ),
            SizedBox(height: 12.h),
            LdLabeled(
              'Engineer signature',
              Container(
                width: double.infinity,
                height: 100.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: theme.border, width: 1),
                ),
                child: Text(
                  'Sign here',
                  style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
