import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/material.dart';

/// Display-feature helpers for fold/hinge awareness.
///
/// Only applies insets when a real [DisplayFeature] exists. Does not assume
/// every feature is a hinge.
class FoldableUtils {
  FoldableUtils._();

  static List<DisplayFeature> displayFeaturesOf(BuildContext context) {
    return MediaQuery.displayFeaturesOf(context);
  }

  /// True when the view reports any display features (fold, hinge, cutout, etc.).
  static bool hasDisplayFeatures(BuildContext context) {
    return displayFeaturesOf(context).isNotEmpty;
  }

  /// Bounds of hinge / fold features only (excludes cutouts).
  static List<Rect> foldOrHingeBounds(BuildContext context) {
    return [
      for (final f in displayFeaturesOf(context))
        if (f.type == DisplayFeatureType.hinge ||
            f.type == DisplayFeatureType.fold)
          f.bounds,
    ];
  }

  /// Extra horizontal padding to keep content off a vertical hinge/fold.
  ///
  /// Returns [EdgeInsets.zero] when no fold/hinge is present.
  static EdgeInsets hingeSafePadding(BuildContext context) {
    final features = foldOrHingeBounds(context);
    if (features.isEmpty) return EdgeInsets.zero;

    final size = MediaQuery.sizeOf(context);
    var left = 0.0;
    var right = 0.0;

    for (final bounds in features) {
      // Vertical strip spanning most of the height → pad away from that band.
      final isVerticalStrip = bounds.height >= size.height * 0.8;
      if (!isVerticalStrip) continue;

      final hingeCenter = bounds.center.dx;
      final mid = size.width / 2;
      if (hingeCenter < mid) {
        if (bounds.right > left) left = bounds.right;
      } else {
        final fromRight = size.width - bounds.left;
        if (fromRight > right) right = fromRight;
      }
    }

    if (left < 8 && right < 8) return EdgeInsets.zero;
    return EdgeInsets.only(left: left, right: right);
  }
}
