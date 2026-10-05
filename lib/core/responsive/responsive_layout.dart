import 'package:chumley_navigator/core/responsive/foldable_utils.dart';
import 'package:chumley_navigator/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ResponsiveSizeClass { compact, medium, expanded, large }

/// Centralized width-based layout decisions (no device-brand checks).
class ResponsiveLayout {
  ResponsiveLayout._();

  /// Used by [ScreenUtilInit.enableScaleWH] / [enableScaleText].
  ///
  /// Returns true only when the viewport is *narrower* than the phone design
  /// canvas — so small phones scale down, but unfolded/tablet widths never
  /// enlarge `.w` / `.h` / `.sp`.
  static bool screenUtilShouldScale() {
    try {
      final width = ScreenUtil().screenWidth;
      return width > 0 && width < ResponsiveBreakpoints.phoneDesignWidth;
    } catch (_) {
      return true;
    }
  }

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static ResponsiveSizeClass sizeClassOf(BuildContext context) {
    final w = widthOf(context);
    if (w < ResponsiveBreakpoints.compactMax) {
      return ResponsiveSizeClass.compact;
    }
    if (w < ResponsiveBreakpoints.mediumMax) {
      return ResponsiveSizeClass.medium;
    }
    if (w < ResponsiveBreakpoints.expandedMax) {
      return ResponsiveSizeClass.expanded;
    }
    return ResponsiveSizeClass.large;
  }

  static bool isLargeScreen(BuildContext context) {
    return widthOf(context) >= ResponsiveBreakpoints.compactMax;
  }

  /// True when Flutter reports fold/hinge display features.
  static bool isFoldable(BuildContext context) {
    return FoldableUtils.foldOrHingeBounds(context).isNotEmpty;
  }

  static double contentMaxWidth(BuildContext context, {double? maxWidth}) {
    return maxWidth ?? ResponsiveBreakpoints.pageContentMax;
  }

  static double formMaxWidth(BuildContext context) =>
      ResponsiveBreakpoints.formContentMax;

  static double dialogMaxWidth(BuildContext context) =>
      ResponsiveBreakpoints.dialogMax;

  static double sheetMaxWidth(BuildContext context) {
    final w = widthOf(context);
    if (w < ResponsiveBreakpoints.compactMax) return w;
    return ResponsiveBreakpoints.sheetMax;
  }

  static double chatBubbleMaxWidth(BuildContext context) {
    final w = widthOf(context);
    final pct = isLargeScreen(context) ? 0.55 : 0.85;
    final fromPct = w * pct;
    return fromPct.clamp(200.0, ResponsiveBreakpoints.chatBubbleMax);
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    final base = switch (sizeClassOf(context)) {
      ResponsiveSizeClass.compact => 16.0,
      ResponsiveSizeClass.medium => 20.0,
      ResponsiveSizeClass.expanded => 24.0,
      ResponsiveSizeClass.large => 32.0,
    };
    final hinge = FoldableUtils.hingeSafePadding(context);
    return EdgeInsets.only(left: base + hinge.left, right: base + hinge.right);
  }

  /// Column count for photo grids from available width.
  static int photoGridColumns(double maxWidth, {double minTile = 120}) {
    final cols = (maxWidth / minTile).floor();
    return cols.clamp(2, 4);
  }
}
