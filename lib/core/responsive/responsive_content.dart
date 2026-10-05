import 'package:chumley_navigator/core/responsive/responsive_breakpoints.dart';
import 'package:chumley_navigator/core/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Centers [child] and caps width on large screens. Phone layouts stay full-width.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.applyHorizontalPadding = false,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;

  /// Override max content width (defaults to [ResponsiveBreakpoints.pageContentMax]).
  final double? maxWidth;

  /// Optional padding around the constrained child.
  final EdgeInsetsGeometry? padding;

  /// When true, applies [ResponsiveLayout.horizontalPadding].
  final bool applyHorizontalPadding;

  final Alignment alignment;

  /// Convenience for form / wizard shells.
  factory ResponsiveContent.form({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool applyHorizontalPadding = false,
  }) {
    return ResponsiveContent(
      key: key,
      maxWidth: ResponsiveBreakpoints.formContentMax,
      padding: padding,
      applyHorizontalPadding: applyHorizontalPadding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cap = ResponsiveLayout.contentMaxWidth(context, maxWidth: maxWidth);
    final resolvedPadding =
        padding ??
        (applyHorizontalPadding
            ? ResponsiveLayout.horizontalPadding(context)
            : EdgeInsets.zero);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: Padding(padding: resolvedPadding, child: child),
      ),
    );
  }
}
