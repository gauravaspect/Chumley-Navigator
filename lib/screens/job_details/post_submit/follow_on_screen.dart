import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FollowOnScreen extends StatelessWidget {
  const FollowOnScreen({
    super.key,
    required this.jobNumber,
    required this.customerName,
    required this.workTypeLabel,
    required this.onNoEnquiry,
    this.onRaiseEstimate,
    this.onRaiseReactive,
    this.onRaiseMultipleFixedPrice,
    this.onReferAndEarn,
  });

  final String jobNumber;
  final String customerName;
  final String workTypeLabel;
  final VoidCallback onNoEnquiry;
  final VoidCallback? onRaiseEstimate;
  final VoidCallback? onRaiseReactive;
  final VoidCallback? onRaiseMultipleFixedPrice;
  final VoidCallback? onReferAndEarn;

  static const _textPrimary = Color(0xFF0B1F3A);
  static const _badgeFill = Color(0xFFD8E6FC);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Anything else for this site?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: theme.dashHeading,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Raise a follow-on enquiry while you're still on site, or confirm none is required.",
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: theme.dashMuted,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: theme.isDark ? theme.dashSurfaceTint : _badgeFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 19.sp,
                      color: theme.isDark ? AppColors.accentBlue : _textPrimary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashTitle,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$jobNumber · $workTypeLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.dashMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Raise jobs',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: theme.dashHeading,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: theme.isDark
                      ? Border.all(color: theme.border, width: 0.5)
                      : null,
                ),
                child: Column(
                  children: [
                    _raiseTile(
                      theme: theme,
                      icon: LucideIcons.fileText,
                      title: 'Raise a Fixed Price Job',
                      subtitle:
                          'Create a new Fixed Price work order for this site',
                      onTap: onRaiseEstimate,
                    ),
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: theme.border,
                    ),
                    _raiseTile(
                      theme: theme,
                      icon: LucideIcons.zap,
                      title: 'Raise a reactive job',
                      subtitle: 'Raise an urgent reactive task or callback',
                      onTap: onRaiseReactive,
                    ),
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: theme.border,
                    ),
                    _raiseTile(
                      theme: theme,
                      icon: LucideIcons.layers,
                      title: 'Raise multiple fixed price job',
                      subtitle:
                          'Raise several Fixed Price work orders for this site',
                      onTap: onRaiseMultipleFixedPrice,
                    ),
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: theme.border,
                    ),
                    _raiseTile(
                      theme: theme,
                      icon: LucideIcons.gift,
                      title: 'Refer and earn',
                      subtitle:
                          'Refer work outside your trade and earn a reward',
                      onTap: onReferAndEarn,
                    ),
                  ],
                ),
              ),
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
            color: Colors.transparent,
            child: InkWell(
              onTap: onNoEnquiry,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: theme.border, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.check,
                      size: 18.sp,
                      color: theme.isDark ? AppColors.accentBlue : _textPrimary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'No enquiry required',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.isDark
                            ? AppColors.accentBlue
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _raiseTile({
    required DashboardTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: theme.isDark ? theme.dashSurfaceTint : _badgeFill,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 19.sp,
                color: theme.isDark
                    ? AppColors.accentBlue
                    : AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.dashMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 17, color: theme.textMuted),
          ],
        ),
      ),
    );
  }
}
