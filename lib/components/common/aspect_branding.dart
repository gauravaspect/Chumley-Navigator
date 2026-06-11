import 'dart:ui';

import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AspectBranding extends StatelessWidget {
  const AspectBranding({
    super.key,
    required this.progress,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.theme,
    this.title,
  });

  final double progress;
  final double expandedHeight;
  final double collapsedHeight;
  final DashboardTheme theme;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final containerHeight = lerpDouble(expandedHeight, collapsedHeight, t)!;
    // 0 = centred, 1 = flush right within horizontal padding.
    final horizontalAlign = lerpDouble(0, 1, t)!;

    // Sizes are proportional to [containerHeight] so callers can use smaller
    // expanded/collapsed heights (e.g. profile) without Column overflow.
    final logoHeight = containerHeight * lerpDouble(0.48, 0.50, t)!;
    final gap = containerHeight * lerpDouble(0.056, 0.040, t)!;
    final poweredByLogoHeight = containerHeight * lerpDouble(0.17, 0.20, t)!;
    final poweredByFontSize = containerHeight * lerpDouble(0.125, 0.16, t)!;

    return RepaintBoundary(
      child: Container(
        height: containerHeight,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.base.withValues(alpha: lerpDouble(0.88, 0.96, t)!),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (title != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(lerpDouble(-16.w, 0, t)!, 0),
                      child: title!,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment(horizontalAlign, 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/images/aspectLogo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: gap),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Powered by',
                          style: TextStyle(
                            color: theme.dashSubtitle,
                            fontSize: poweredByFontSize,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Opacity(
                          opacity: 0.6,
                          child: Image.asset(
                            'assets/images/nav_logo.png',
                            height: poweredByLogoHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
