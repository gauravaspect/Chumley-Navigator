import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.theme,
    required this.controller,
    required this.enabled,
    required this.placeholder,
    required this.onSend,
  });

  final DashboardTheme theme;
  final TextEditingController controller;
  final bool enabled;
  final String placeholder;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 4.h, 7.w, 4.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 14.sp),
                ),
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            Material(
              color: enabled
                  ? AppColors.primaryBlue
                  : AppColors.buttonDisabledBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: enabled ? onSend : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: const Icon(
                    LucideIcons.send,
                    color: Colors.white,
                    size: 17,
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
