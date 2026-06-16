import 'dart:math';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
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

class GoalsTargetsScreen extends StatefulWidget {
  const GoalsTargetsScreen({super.key});

  @override
  State<GoalsTargetsScreen> createState() => _GoalsTargetsScreenState();
}

class _GoalsTargetsScreenState extends State<GoalsTargetsScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  static double _easedCollapseProgress(double offset) {
    final raw = (offset / _scrollThreshold).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  void _onScroll() {
    final progress = _easedCollapseProgress(_scrollController.offset);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as UserModel?;
    final List<_CardData> cards;
    if (user != null) {
      cards = [
        _CardData(
          label: 'Conversion Pool',
          value: user.conversion.score,
          max: 20,
        ),
        _CardData(
          label: 'Productivity Pool',
          value: user.productivity.score,
          max: 20,
        ),
        _CardData(
          label: 'Procedural Pool',
          value: user.procedural.score,
          max: 20,
        ),
        _CardData(
          label: 'Vehicular Pool',
          value: user.vehicular.score,
          max: 20,
        ),
        _CardData(label: 'Satisfaction Pool', value: user.cSat.score, max: 20),
      ];
    } else {
      cards = _cards;
    }

    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: _brandingExpandedHeight + 28,
                    bottom: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 14.h),
                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Opacity(
                            opacity: (1.0 - progress).clamp(0.0, 1.0),
                            child: Text(
                              'Goals & targets',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: theme.textBody,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 14.h),
                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Opacity(
                            opacity: (1.0 - progress).clamp(0.0, 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 14.h),
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) SizedBox(height: 8.h),
                        FadeSlideIn(
                          delay: Duration(milliseconds: 50 * i),
                          child: _KpiCard(theme: theme, data: cards[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _collapseProgress,
                  builder: (context, progress, _) {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AspectBranding(
                        progress: progress,
                        expandedHeight: _brandingExpandedHeight,
                        collapsedHeight: _brandingCollapsedHeight,
                        theme: theme,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8.h,
                  left: 16.w,
                  child: _CloseButton(theme: theme),
                ),
              ],
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
      onTap: () => Navigator.pop(context),
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
        child: Icon(Icons.close_rounded, size: 16.sp, color: theme.textMuted),
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
    final arcColor = progress >= 0.7 ? theme.kpiBarHighColor : theme.accent;

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
                  Icon(Icons.trending_up_rounded, size: 22.sp, color: arcColor),
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
