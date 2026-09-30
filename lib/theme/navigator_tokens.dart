import 'package:flutter/material.dart';

/// 1:1 tokens from `color-scheme.md` and HTML `:root`
/// (`Navigator-Modern-2026-live.html`). One palette for leak, gas, and works.
class NavigatorTokens {
  NavigatorTokens._();

  // Brand
  static const brandNavy = Color(0xFF27549D);
  static const brandNavyDeep = Color(0xFF1A3A73);
  static const brandNavySoft = Color(0xFFC9DCF7);
  static const brandNavyTint = Color(0xFFD8E6FC);
  static const brandYellow = Color(0xFFFFF23D);
  static const brandYellowDeep = Color(0xFFE9F94A);
  static const brandYellowTint = Color(0xFFFBFFDE);
  static const brandYellow300 = Color(0xFFF4FF7F);

  static const navy = brandNavy;
  static const navyDeep = brandNavyDeep;
  static const navySoft = brandNavySoft;
  static const navyTint = brandNavyTint;
  static const navyLight = Color(0xFF5A9CF6);
  static const yellow = brandYellow;
  static const yellowDeep = brandYellowDeep;
  static const yellowTint = brandYellowTint;

  // Surfaces
  static const pageTop = Color(0xFFF4F9FF);
  static const pageMid = Color(0xFFEDF4FE);
  static const pageBottom = Color(0xFFE2ECFA);
  static const surfaceChrome = pageTop;
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFE3E9F2);
  static const surfaceSunken = Color(0xFFE9EDF5);
  static const surfacePage = Color(0xFFF1F3F8);
  static const surfaceDarker = Color(0xFF17325E);
  static const surfaceDefault = brandNavy;
  static const surfaceLighter = navyLight;
  static const fillTertiary = Color(0xFFF1F5F9);
  static const card = surfaceCard;
  static const muted = surfaceMuted;
  static const sunken = surfaceSunken;

  // Text
  static const textPrimary = Color(0xFF0B1F3A);
  static const textSecondary = Color(0xFF5A6B85);
  static const textTertiary = Color(0xFF8A99B0);
  static const textInverse = Color(0xFFFFFFFF);
  static const textBrand = brandNavy;
  static const textOnNavy = textInverse;

  // Borders
  static const borderHairline = Color(0xFFE2E7F0);
  static const borderStrong = Color(0xFFD3DBE8);
  static const borderLighter = Color(0xFF9FC3FC);
  static const borderSubtle = surfaceMuted;
  static const hairline = borderHairline;
  static const border = borderStrong;

  // Status — HTML TONE
  static const infoBg = Color(0xFFD8E6FC);
  static const infoFg = brandNavy;
  static const successBg = Color(0xFFE9F8EF);
  static const successFg = Color(0xFF15803D);
  static const warningBg = Color(0xFFFEF6E7);
  static const warningFg = Color(0xFFB45309);
  static const errorBg = Color(0xFFFDEDED);
  static const errorFg = Color(0xFFC42A2A);
  static const green100 = Color(0xFFD3FAD1);
  static const red100 = Color(0xFFFFDDD2);
  static const red700 = Color(0xFFA72B01);
  static const success = successFg;
  static const warning = warningFg;
  static const error = errorFg;

  /// Journey accents from HTML TONE (not Tailwind).
  static const dispatched = brandNavy;
  static const inTransit = warningFg;
  static const onSite = brandNavy;
  static const complete = successFg;

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pageTop, pageMid, pageBottom],
    stops: [0.0, 0.55, 1.0],
  );

  static BorderRadius get fieldRadius => BorderRadius.circular(10);
  static BorderRadius get buttonRadius => BorderRadius.circular(14);
  static BorderRadius get cardRadius => BorderRadius.circular(20);

  /// HTML: `0px 1px 2px rgba(11,31,58,0.04), 0px 2px 10px rgba(11,31,58,0.06)`
  static List<BoxShadow> get cardShadows => const [
    BoxShadow(color: Color(0x0A0B1F3A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F0B1F3A), blurRadius: 10, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get actionBarShadows => const [
    BoxShadow(color: Color(0x0F0B1F3A), blurRadius: 16, offset: Offset(0, -2)),
  ];

  static TextStyle titleStyle(double sp) => TextStyle(
    fontSize: sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.7,
    color: textPrimary,
  );

  static TextStyle captionStyle(double sp) => TextStyle(
    fontSize: sp,
    fontWeight: FontWeight.w400,
    height: 1.42,
    color: textTertiary,
  );

  static TextStyle fieldLabelStyle(double sp) => TextStyle(
    fontSize: sp,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: textPrimary,
  );

  static TextStyle buttonLabelStyle(double sp) => TextStyle(
    fontSize: sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textInverse,
  );
}
