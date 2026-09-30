import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryCtaButton extends StatelessWidget {
  const PrimaryCtaButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.height,
    this.borderRadius,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 12.r;

    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: height ?? 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: ElevatedSurface.softShadows(elevation: 0.85),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: 0.15,
                      color: AppColors.highlightYellow,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: 8.w),
                Icon(icon, size: 20.sp, color: AppColors.highlightYellow),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
