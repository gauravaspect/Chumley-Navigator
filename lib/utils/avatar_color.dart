import 'package:flutter/material.dart';

import 'colors.dart';

/// Maps a stable hash to a readable avatar background from brand palette.
Color avatarColorFromSeed(int seed) {
  const palette = [
    AppColors.primaryBlue,
    AppColors.primaryBlueDark,
    AppColors.accentBlue,
    Color(0xFFAC3232),
    Color(0xFF6A2020),
    AppColors.textDarkBlue,
  ];
  return palette[seed.abs() % palette.length];
}
