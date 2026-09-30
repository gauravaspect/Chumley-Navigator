import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlinedCtaButton extends StatelessWidget {
  const OutlinedCtaButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.borderColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.streakOrange;
    final fg = foregroundColor ?? AppColors.streakOrange;

    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: ElevatedSurface.tintedFill,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: border.withValues(alpha: 0.65), width: 1),
          boxShadow: ElevatedSurface.softShadows(elevation: 0.45),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: fg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
