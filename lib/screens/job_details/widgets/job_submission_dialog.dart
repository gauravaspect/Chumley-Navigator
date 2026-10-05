import 'package:chumley_navigator/core/responsive/responsive_overlays.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobSubmissionDialog extends StatelessWidget {
  const JobSubmissionDialog({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.referenceId,
    required this.details,
    this.buttonLabel = 'Back to Job',
    this.onDismiss,
  });

  final DashboardTheme theme;
  final String title;
  final String subtitle;
  final String referenceId;
  final Map<String, String> details;
  final String buttonLabel;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    required DashboardTheme theme,
    required String title,
    required String subtitle,
    required String referenceId,
    required Map<String, String> details,
    String buttonLabel = 'Back to Job',
  }) {
    return showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => JobSubmissionDialog(
        theme: theme,
        title: title,
        subtitle: subtitle,
        referenceId: referenceId,
        details: details,
        buttonLabel: buttonLabel,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const successColor = Color(0xFF22C55E);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: theme.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.isDark ? 0.45 : 0.12),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon with glow
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: successColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.check,
                  color: successColor,
                  size: 28.sp,
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Title & Subtitle
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textMuted,
                height: 1.35,
              ),
            ),
            SizedBox(height: 14.h),

            // Reference badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reference: ',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textMuted,
                    ),
                  ),
                  Text(
                    referenceId,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Details list
            if (details.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.border, width: 0.5),
                ),
                child: Column(
                  children: details.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 95.w,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 20.h),

            // Action Button
            PressableScale(
              onTap: onDismiss,
              scale: 0.98,
              child: Container(
                height: 44.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentLime,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentLime.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
