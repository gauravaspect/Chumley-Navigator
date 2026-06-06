import 'dart:ui';

class AppColors {
  // Splash & brand
  static const splashBackground = Color(0xFF7829DA);
  static const primaryTextPurple = Color(0xFF380D73);

  // Surfaces & backgrounds
  static const white = Color(0xFFFFFFFF);
  static const backgroundWhite = Color(0xFFFFFFFF);
  static const backgroundBlue = Color(0xFFF1F7FF);
  static const backgroundGray = Color(0xFFF7F9FC);
  static const surfaceLightBlue = Color(0xFFF6FAFF);
  static const surfaceBlueTint = Color(0xFFEEF4FF);
  static const progressTrackBackground = Color(0xFFEAF1FB);

  // Brand red (dashboard primary accent)
  static const brandRed = Color(0xFFAC3232);
  static const brandRedDark = Color(0xFF8D2A2A);
  static const brandRedDeep = Color(0xFF6A2020);
  static const brandRedSoft = Color(0xFFC94A4A);
  static const brandRedFill = Color(0xFFF5DEDE);
  static const brandRedTrack = Color(0xFFF0E0E0);
  static const brandRedBorderLight = Color(0xFFE8C4C4);

  // Primary blues (interactive, headings — rest of app)
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

  // Highlights (points, nav)
  static const highlightYellow = Color(0xFFF1FF24);
  static const accentLime = Color(0xFFF4FF7F);
  static const starIconBorder = brandRedDeep;

  // Borders & dividers
  static const borderDefault = Color(0xFFE5E5EF);
  static const dividerLight = Color(0xFFEEF0F3);
  static const chartGridLine = Color(0xFFEEF2FA);

  // Semantic
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
  static const gradientPromoStart = Color(0xFFE1322F);
  static const gradientPromoEnd = Color(0xFFF57323);

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

  // Light mode surfaces (dashboard — warm red-forward)
  static const lightBase = Color(0xFFF7F6F3);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceDeep = Color(0xFFFFF4F4);
  static const lightBorder = Color(0xFFE3D8D8);
  static const lightText = brandRedDeep;
  static const lightTextMuted = Color(0xFF9A7A7A);
  static const lightProgressTrack = brandRedTrack;

  /// Light-mode notification bell background (header).
  static const lightHeaderBellBg = Color(0xFFFFF4F4);

  // Dashboard semantic (shared)
  static const kpiBarLow = Color(0xFF378ADD);
  static const kpiBarHigh = Color(0xFF4ADE80);
  static const kpiBarHighLight = Color(0xFF166534);
  static const trendUpDark = Color(0xFF4ADE80);
  static const trendUpBgDark = Color(0xFF1B3A2A);
  static const trendUpLight = Color(0xFF166534);
  static const trendUpBgLight = Color(0xFFDCF5E8);
  static const trendDownLight = Color(0xFFA32D2D);

  // Leaderboard podium (1st place accents)
  static const podiumFirstDarkBorder = Color(0xFF2A3A2A);
  static const podiumFirstLightBg = Color(0xFFEAF3DE);
  static const podiumFirstLightBorder = Color(0xFFC0DD97);
  static const podiumFirstLightGreen = Color(0xFF27500A);
  static const podiumFirstLightBadgeGreen = Color(0xFF3B6D11);
}
