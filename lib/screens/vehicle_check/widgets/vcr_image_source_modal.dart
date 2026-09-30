import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modal bottom sheet to select image source (Camera vs Gallery).
class VcrImageSourceModal {
  const VcrImageSourceModal._();

  static Future<ImageSource?> show(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.dashCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select image source',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashHeading,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              _ImageSourceButton(
                theme: theme,
                icon: LucideIcons.camera,
                label: 'Take photo',
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              SizedBox(height: 10.h),
              _ImageSourceButton(
                theme: theme,
                icon: LucideIcons.image,
                label: 'Choose from gallery',
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.dashMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  const _ImageSourceButton({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final DashboardTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.isDark ? theme.dashSurfaceTint : const Color(0xFFE9EDF5),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: theme.dashPrimary),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.dashHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
