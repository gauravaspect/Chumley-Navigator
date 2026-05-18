import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.profileBorderPurple),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPurple.withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.profileGradientStart, AppColors.profileGradientEnd],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header Row ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.profileDividerPurple, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar + Greeting
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.textDarkBlue,
                          ),
                          children: const [
                            TextSpan(text: 'Hi, '),
                            TextSpan(
                              text: 'Gaurav',
                              style: TextStyle(color: AppColors.textBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bell Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.notifications);
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset("assets/images/bell.png"),
                        // Red dot
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.streakOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body Row ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mascot image
                Transform.translate(
                  offset: const Offset(0, -3.67),
                  child: Image.asset(
                    'assets/images/navigator-mascot.png',
                    height: 60.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12.w),

                // Text column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WELCOME TO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                        color: AppColors.textPurple,
                        letterSpacing: 0.22 * 10, // tracking-[0.22em]
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // "chumley" – solid purple
                        Text(
                          'chumley',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 22.sp,
                            color: AppColors.textPurple,
                            letterSpacing: -0.02 * 22,
                            height: 1,
                          ),
                        ),
                        // "navigator" – gradient text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.gradientPromoStart, AppColors.gradientPromoEnd],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'navigator',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                              color: Colors.white, // masked by ShaderMask
                              letterSpacing: -0.02 * 22,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
