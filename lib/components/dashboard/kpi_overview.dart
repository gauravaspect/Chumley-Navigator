import 'dart:math';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────
// KPI OVERVIEW
// ─────────────────────────────────────────────────────────────

class KpiOverview extends StatelessWidget {
  const KpiOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only( bottom:14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal KPI Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlueDark,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'Your real-time performance summary and safety analytics',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 20.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (_, index) {
              return GestureDetector(
                  onTap: (){Navigator.pushNamed(context, AppRoutes.goals);},
                  child: _KpiCard(data: _cards[index]));
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KPI CARD
// ─────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.data,
  });

  final _CardData data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.value / data.max).clamp(0.0, 1.0);

    final valueText = data.value % 1 == 0
        ? '${data.value.toInt()}/${data.max.toInt()}'
        : '${data.value}/${data.max.toInt()}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 18.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.accentBlue,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ─────────────────────────────────────────
          // PROGRESS ARC
          // ─────────────────────────────────────────

          SizedBox(
            width: 92.w,
            height: 92.w,
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

          // ─────────────────────────────────────────
          // SCORE
          // ─────────────────────────────────────────

          Text(
            valueText,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkBlue,
            ),
          ),

          // ─────────────────────────────────────────
          // LABEL
          // ─────────────────────────────────────────

          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ARC PAINTER
// ─────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
  });

  final double progress;

  static const double _startAngle = 135 * pi / 180;
  static const double _sweepAngle = 270 * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 102;

    final radius = 42 * scale;
    final strokeWidth = 7 * scale;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // BACKGROUND ARC

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

    // PROGRESS ARC

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