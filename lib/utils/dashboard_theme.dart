import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_palette.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Theme-aware colours for the status-first dashboard.
class DashboardTheme {
  const DashboardTheme({required this.isDark});

  final bool isDark;

  static DashboardTheme of(BuildContext context) {
    return DashboardTheme(isDark: ThemeScope.of(context).isDark);
  }

  Color get base => isDark ? AppColors.darkBase : AppColors.lightBase;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceDeep =>
      isDark ? AppColors.darkSurfaceDeep : AppColors.lightSurfaceDeep;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text =>
      isDark ? AppColors.darkText : AppColors.lightText;
  Color get textMuted =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get textBody =>
      isDark ? AppColors.darkTextBody : AppColors.textDarkBlue;
  Color get progressTrack =>
      isDark ? AppColors.darkProgressTrack : AppColors.lightProgressTrack;

  Color get trendUpFg =>
      isDark ? AppColors.trendUpDark : AppColors.trendUpLight;
  Color get trendUpBg =>
      isDark ? AppColors.trendUpBgDark : AppColors.trendUpBgLight;

  Color get kpiBarHighColor =>
      isDark ? AppColors.kpiBarHigh : AppColors.kpiBarHighLight;

  Color get headerBellBg =>
      isDark ? AppColors.darkSurfaceDeep : AppColors.lightHeaderBellBg;

  Color get accent => AppColors.primaryBlue;
  Color get accentSoft => AppColors.chartFillBlue;

  // Blue-accent dashboard (home UI)
  Color get dashCardBg => isDark ? AppColors.darkSurface : AppColors.white;
  Color get dashCardBorder =>
      isDark ? AppColors.darkBorder : DashboardPalette.borderLight;
  Color get dashCardBorderSoft => isDark
      ? AppColors.primaryBlue.withValues(alpha: 0.35)
      : AppColors.primaryBlue.withValues(alpha: 0.45);
  Color get dashHeading =>
      isDark ? AppColors.darkText : DashboardPalette.heading;
  Color get dashTitle =>
      isDark ? AppColors.darkText : DashboardPalette.primaryDeep;
  Color get dashSubtitle =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get dashMuted =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get dashPrimary =>
      isDark ? AppColors.accentBlue : DashboardPalette.primary;
  Color get dashPrimaryCalendar =>
      isDark ? AppColors.accentBlue : DashboardPalette.primary;
  Color get dashSurfaceTint =>
      isDark ? AppColors.darkSurfaceDeep : DashboardPalette.chartFill;
  Color get dashBorderLight =>
      isDark ? AppColors.darkBorder : DashboardPalette.borderLight;
  Color get dashIconButtonBg =>
      isDark ? AppColors.darkSurfaceDeep : DashboardPalette.chartTrack;
  Color get dashChipBg =>
      isDark ? AppColors.darkSurfaceDeep : DashboardPalette.chartTrack;
  Color get dashChartTrack =>
      isDark ? AppColors.darkProgressTrack : DashboardPalette.chartTrack;
  Color get dashStarBg =>
      isDark ? AppColors.darkSurfaceDeep : AppColors.accentLime;
  Color get dashStarBorder =>
      isDark ? AppColors.accentBlue : AppColors.starIconBorder;
  Color get dashWelcomeHeading =>
      isDark ? AppColors.accentBlue : DashboardPalette.heading;
  Color get dashWelcomeSubtext =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get dashHeaderBorder =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get dashShadow =>
      isDark ? Colors.transparent : AppColors.shadowSubtle;
  Color get dashCalendarDay =>
      isDark ? AppColors.darkTextBody : AppColors.textDarkBlue;
  Color get dashCalendarDisabled =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get dashTodayBg =>
      isDark
          ? AppColors.primaryBlue.withValues(alpha: 0.2)
          : DashboardPalette.borderLight;
  Color get dashSuccessBg =>
      isDark ? AppColors.trendUpBgDark : AppColors.successBackground;
  Color get dashSuccessFg =>
      isDark ? AppColors.trendUpDark : AppColors.successText;
  Color get dashCardShadow => isDark
      ? Colors.black.withValues(alpha: 0.25)
      : AppColors.textDarkBlue.withValues(alpha: 0.06);

  Color get chartBarFill =>
      AppColors.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.25);
  Color get chartBarSelected => AppColors.primaryBlue;
  Color get chartGridLine =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;

  BoxDecoration cardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: surface,
      border: Border.all(color: border, width: 0.5),
      borderRadius: BorderRadius.circular(radius.r),
    );
  }

  /// Shared card shell for dashboard sections (consistent shadow + border).
  BoxDecoration dashCardDecoration({
    double radius = 16,
    bool softBorder = false,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? dashCardBg,
      border: Border.all(
        color: softBorder ? dashCardBorderSoft : dashCardBorder,
        width: 1.25,
      ),
      borderRadius: BorderRadius.circular(radius.r),
      boxShadow: [
        BoxShadow(
          color: dashCardShadow,
          offset: Offset(0, 4.h),
          blurRadius: 12.r,
        ),
      ],
    );
  }
}
