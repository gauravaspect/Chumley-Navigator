import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenTitleBlock extends StatelessWidget {
  const ScreenTitleBlock({
    super.key,
    required this.title,
    this.subtitle,
    this.titleSize,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String title;
  final String? subtitle;
  final double? titleSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize ?? 22.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
            color: AppColors.primaryBlueDark,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.35,
              letterSpacing: 0.1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
