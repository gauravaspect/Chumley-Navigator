import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/colors.dart';

class AspectBranding extends StatelessWidget {
  const AspectBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset('assets/images/aspectLogo.png', height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Powered by",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset(
                "assets/images/ChumleyLogo.png",
                height: 16.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
