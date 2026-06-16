import 'dart:math';

import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _CardData {
  const _CardData({
    required this.label,
    required this.value,
    required this.max,
    required this.asset,
  });

  final String label;
  final double value;
  final double max;
  final String asset;
}

const _kpiMax = 20.0;

List<_CardData> _cardsFromUser(UserModel user) {
  return [
    _CardData(
      label: 'Conversion Pool',
      value: user.conversion.score,
      max: _kpiMax,
      asset: 'assets/icons/conversion_pool.png',
    ),
    _CardData(
      label: 'Productivity Pool',
      value: user.productivity.score,
      max: _kpiMax,
      asset: 'assets/icons/productivity_pool.png',
    ),
    _CardData(
      label: 'Procedural Pool',
      value: user.procedural.score,
      max: _kpiMax,
      asset: 'assets/icons/procedural_pool.png',
    ),
    _CardData(
      label: 'Vehicular Pool',
      value: user.vehicular.score,
      max: _kpiMax,
      asset: 'assets/icons/vehicular_pool.png',
    ),
    _CardData(
      label: 'Satisfaction Pool',
      value: user.cSat.score,
      max: _kpiMax,
      asset: 'assets/icons/star.png',
    ),
  ];
}

class KpiOverview extends StatelessWidget {
  const KpiOverview({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final cards = _cardsFromUser(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Personal KPI Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.dashHeading,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your real-time performance summary and safety analytics',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.dashSubtitle,
            ),
          ),
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (_, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.goals,
                      arguments: user,
                    );
                  },
                  borderRadius: BorderRadius.circular(18.r),
                  child: _KpiCard(
                    data: cards[index],
                    theme: theme,
                  ),
                ),
              );
            },
          ),
        ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.data,
    required this.theme,
  });

  final _CardData data;
  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    final progress = (data.value / data.max).clamp(0.0, 1.0);

    final valueText = data.value % 1 == 0
        ? '${data.value.toInt()}/${data.max.toInt()}'
        : '${data.value}/${data.max.toInt()}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 18.h,
      ),
      decoration: theme.dashCardDecoration(radius: 18, softBorder: true),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 92.w,
            height: 92.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedProgress, _) {
                    return CustomPaint(
                      size: Size(92.w, 92.w),
                      painter: _ArcPainter(
                        progress: animatedProgress,
                        trackColor: theme.dashChartTrack,
                        progressColor: theme.dashPrimary,
                      ),
                    );
                  },
                ),
                Image.asset(
                  data.asset,
                  height: 24.h,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: theme.dashTitle,
            ),
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
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

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
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
