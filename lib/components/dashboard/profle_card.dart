import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/skeleton_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return SkeletonShimmer(
      isLoading: isLoading,
      baseColor: theme.shimmerBase,
      highlightColor: theme.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: theme.dashCardBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: theme.dashCardBorder, width: 0.8),
          boxShadow: theme.isDark
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(16.w),
                child: SkeletonBox(
                  height: 88.h,
                  baseColor: theme.shimmerBase,
                  highlightColor: theme.shimmerHighlight,
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -3.67),
                      child: Image.asset(
                        'assets/images/navigator-mascot.png',
                        height: 60.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'WELCOME TO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            color: theme.dashWelcomeSubtext,
                            letterSpacing: 2.2,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'chumley navigator',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22.sp,
                            color: theme.dashWelcomeHeading,
                            letterSpacing: -0.44,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
