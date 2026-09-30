import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VisitCompleteScreen extends StatelessWidget {
  const VisitCompleteScreen({
    super.key,
    required this.jobNumber,
    required this.onBackToHome,
  });

  final String jobNumber;
  final VoidCallback onBackToHome;

  static const _textPrimary = Color(0xFF0B1F3A);
  static const _badgeFill = Color(0xFFD8E6FC);
  static const _yellowCta = Color(0xFFFFF23D);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 22.h),
                decoration: BoxDecoration(
                  color: theme.isDark ? theme.surface : _textPrimary,
                  borderRadius: BorderRadius.circular(24.r),
                  border: theme.isDark
                      ? Border.all(color: theme.border, width: 1)
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.isDark
                            ? AppColors.accentBlue.withValues(alpha: 0.15)
                            : null,
                        border: Border.all(
                          color: theme.isDark
                              ? AppColors.accentBlue
                              : Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 36.sp,
                        color: theme.isDark ? AppColors.accentBlue : Colors.white,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Visit complete',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: theme.isDark ? theme.text : Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$jobNumber is closed. All forms are submitted and the visit is signed off.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: theme.isDark
                            ? theme.textMuted
                            : Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      height: 1,
                      color: theme.isDark
                          ? theme.border
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.isDark
                                      ? theme.textMuted
                                      : Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                jobNumber,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.isDark
                                      ? theme.text
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: jobNumber));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    theme.isDark ? theme.surface : null,
                                content: Text(
                                  'Appointment copied',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.isDark ? theme.text : null,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            LucideIcons.copy,
                            size: 18,
                            color: theme.isDark
                                ? AppColors.highlightYellow
                                : _yellowCta,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'What happens next',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashHeading,
                ),
              ),
              SizedBox(height: 14.h),
              _nextStep(theme, 1, 'Your report goes to the office for review'),
              SizedBox(height: 12.h),
              _nextStep(theme, 2, 'The customer receives their visit summary'),
              SizedBox(height: 12.h),
              _nextStep(theme, 3, 'Points for this visit land in your Points Hub'),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            border: theme.isDark
                ? Border(top: BorderSide(color: theme.border, width: 0.5))
                : null,
          ),
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: Material(
            color: _yellowCta,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: onBackToHome,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                child: Text(
                  'Back to home',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextStep(DashboardTheme theme, int n, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.isDark ? theme.dashSurfaceTint : _badgeFill,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                color: theme.dashTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
