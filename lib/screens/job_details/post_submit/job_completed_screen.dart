import 'package:chumley_navigator/screens/job_details/post_submit/status_progress_timeline.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobCompletedScreen extends StatelessWidget {
  const JobCompletedScreen({
    super.key,
    required this.jobNumber,
    required this.jobType,
    required this.workTypeLabel,
    required this.customerName,
    required this.description,
    required this.onCloseJob,
  });

  final String jobNumber;
  final String jobType;
  final String workTypeLabel;
  final String customerName;
  final String description;
  final VoidCallback onCloseJob;

  static const _textPrimary = Color(0xFF0B1F3A);
  static const _textSecondary = Color(0xFF5A6B85);
  static const _badgeFill = Color(0xFFD8E6FC);
  static const _successGreen = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.isDark
                          ? const Color(0xFF1B3A2A)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: theme.isDark
                                ? AppColors.trendUpDark
                                : _successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Job Closure',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: theme.isDark
                                ? AppColors.trendUpDark
                                : _successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    jobNumber,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.dashMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Job Completed',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: theme.dashHeading,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _neutralChip(theme, jobType),
                  _neutralChip(theme, workTypeLabel),
                ],
              ),
              SizedBox(height: 18.h),
              const StatusProgressTimeline(completed: true),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: theme.isDark
                      ? Border.all(color: theme.border, width: 0.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? AppColors.trendUpDark.withValues(alpha: 0.2)
                            : _successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 18.sp,
                        color: theme.isDark
                            ? AppColors.trendUpDark
                            : Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job completed',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.dashTitle,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'All forms submitted. This job is now closed.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: theme.dashMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Job details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: theme.dashHeading,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: theme.isDark
                      ? Border.all(color: theme.border, width: 0.5)
                      : null,
                ),
                child: Column(
                  children: [
                    _detailRow(theme, 'Appointment ID', jobNumber),
                    Divider(
                      height: 20,
                      color: theme.border,
                    ),
                    _detailRow(theme, 'Type', jobType),
                    Divider(
                      height: 20,
                      color: theme.border,
                    ),
                    _detailRow(theme, 'Customer', customerName),
                    Divider(
                      height: 20,
                      color: theme.border,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.textMuted,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.dashTitle,
                            height: 1.4,
                          ),
                        ),
                      ],
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
          child: CallStyleActionSlider(
            text: 'Slide to close job',
            backgroundColor: AppColors.primaryBlue,
            icon: LucideIcons.chevronRight,
            isEnabled: true,
            onConfirm: onCloseJob,
          ),
        ),
      ],
    );
  }

  Widget _neutralChip(DashboardTheme theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.dashSurfaceTint : _badgeFill,
        borderRadius: BorderRadius.circular(500.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: theme.dashTitle,
        ),
      ),
    );
  }

  Widget _detailRow(DashboardTheme theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: theme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
        ),
      ],
    );
  }
}

