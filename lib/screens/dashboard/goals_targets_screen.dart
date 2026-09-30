import 'dart:math';

import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _PoolData {
  const _PoolData({
    required this.label,
    required this.value,
    required this.max,
    required this.icon,
    required this.delta,
  });

  final String label;
  final double value;
  final double max;
  final IconData icon;
  final int delta;
}

class GoalsTargetsScreen extends StatelessWidget {
  const GoalsTargetsScreen({super.key});

  static const _kpiMax = 20.0;

  List<_PoolData> _poolsFromUser(UserModel? user) {
    if (user == null) {
      return const [
        _PoolData(
          label: 'Conversion',
          value: 12,
          max: _kpiMax,
          icon: LucideIcons.target,
          delta: 2,
        ),
        _PoolData(
          label: 'Productivity',
          value: 12,
          max: _kpiMax,
          icon: LucideIcons.trendingUp,
          delta: -1,
        ),
        _PoolData(
          label: 'Procedural',
          value: 17,
          max: _kpiMax,
          icon: LucideIcons.clipboardCheck,
          delta: 2,
        ),
        _PoolData(
          label: 'Vehicular',
          value: 4,
          max: _kpiMax,
          icon: LucideIcons.car,
          delta: -1,
        ),
        _PoolData(
          label: 'Satisfaction',
          value: 18,
          max: _kpiMax,
          icon: LucideIcons.star,
          delta: 3,
        ),
      ];
    }

    return [
      _PoolData(
        label: 'Conversion',
        value: user.conversion.score,
        max: _kpiMax,
        icon: LucideIcons.target,
        delta: 2,
      ),
      _PoolData(
        label: 'Productivity',
        value: user.productivity.score,
        max: _kpiMax,
        icon: LucideIcons.trendingUp,
        delta: -1,
      ),
      _PoolData(
        label: 'Procedural',
        value: user.procedural.score,
        max: _kpiMax,
        icon: LucideIcons.clipboardCheck,
        delta: 2,
      ),
      _PoolData(
        label: 'Vehicular',
        value: user.vehicular.score,
        max: _kpiMax,
        icon: LucideIcons.car,
        delta: -1,
      ),
      _PoolData(
        label: 'Satisfaction',
        value: user.cSat.score,
        max: _kpiMax,
        icon: LucideIcons.star,
        delta: 3,
      ),
    ];
  }

  double _overallScore(UserModel? user, List<_PoolData> pools) {
    if (user != null && user.overallRating > 0) {
      return user.overallRating.clamp(0, _kpiMax);
    }
    final sum = pools.fold<double>(0, (a, b) => a + b.value);
    return (sum / pools.length).clamp(0, _kpiMax);
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as UserModel?;
    final pools = _poolsFromUser(user);
    final overall = _overallScore(user, pools);
    final weakest = pools.reduce((a, b) => a.value <= b.value ? a : b);

    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          appBar: AppBar(
            backgroundColor: theme.base,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
                color: theme.dashPrimary,
                size: 22.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'KPI pools',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.dashHeading,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: theme.isDark
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF4F9FF),
                        Color(0xFFEDF4FE),
                        Color(0xFFE2ECFA),
                      ],
                      stops: [0, 0.55, 1],
                    ),
              color: theme.isDark ? theme.base : null,
            ),
            child: SafeArea(
              top: false,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
                children: [
                  _OverallHero(score: overall, max: _kpiMax, theme: theme),
                  SizedBox(height: 14.h),
                  _NudgeCard(pool: weakest, theme: theme),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your pools',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashHeading,
                          ),
                        ),
                      ),
                      Text(
                        'This month',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.dashMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  for (var i = 0; i < pools.length; i++) ...[
                    if (i > 0) SizedBox(height: 10.h),
                    _PoolRow(pool: pools[i], theme: theme),
                  ],
                  SizedBox(height: 16.h),
                  Text(
                    'Scores refresh daily at 06:00. Tap a pool to see how it is calculated.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 17 / 12,
                      color: theme.dashMuted,
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

class _OverallHero extends StatelessWidget {
  const _OverallHero({
    required this.score,
    required this.max,
    required this.theme,
  });

  final double score;
  final double max;
  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    final progress = (score / max).clamp(0.0, 1.0);
    final scoreLabel = score % 1 == 0
        ? score.toInt().toString()
        : score.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.dashPrimary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88.w,
            height: 88.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(88.w, 88.w),
                  painter: _RingPainter(
                    progress: progress,
                    trackColor: Colors.white.withValues(alpha: 0.2),
                    progressColor: AppColors.accentLime,
                    strokeWidth: 9.7,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scoreLabel,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -1.2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'of ${max.toInt()}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall score',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    height: 23 / 17,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Average across your 5 pools',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    height: 19 / 13,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.fromLTRB(8.w, 4.h, 10.w, 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(500.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.arrowUp,
                        size: 11.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '+1 this month',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          height: 14 / 11,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.pool, required this.theme});

  final _PoolData pool;
  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFB45309);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: theme.isDark
            ? AppColors.pendingBackground.withValues(alpha: 0.15)
            : const Color(0xFFFEF6E7),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.trendingUp, size: 18.sp, color: amber),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pool.label} is holding your pay back',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: amber,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '3 fixes worth about £60 a month',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: amber.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 17.sp, color: amber),
        ],
      ),
    );
  }
}

class _PoolRow extends StatelessWidget {
  const _PoolRow({required this.pool, required this.theme});

  final _PoolData pool;
  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    final progress = (pool.value / pool.max).clamp(0.0, 1.0);
    final up = pool.delta >= 0;
    final deltaColor = up ? const Color(0xFF15803D) : const Color(0xFFC42A2A);
    final valueLabel = pool.value % 1 == 0
        ? pool.value.toInt().toString()
        : pool.value.toStringAsFixed(1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
          decoration: theme.dashCardDecoration(radius: 18),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? theme.dashSurfaceTint
                      : const Color(0xFFD8E6FC),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(pool.icon, size: 20.sp, color: theme.dashPrimary),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pool.label,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.dashTitle,
                            ),
                          ),
                        ),
                        Text(
                          valueLabel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashTitle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'of ${pool.max.toInt()}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: theme.dashMuted,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          up ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                          size: 10.sp,
                          color: deltaColor,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${up ? '+' : ''}${pool.delta}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: deltaColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(500.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7.h,
                        backgroundColor: theme.isDark
                            ? theme.dashSurfaceTint
                            : const Color(0xFFE9EDF5),
                        valueColor: AlwaysStoppedAnimation(theme.dashPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                LucideIcons.chevronRight,
                size: 18.sp,
                color: const Color(0xFF8A99B0),
              ),
            ],
          ),
        ),
      ),
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
