import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatErrorBanner extends StatelessWidget {
  const ChatErrorBanner({
    super.key,
    required this.theme,
    required this.message,
    required this.onDismiss,
  });

  final DashboardTheme theme;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.errorBackground,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: 14.sp,
            color: AppColors.errorText,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 11.sp, color: AppColors.errorText),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 14.sp, color: AppColors.errorText),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
