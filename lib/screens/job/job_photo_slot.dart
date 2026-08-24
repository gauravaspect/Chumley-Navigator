import 'dart:io';

import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobPhotoSlot extends StatelessWidget {
  const JobPhotoSlot({
    super.key,
    required this.label,
    required this.path,
    required this.onPicked,
  });

  final String label;
  final String? path;
  final ValueChanged<String> onPicked;

  Future<void> _capture() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final captured = path != null && path!.isNotEmpty;
    final hasFile = captured && File(path!).existsSync();

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _capture,
          borderRadius: NavigatorTokens.fieldRadius,
          child: Ink(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: captured ? NavigatorTokens.successBg : NavigatorTokens.surfaceMuted,
              borderRadius: NavigatorTokens.fieldRadius,
              border: Border.all(
                color: captured
                    ? NavigatorTokens.successFg.withValues(alpha: 0.35)
                    : NavigatorTokens.borderHairline,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: captured ? NavigatorTokens.successFg : NavigatorTokens.brandNavyTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    captured ? LucideIcons.circleCheck : LucideIcons.camera,
                    size: 20.sp,
                    color: captured ? NavigatorTokens.textInverse : NavigatorTokens.brandNavy,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: NavigatorTokens.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        captured ? 'Photo captured' : 'Tap to capture',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: captured ? NavigatorTokens.successFg : NavigatorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasFile)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(path!),
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
