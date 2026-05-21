import 'dart:math';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/ui/screen_title_block.dart';
import 'package:chumley_navigator/widgets/ui/soft_icon_button.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SoftIconButton(
                  icon: Icons.close_rounded,
                  onTap: () =>
                      Navigator.popAndPushNamed(context, AppRoutes.home),
                ),
              ),
              const AspectBranding(),
              SizedBox(height: 24.h),
              const FadeSlideIn(
                child: ScreenTitleBlock(
                  title: 'Goal & Targets',
                  subtitle: 'Tap a pool to see your KPI Background',
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16.h),
                  itemCount: _cards.length,
                  separatorBuilder: (_, index) => SizedBox(height: 4.h),
                  itemBuilder: (_, index) => FadeSlideIn(
                    delay: Duration(milliseconds: 60 * index),
                    child: _KpiCard(data: _cards[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _CardData data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.value / data.max).clamp(0.0, 1.0);

    final valueText = data.value % 1 == 0
        ? '${data.value.toInt()}/${data.max.toInt()}'
        : '${data.value}/${data.max.toInt()}';

    return PressableScale(
      onTap: () {},
      scale: 0.985,
      child: ElevatedSurface(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        borderRadius: 22.r,
        borderColor: AppColors.accentBlue.withValues(alpha: 0.35),
        child: Row(
          children: [
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(92.w, 92.w),
                    painter: _ArcPainter(progress: progress),
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 26.sp,
                    color: AppColors.primaryBlue,
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
                    data.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: -0.15,
                      color: AppColors.textDarkBlue,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: AppColors.textDarkBlue,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.textPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress});

  final double progress;

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
        ..color = AppColors.chartTrackBlue
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
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
