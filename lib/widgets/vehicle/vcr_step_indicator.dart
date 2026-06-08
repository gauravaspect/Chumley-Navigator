import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final stepNumber = stepIndex + 1;
          final isActive = stepIndex == currentStep;

          return PressableScale(
            onTap: onStepTap != null ? () => onStepTap!(stepIndex) : null,
            scale: 0.92,
            child: _StepDot(
              label: '$stepNumber',
              isActive: isActive,
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: 28.w,
      height: 28.w,
      decoration: isActive
          ? const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            )
          : BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.border, width: 0.5),
            ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.white : theme.textMuted,
        ),
      ),
    );
  }
}
