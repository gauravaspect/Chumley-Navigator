import 'package:chumley_navigator/utils/colors.dart';
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
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderLightBlue.withValues(alpha: 0.46),
          width: 0.46,
        ),
      ),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.borderLightBlue,
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
  const _StepDot({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.accentLime : AppColors.white,
        border: Border.all(
          color: isActive ? AppColors.starIconBorder : AppColors.borderLightBlue,
          width: isActive ? 0.15 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.textDarkBlue : AppColors.textSecondary,
        ),
      ),
    );
  }
}
