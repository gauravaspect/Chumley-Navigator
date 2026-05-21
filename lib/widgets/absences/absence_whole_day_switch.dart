import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AbsenceWholeDaySwitch extends StatelessWidget {
  const AbsenceWholeDaySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Whole Day',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkBlue,
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 48.w,
            height: 28.h,
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryBlue
                  : AppColors.buttonDisabledBackground,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: value
                    ? AppColors.primaryBlue
                    : AppColors.textPlaceholder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textShadow.withValues(alpha: 0.12),
                      blurRadius: 4.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
