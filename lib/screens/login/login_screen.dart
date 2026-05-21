import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FadeSlideIn(
            offsetY: 18,
            child: ElevatedSurface(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
              borderRadius: 28.r,
              showBorder: false,
              child: SizedBox(
                width: 300.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/aspectLogoIcon.png',
                      height: 56.h,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chumley Navigator for Office',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: -0.35,
                        color: AppColors.textLoginTitle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to access the dashboard',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: AppColors.textLoginSubtitle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    _MicrosoftSignInButton(
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call_outlined,
                          size: 16.sp,
                          color: AppColors.textLoginSubtitle,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'Call Us — +441908024199',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLoginSubtitle,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MicrosoftSignInButton extends StatelessWidget {
  const _MicrosoftSignInButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: ElevatedSurface.softShadows(elevation: 0.85),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/microsoft-logo.png',
              height: 22.h,
            ),
            SizedBox(width: 8.w),
            Text(
              'Sign in with Microsoft',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                letterSpacing: 0.15,
                color: AppColors.highlightYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
