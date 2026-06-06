import 'dart:math';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _CardData {
  const _CardData({
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final double value;
  final double max;
}

const List<_CardData> _cards = [
  _CardData(label: 'Conversion Pool', value: 8.1, max: 20),
  _CardData(label: 'Productivity Pool', value: 12.1, max: 20),
  _CardData(label: 'Procedural Pool', value: 14.2, max: 20),
  _CardData(label: 'Vehicular Pool', value: 18.1, max: 20),
  _CardData(label: 'Satisfaction Pool', value: 16.7, max: 20),
];

class GoalsTargetsScreen extends StatelessWidget {
  const GoalsTargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _CloseButton(theme: theme),
                  ),
                  const AspectBranding(),
                  SizedBox(height: 14.h),
                  Text(
                    'Goals & targets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  FadeSlideIn(
                    child: Text(
                      'KPI pools',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: theme.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 40),
                    child: Text(
                      'Tap a pool to see your KPI background',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.35,
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: _cards.length,
                      separatorBuilder: (context, _) =>
                          SizedBox(height: 8.h),
                      itemBuilder: (_, index) => FadeSlideIn(
                        delay: Duration(milliseconds: 50 * index),
                        child: _KpiCard(theme: theme, data: _cards[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.popAndPushNamed(context, AppRoutes.home),
      scale: 0.92,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: theme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close_rounded,
          size: 16.sp,
          color: theme.textMuted,
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.theme, required this.data});

  final DashboardTheme theme;
  final _CardData data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.value / data.max).clamp(0.0, 1.0);
    final arcColor =
        progress >= 0.7 ? theme.kpiBarHighColor : theme.accent;

    final valueText = data.value % 1 == 0
        ? '${data.value.toInt()}/${data.max.toInt()}'
        : '${data.value}/${data.max.toInt()}';

    return PressableScale(
      onTap: () {},
      scale: 0.985,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.border, width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(72.w, 72.w),
                    painter: _ArcPainter(
                      progress: progress,
                      trackColor: theme.progressTrack,
                      fillColor: arcColor,
                    ),
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 22.sp,
                    color: arcColor,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      height: 1.3,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: theme.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: theme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  static const double _startAngle = 135 * pi / 180;
  static const double _sweepAngle = 270 * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 102;
    final radius = 42 * scale;
    final strokeWidth = 7 * scale;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle * progress,
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor;
  }
}
