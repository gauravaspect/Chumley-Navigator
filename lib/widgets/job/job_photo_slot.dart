import 'dart:io';

import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Captures a photo file for visit and compliance forms.
class JobPhotoSlot extends StatelessWidget {
  JobPhotoSlot({
    super.key,
    required this.label,
    String? filePath,
    String? path,
    ValueChanged<String?>? onChanged,
    ValueChanged<String>? onPicked,
  })  : filePath = filePath ?? path,
        onChanged = onChanged ??
            (onPicked != null
                ? ((val) {
                    if (val != null) onPicked(val);
                  })
                : null);

  final String label;
  final String? filePath;
  final ValueChanged<String?>? onChanged;

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return;
    onChanged?.call(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final captured = filePath != null && filePath!.isNotEmpty && File(filePath!).existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: NavigatorTokens.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
            if (captured) {
              onChanged?.call(null);
              return;
            }
            await _pick(context);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: VcrDashedBorder(
            color: const Color(0xFFC9DCF7),
            borderRadius: 12.r,
            child: Container(
              width: double.infinity,
              height: 84.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: captured
                  ? Row(
                      children: [
                        SizedBox(width: 8.w),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(filePath!),
                            width: 68.w,
                            height: 68.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Photo attached',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: NavigatorTokens.brandNavy,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.camera,
                          size: 18.sp,
                          color: NavigatorTokens.brandNavy,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Take photo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: NavigatorTokens.brandNavy,
                          ),
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
