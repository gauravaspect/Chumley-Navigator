import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PodiumEntry {
  const PodiumEntry({
    required this.firstName,
    required this.lastName,
    required this.score,
    required this.position,
  });

  final String firstName;
  final String lastName;
  final String score;
  final String position;
}

class PodiumColumn extends StatelessWidget {
  const PodiumColumn({super.key, required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;
    final isFirst = entry.position == '1st';
    final cardH = isFirst ? 175.h : 145.h;
    final nameSize = isFirst ? 12.sp : 10.sp;
    final iconSize = isFirst ? 30.sp : 22.sp;
    final scoreSize = isFirst ? 18.sp : 14.sp;

    final cardBg = _cardBackground(isDark, isFirst);
    final cardBorder = _cardBorder(isDark, isFirst);
    final nameColor = _nameColor(isDark, isFirst);
    final iconColor = _iconColor(isDark, isFirst);
    final scoreColor = _scoreColor(isDark, isFirst);
    final badgeStyle = _badgeStyle(isDark, isFirst);

    return Semantics(
      label:
          '${entry.position} place, ${entry.firstName} ${entry.lastName}, score ${entry.score}',
      child: PressableScale(
        onTap: () {},
        scale: 0.98,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: cardH,
              decoration: BoxDecoration(
                color: cardBg,
                border: Border.all(color: cardBorder, width: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.firstName,
                    style: TextStyle(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w500,
                      color: nameColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    entry.lastName,
                    style: TextStyle(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w500,
                      color: nameColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Icon(
                    Icons.emoji_events_outlined,
                    size: iconSize,
                    color: iconColor,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    entry.score,
                    style: TextStyle(
                      fontSize: scoreSize,
                      fontWeight: FontWeight.w500,
                      color: scoreColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: badgeStyle.background,
                border: Border.all(color: badgeStyle.border, width: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.position,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: badgeStyle.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _cardBackground(bool isDark, bool isFirst) {
    if (isDark) {
      return isFirst ? AppColors.trendUpBgDark : AppColors.darkSurfaceDeep;
    }
    return isFirst ? AppColors.podiumFirstLightBg : AppColors.lightSurfaceDeep;
  }

  static Color _cardBorder(bool isDark, bool isFirst) {
    if (isDark) {
      return isFirst ? AppColors.podiumFirstDarkBorder : AppColors.darkBorder;
    }
    return isFirst ? AppColors.podiumFirstLightBorder : AppColors.lightBorder;
  }

  static Color _nameColor(bool isDark, bool isFirst) {
    if (isDark) return AppColors.darkText;
    if (isFirst) return AppColors.podiumFirstLightGreen;
    return AppColors.lightText;
  }

  static Color _iconColor(bool isDark, bool isFirst) {
    if (isDark) {
      return isFirst ? AppColors.kpiBarHigh : AppColors.darkTextMuted;
    }
    if (isFirst) return AppColors.podiumFirstLightGreen;
    return AppColors.lightTextMuted;
  }

  static Color _scoreColor(bool isDark, bool isFirst) {
    if (isDark) return AppColors.darkText;
    if (isFirst) return AppColors.podiumFirstLightGreen;
    return AppColors.lightText;
  }

  static _BadgeStyle _badgeStyle(bool isDark, bool isFirst) {
    if (isDark) {
      if (isFirst) {
        return const _BadgeStyle(
          background: AppColors.trendUpBgDark,
          border: AppColors.podiumFirstDarkBorder,
          text: AppColors.kpiBarHigh,
        );
      }
      return const _BadgeStyle(
        background: AppColors.darkSurfaceDeep,
        border: AppColors.darkBorder,
        text: AppColors.darkTextMuted,
      );
    }
    if (isFirst) {
      return const _BadgeStyle(
        background: AppColors.podiumFirstLightBg,
        border: AppColors.podiumFirstLightBorder,
        text: AppColors.podiumFirstLightBadgeGreen,
      );
    }
    return const _BadgeStyle(
      background: AppColors.lightSurfaceDeep,
      border: AppColors.lightBorder,
      text: AppColors.lightTextMuted,
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}
