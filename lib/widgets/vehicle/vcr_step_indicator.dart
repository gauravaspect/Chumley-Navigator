import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VcrStepIndicator extends StatelessWidget {
  const VcrStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.onStepTap,
  });

  final int totalSteps;
  final int currentStep;
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final navy = theme.dashPrimary;
    final tint =
        theme.isDark ? theme.dashSurfaceTint : const Color(0xFFD8E6FC);

    return Row(
      children: List.generate(totalSteps, (stepIndex) {
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final leftDone = stepIndex > 0 && stepIndex <= currentStep;
        final rightDone = stepIndex < currentStep;

        return Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 22.h,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: stepIndex == 0
                            ? Colors.transparent
                            : (leftDone ? navy : tint),
                      ),
                    ),
                    PressableScale(
                      onTap: onStepTap != null
                          ? () => onStepTap!(stepIndex)
                          : null,
                      scale: 0.92,
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent ? navy : tint,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? Icon(
                                LucideIcons.check,
                                size: 12.sp,
                                color: Colors.white,
                              )
                            : Text(
                                '${stepIndex + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? Colors.white
                                      : theme.dashMuted,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: stepIndex == totalSteps - 1
                            ? Colors.transparent
                            : (rightDone ? navy : tint),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
