import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AbsenceTimeField extends StatelessWidget {
  const AbsenceTimeField({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final bool enabled;

  String get _display {
    if (time == null) return 'Select time';
    final hour = time!.hourOfPeriod == 0 ? 12 : time!.hourOfPeriod;
    final minute = time!.minute.toString().padLeft(2, '0');
    final period = time!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textBodyMuted,
          ),
        ),
        SizedBox(height: 8.h),
        PressableScale(
          onTap: enabled ? onTap : null,
          enabled: enabled,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1 : 0.5,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: enabled
                      ? AppColors.textPlaceholder
                      : AppColors.borderDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _display,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: time != null
                            ? AppColors.textDarkBlue
                            : AppColors.inputPlaceholder,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: AppColors.textDarkBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
