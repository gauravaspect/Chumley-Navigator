import 'dart:io';

import 'package:chumley_navigator/utils/colors.dart';
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
  });

  final String label;
  final File? imageFile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 114.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressableScale(
            onTap: onTap,
            scale: 0.98,
            child: VcrDashedBorder(
              color: AppColors.borderAccentBlue,
              borderRadius: 16.r,
              strokeWidth: 1.36,
              child: Container(
                width: double.infinity,
                height: 113.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightBlue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.file(
                        imageFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 24.sp,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Tap to Capture',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
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
              color: AppColors.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
