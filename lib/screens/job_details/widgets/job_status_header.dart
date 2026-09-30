import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobStatusHeader extends StatelessWidget {
  final DashboardTheme theme;
  final String status;
  final Color statusColor;
  final String jobNo;
  final String jobType;
  final int progressIndex;

  const JobStatusHeader({
    super.key,
    required this.theme,
    required this.status,
    required this.statusColor,
    required this.jobNo,
    required this.jobType,
    required this.progressIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.08),
                  blurRadius: 20.r,
                  spreadRadius: 0,
                  offset: Offset(0, 4.h),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Colour-coded status pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Job number top-right
              Text(
                jobNo,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Large status text
          Text(
            status,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: theme.text,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E9F2),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  jobType,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A6B85),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E9F2),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  "Bathroom/Kitchen & Interfloor",
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A6B85),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Progress track (step dots)
          _buildStatusProgressTrack(theme, statusColor),
        ],
      ),
    );
  }

  Widget _buildStatusProgressTrack(DashboardTheme theme, Color statusColor) {
    const shortLabels = [
      'Dispatched',
      'Received',
      'In Transit',
      'On site',
      'Job Closure',
      'Visit Complete',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dotSize = 8.w;
        final activeDotSize = 12.w;
        final colWidth = totalWidth / shortLabels.length;

        final lineStart = colWidth / 2;
        final lineEnd = totalWidth - colWidth / 2;
        final lineLength = lineEnd - lineStart;

        final progressIdx = progressIndex.clamp(0, shortLabels.length - 1);
        final activeFraction = progressIdx / (shortLabels.length - 1);
        final activeLength = lineLength * activeFraction;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connector bar with dots
            SizedBox(
              height: 20.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background connector line (inactive)
                  Positioned(
                    left: lineStart,
                    right: colWidth / 2,
                    top: 10.h - 1.h,
                    height: 2.h,
                    child: Container(
                      color: theme.isDark
                          ? AppColors.darkBorder
                          : AppColors.borderDefault,
                    ),
                  ),
                  // Active connector line
                  Positioned(
                    left: lineStart,
                    width: activeLength,
                    top: 10.h - 1.h,
                    height: 2.h,
                    child: Container(color: statusColor),
                  ),
                  // Row of dots — completed steps show a check icon
                  Row(
                    children: List.generate(shortLabels.length, (i) {
                      final isActive = i <= progressIdx;
                      final isCurrent = i == progressIdx;
                      final isCompleted = i < progressIdx;
                      final size = isCompleted
                          ? 16.w
                          : isCurrent
                          ? activeDotSize
                          : dotSize;

                      return Expanded(
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: size,
                            height: size,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? statusColor
                                  : theme.isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderDefault,
                              shape: BoxShape.circle,
                              boxShadow: isCurrent && !isCompleted
                                  ? [
                                      BoxShadow(
                                        color: statusColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 6.r,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isCompleted
                                ? Icon(
                                    LucideIcons.check,
                                    size: 10.sp,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: List.generate(shortLabels.length, (i) {
                final isActive = i <= progressIdx;
                final isCurrent = i == progressIdx;

                return Expanded(
                  child: Text(
                    shortLabels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isCurrent
                          ? statusColor
                          : isActive
                          ? statusColor.withValues(alpha: 0.8)
                          : theme.textMuted,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
