import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size,
    this.iconSize,
    this.alignment = Alignment.center,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final double? iconSize;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 36.r;

    return Align(
      alignment: alignment,
      child: PressableScale(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ElevatedSurface.tintedFill,
            border: Border.all(
              color: AppColors.borderLightBlue.withValues(alpha: 0.45),
              width: 0.75,
            ),
            boxShadow: ElevatedSurface.softShadows(elevation: 0.6),
          ),
          child: Icon(
            icon,
            size: iconSize ?? 18.sp,
            color: AppColors.textDarkBlue,
          ),
        ),
      ),
    );
  }
}
