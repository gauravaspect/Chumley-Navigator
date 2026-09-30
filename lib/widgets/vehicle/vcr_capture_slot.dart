import 'dart:io';

import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VcrCaptureSlot extends StatelessWidget {
  const VcrCaptureSlot({
    super.key,
    required this.label,
    this.imageFile,
    this.onTap,
    this.isCompressing = false,
  });

  final String label;
  final File? imageFile;
  final VoidCallback? onTap;
  final bool isCompressing;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return SizedBox(
      width: 114.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressableScale(
            onTap: isCompressing ? null : onTap,
            scale: 0.98,
            child: VcrDashedBorder(
              color: theme.border,
              borderRadius: 12.r,
              strokeWidth: 1.36,
              child: Container(
                width: double.infinity,
                height: 113.h,
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: isCompressing
                    ? Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                    : imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.file(
                          imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 300,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 22.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Upload',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
