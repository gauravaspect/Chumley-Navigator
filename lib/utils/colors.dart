import 'dart:ui';

class AppColors {
  // Splash & brand
  static const splashBackground = Color(0xFF6728C8);
  // static const splashBackground = Color(0xFF7829DA);
  static const primaryTextPurple = Color(0xFF380D73);

  // Surfaces & backgrounds
  static const white = Color(0xFFFFFFFF);
  static const backgroundWhite = Color(0xFFFFFFFF);
  static const backgroundBlue = Color(0xFFF1F7FF);
  static const backgroundGray = Color(0xFFF7F9FC);
  static const surfaceLightBlue = Color(0xFFF6FAFF);
  static const surfaceBlueTint = Color(0xFFEEF4FF);
  static const progressTrackBackground = Color(0xFFEAF1FB);

  // Primary blues (interactive, headings — dashboard accent)
  static const primaryBlue = Color(0xFF27549D);
  static const primaryBlueDark = Color(0xFF1A4781);
  static const primaryBlueCalendar = Color(0xFF27449D);

  // Accent blues (borders, links, charts)
  static const accentBlue = Color(0xFF5A9CF6);
  static const textBlue = accentBlue;
  static const accentBlueGradientEnd = Color(0xFF4A8CE5);
  static const borderAccentBlue = Color(0xFF3B73CE);
  static const borderLightBlue = Color(0xFF9FC3FC);
  static const chartFillBlue = Color(0xFFD8E6FF);
  static const chartTrackBlue = Color(0xFFDCEAFE);

  // Text
  static const textDarkBlue = Color(0xFF17325E);
  static const textSecondary = Color(0xFF848EA3);
  static const textBodyMuted = Color(0xFF646F86);
  static const textPlaceholder = Color(0xFFB6BCC8);
  static const textInactive = Color(0xFF9CA3AF);
  static const textHeadingDark = Color(0xFF1E1B39);
  static const textLoginTitle = Color(0xFF1F2937);
  static const textLoginSubtitle = Color(0xFF4B5563);
  static const textChartLegend = Color(0xFF615E83);
  static const textCalendarDay = Color(0xFF333333);
  static const textCalendarDisabled = Color(0xFFBDBDBD);
  static const textShadow = Color(0xFF323843);

  // Purple (profile card)
  static const textPurple = Color(0xFF7C2BDE);
  static const profileBorderPurple = Color(0xFFE9D1FF);
  static const profileGradientStart = Color(0xFFFAF5FF);
  static const profileGradientEnd = Color(0xFFFFF5EC);
  static const profileDividerPurple = Color(0xFFF1E2FF);

  // Highlights (points, nav, CTA text)
  static const highlightYellow = Color(0xFFF1FF24);
  static const accentLime = Color(0xFFF4FF7F);
  static const starIconBorder = borderAccentBlue;

  // Borders & dividers
  static const borderDefault = Color(0xFFE5E5EF);
  static const dividerLight = Color(0xFFEEF0F3);
  static const chartGridLine = Color(0xFFEEF2FA);

  // Semantic
  static const successGreen = Color(0xFF22C55E);
  static const successBackground = Color(0xFFDCFCE7);
  static const successText = Color(0xFF166534);
  static const errorBackground = Color(0xFFFDECEC);
  static const errorBorder = Color(0xFFFCA5A5);
  static const errorText = Color(0xFFB91C1C);
  static const vcrWarningBackground = Color(0xFFFDEDEA);
  static const vcrWarningBorder = Color(0xFFFFC0B6);
  static const vcrWarningText = Color(0xFFB62D00);
  static const vcrWarningIcon = Color(0xFFE8520A);
  static const inputPlaceholder = Color(0xFFCDD1DA);
  static const buttonDisabledBackground = Color(0xFFE8EAEE);
  static const pendingBackground = Color(0xFFFFF5D6);
  static const pendingText = Color(0xFF8A6D00);
  static const streakOrange = Color(0xFFFD541C);

  // Gift card brand colors
  static const giftCardTargetBg = Color(0xFF6E1F2A);
  static const giftCardNhsBg = Color(0xFF005EB8);
  static const giftCardAmazonBg = Color(0xFF232F3E);
  static const giftCardAmazonAmount = Color(0xFFFF9900);
  static const giftCardSainsburysBg = Color(0xFFF06C00);
  static const giftCardMorrisonsBg = Color(0xFF4C12A1);
  static const giftCardMcdonaldsBg = Color(0xFFFBCE07);
  static const giftCardMcdonaldsAmount = Color(0xFFDD1D21);

  // Card shine overlay gradient
  static const cardShineStart = Color(0xD9FFD778);
  static const cardShineEnd = Color(0x66FFFFFF);

  // Shadows (black at fixed opacity — prefer these over inline withOpacity)
  static const shadowSubtle = Color(0x0A000000); // ~4% black
  static const shadowSoft = Color(0x14000000); // ~8% black
  static const shadowMedium = Color(0x1F000000); // ~12% black

  // Dark mode surfaces (dashboard command centre)
  static const darkBase = Color(0xFF0D0D12);
  static const darkSurface = Color(0xFF1A1A28);
  static const darkSurfaceDeep = Color(0xFF13131E);
  static const darkBorder = Color(0xFF2A2A3A);
  static const darkText = Color(0xFFF5F5F5);
  static const darkTextMuted = Color(0xFF6B7280);
  static const darkTextBody = Color(0xFFD1D5DB);
  static const darkProgressTrack = Color(0xFF1E1E2E);

  // Light mode surfaces (dashboard — blue-forward)
  static const lightBase = backgroundGray;
  static const lightSurface = white;
  static const lightSurfaceDeep = surfaceLightBlue;
  static const lightBorder = borderDefault;
  static const lightText = textDarkBlue;
  static const lightTextMuted = textSecondary;
  static const lightProgressTrack = progressTrackBackground;
  static const lightHeaderBellBg = surfaceBlueTint;

  // Dashboard semantic (shared)
  static const kpiBarLow = Color(0xFF378ADD);
  static const kpiBarHigh = Color(0xFF4ADE80);
  static const kpiBarHighLight = Color(0xFF166534);
  static const trendUpDark = Color(0xFF4ADE80);
  static const trendUpBgDark = Color(0xFF1B3A2A);
  static const trendUpLight = Color(0xFF166534);
  static const trendUpBgLight = Color(0xFFDCF5E8);
  static const trendDownLight = Color(0xFFA32D2D);

  /// PPM / demo jobs accent (distinct from appointment blue)
  static const ppmAccent = Color(0xFF0D9488);
  static const ppmAccentSoft = Color(0xFFCCFBF1);

  // Leaderboard podium (1st place accents)
  static const podiumFirstDarkBorder = Color(0xFF2A3A2A);
  static const podiumFirstLightBg = Color(0xFFEAF3DE);
  static const podiumFirstLightBorder = Color(0xFFC0DD97);
  static const podiumFirstLightGreen = Color(0xFF27500A);
  static const podiumFirstLightBadgeGreen = Color(0xFF3B6D11);

  // Milestone Tiers
  static const Color tierBronze   = Color(0xFFCD7F32);
  static const Color tierSilver   = Color(0xFFB0B7C3);
  static const Color tierGold     = Color(0xFFF59E0B);  // reuse amber
  static const Color tierPlatinum = Color(0xFF60A5FA);  // blue-300
  static const Color tierDiamond  = Color(0xFFA78BFA);  // violet-400
  static const Color tierOneOff   = Color(0xFF34D399);  // emerald (for Welcome Aboard)
}
