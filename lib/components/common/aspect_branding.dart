import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AspectBranding extends StatelessWidget {
  const AspectBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/aspectLogo.png', height: 36.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Powered by',
                style: TextStyle(
                  color: theme.dashSubtitle,
                  fontSize: 9.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/nav_logo.png',
                  height: 12.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
