import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tinted card surface with soft elevation — avoids flat pure-white panels.
class ElevatedSurface extends StatelessWidget {
  const ElevatedSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showBorder;

  static Color get tintedFill =>
      Color.lerp(AppColors.white, AppColors.surfaceLightBlue, 0.45)!;

  static List<BoxShadow> softShadows({double elevation = 1}) {
    final factor = elevation.clamp(0.5, 1.5);
    return [
      BoxShadow(
        color: AppColors.textDarkBlue.withValues(alpha: 0.055 * factor),
        blurRadius: (22 * factor).r,
        offset: Offset(0, (6 * factor).h),
        spreadRadius: (-6 * factor).r,
      ),
      BoxShadow(
        color: AppColors.primaryBlue.withValues(alpha: 0.035 * factor),
        blurRadius: (10 * factor).r,
        offset: Offset(0, (2 * factor).h),
      ),
    ];
  }

  static BoxDecoration decoration({
    double radius = 20,
    Color? color,
    Color? border,
    bool showBorder = true,
    double elevation = 1,
  }) {
    return BoxDecoration(
      color: color ?? tintedFill,
      borderRadius: BorderRadius.circular(radius.r),
      border: showBorder
          ? Border.all(
              color: border ?? AppColors.borderDefault.withValues(alpha: 0.55),
              width: 0.5,
            )
          : null,
      boxShadow: softShadows(elevation: elevation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20.r;
    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration(
        radius: radius / 1.r,
        color: backgroundColor,
        border: borderColor,
        showBorder: showBorder,
      ),
      child: child,
    );
  }
}
