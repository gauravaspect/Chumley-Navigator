import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrExamplePhotoCard extends StatelessWidget {
  const VcrExamplePhotoCard({
    super.key,
    required this.imageUrl,
    required this.label,
    this.onTap,
  });

  final String imageUrl;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return PressableScale(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        width: 116.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9.r),
              child: Image.network(
                imageUrl,
                width: 100.w,
                height: 98.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100.w,
                  height: 98.h,
                  color: theme.surfaceDeep,
                  child: Icon(
                    Icons.image_outlined,
                    color: theme.textMuted,
                    size: 28.sp,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 100.w,
                    height: 98.h,
                    color: theme.surfaceDeep,
                    child: Center(
                      child: SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: theme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
