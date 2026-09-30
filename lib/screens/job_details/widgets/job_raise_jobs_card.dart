import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobRaiseJobsCard extends StatelessWidget {
  final DashboardTheme theme;
  final bool isOnSite;
  final VoidCallback onRaiseFixedPrice;
  final VoidCallback onRaiseReactive;
  final VoidCallback onRaiseMultipleFixedPrice;
  final VoidCallback onDisabledTap;

  const JobRaiseJobsCard({
    super.key,
    required this.theme,
    required this.isOnSite,
    required this.onRaiseFixedPrice,
    required this.onRaiseReactive,
    required this.onRaiseMultipleFixedPrice,
    required this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFF59E0B);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isOnSite ? goldColor.withValues(alpha: 0.3) : theme.border,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 16.sp,
                  color: isOnSite ? goldColor : theme.textMuted,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Raise Jobs',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isOnSite ? theme.text : theme.textMuted,
                  ),
                ),
                const Spacer(),
                if (!isOnSite)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.lock,
                        size: 12.sp,
                        color: theme.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Requires On Site',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise a Fixed Price Job',
              subtitle: 'Create a new Fixed Price work order for this site',
              icon: LucideIcons.fileText,
              enabled: isOnSite,
              onTap: onRaiseFixedPrice,
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise a reactive job',
              subtitle: 'Raise an urgent reactive task or callback',
              icon: LucideIcons.zap,
              enabled: isOnSite,
              onTap: onRaiseReactive,
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise multiple fixed price job',
              subtitle: 'Raise several Fixed Price work orders for this site',
              icon: LucideIcons.layers,
              enabled: isOnSite,
              onTap: onRaiseMultipleFixedPrice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaiseJobItem({
    required DashboardTheme theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    const goldColor = Color(0xFFF59E0B);
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!enabled) {
              onDisabledTap();
              return;
            }
            onTap();
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: enabled
                  ? goldColor.withValues(alpha: 0.05)
                  : theme.isDark
                  ? AppColors.darkSurfaceDeep
                  : AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: enabled
                    ? goldColor.withValues(alpha: 0.25)
                    : theme.border,
                width: 0.75,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: enabled
                        ? goldColor.withValues(alpha: 0.1)
                        : theme.isDark
                        ? AppColors.darkBorder
                        : AppColors.surfaceBlueTint,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: enabled ? goldColor : theme.textMuted,
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
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: enabled ? theme.text : theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14.sp,
                  color: theme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
