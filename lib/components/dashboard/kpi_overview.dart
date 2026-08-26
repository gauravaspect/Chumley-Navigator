import 'dart:math';

import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _kpiMax = 20.0;

class KpiOverview extends StatelessWidget {
  const KpiOverview({
    super.key,
    required this.user,
  });

  final UserModel user;

  double get _overallScore {
    final pools = [
      user.conversion.score,
      user.productivity.score,
      user.procedural.score,
      user.vehicular.score,
      user.cSat.score,
    ];
    if (user.overallRating > 0) return user.overallRating.clamp(0, _kpiMax);
    final sum = pools.fold<double>(0, (a, b) => a + b);
    return (sum / pools.length).clamp(0, _kpiMax);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final score = _overallScore;
    final progress = (score / _kpiMax).clamp(0.0, 1.0);
    final scoreLabel = score % 1 == 0
        ? score.toInt().toString()
        : score.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal KPI',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashHeading,
          ),
        ),
        SizedBox(height: 14.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.goals,
                arguments: user,
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
              decoration: theme.dashCardDecoration(radius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                  painter: _RingPainter(
                                    progress: animatedProgress,
                                    trackColor: theme.isDark
                                        ? theme.dashSurfaceTint
                                        : const Color(0xFFE9EDF5),
                                    progressColor: theme.dashPrimary,
                                    strokeWidth: 10,
                                  ),
                                );
                              },
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  scoreLabel,
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 34 / 32,
                                    letterSpacing: -1.4,
                                    color: theme.dashPrimary,
                                  ),
                                ),
                                Text(
                                  'of ${_kpiMax.toInt()}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 14 / 11,
                                    letterSpacing: 0.1,
                                    color: theme.dashMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Overall score',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 27 / 20,
                                      letterSpacing: -0.2,
                                      color: theme.dashTitle,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(
                                    7.w,
                                    4.h,
                                    9.w,
                                    4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.dashSuccessBg,
                                    borderRadius: BorderRadius.circular(500.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.arrowUp,
                                        size: 10.sp,
                                        color: theme.dashSuccessFg,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        '+1',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 14 / 11,
                                          letterSpacing: 0.2,
                                          color: theme.dashSuccessFg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Across all 5 KPI pools',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                height: 19 / 13,
                                color: theme.dashSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Divider(height: 1, color: theme.dashBorderLight),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'View pool breakdown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 18.sp,
                        color: theme.dashPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
