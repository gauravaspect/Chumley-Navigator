/// Width bands and content max-widths for large-screen / foldable layouts.
///
/// Prefer these over device-name checks. Values align with Phase 6 audit bands.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Phone design canvas used by ScreenUtil (do not scale *up* past this).
  static const double phoneDesignWidth = 393;
  static const double phoneDesignHeight = 852;

  /// Below this: compact phone / folded-like single column.
  static const double compactMax = 600;

  /// Below this: medium (large phone / narrow unfolded).
  static const double mediumMax = 840;

  /// Below this: expanded; above: large tablet.
  static const double expandedMax = 1200;

  /// Readable form / wizard content column.
  static const double formContentMax = 640;

  /// Generic page content (dashboard, profile, lists).
  static const double pageContentMax = 840;

  /// Dialogs on large screens.
  static const double dialogMax = 480;

  /// Modal bottom sheets on large screens.
  static const double sheetMax = 640;

  /// Chat message bubble max width.
  static const double chatBubbleMax = 480;

  /// Job photo capture slot max width.
  static const double photoSlotMax = 420;
}
