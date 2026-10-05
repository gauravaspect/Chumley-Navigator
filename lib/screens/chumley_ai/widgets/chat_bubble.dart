import 'package:chumley_navigator/core/responsive/responsive_layout.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.theme,
    required this.text,
    required this.isUser,
  });

  final DashboardTheme theme;
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.chatBubbleMaxWidth(context),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : theme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16.r : 4.r),
            topRight: Radius.circular(isUser ? 4.r : 16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          border: isUser ? null : Border.all(color: theme.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: isUser ? Colors.white : theme.textBody,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
