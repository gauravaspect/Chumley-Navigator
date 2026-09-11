import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/number_display.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({super.key, required this.user});

  final UserModel user;

  int get _points => user.performanceScore.round();

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final iconColor = theme.dashPrimary;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final history = state.performanceHistoryOrNull;
        final cumulativePoints = history?.cumulativeTotal ?? _points;
        final thisMonthPoints = history?.thisMonthTotal ?? 0;
        final cumulativeLabel = formatIntegerWithCommas(cumulativePoints);
        final thisMonthLabel =
            '${formatSignedIntegerWithCommas(thisMonthPoints)} this month';

        return _PointsCardBody(
          theme: theme,
          iconColor: iconColor,
          user: user,
          performanceHistory: history ?? const EngineerPerformanceHistory(),
          cumulativeLabel: cumulativeLabel,
          thisMonthLabel: thisMonthLabel,
        );
      },
    );
  }
}

class _PointsCardBody extends StatelessWidget {
  const _PointsCardBody({
    required this.theme,
    required this.iconColor,
    required this.user,
    required this.performanceHistory,
    required this.cumulativeLabel,
    required this.thisMonthLabel,
  });

  final DashboardTheme theme;
  final Color iconColor;
  final UserModel user;
  final EngineerPerformanceHistory performanceHistory;
  final String cumulativeLabel;
  final String thisMonthLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        color: AppColors.primaryBlue,
        // decoration: theme.dashCardDecoration(),
        padding: EdgeInsets.only(
          left: 11.w,
          right: 12.w,
          top: 12.h,
          bottom: 12.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: AppColors.white, size: 24.sp),
                    Text(
                      'Available Points',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: AppColors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$cumulativeLabel ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                          color: AppColors.white,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'Pts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: AppColors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLime,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    thisMonthLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5.sp,
                      color: theme.dashPrimaryCalendar,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Material(
                    borderRadius: BorderRadius.circular(18.r),
                    color: AppColors.accentLime,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.redeemPoints,
                          arguments: {
                            'user': user,
                            'performanceHistory': performanceHistory,
                          },
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 38.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Redeem Points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              LucideIcons.gift,
                              size: 18.sp,
                              color: AppColors.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(18.r),
                    color: AppColors.white,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.redeemPoints,
                          arguments: {
                            'user': user,
                            'performanceHistory': performanceHistory,
                          },
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 38.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.history,
                              size: 18.sp,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.onTap,
    required this.child,
    required this.backgroundColor,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ClipboardPainter extends CustomPainter {
  _ClipboardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 4, 12, 16),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, paint);

    final clip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(9, 2.5, 6, 3),
      const Radius.circular(0.8),
    );
    canvas.drawRRect(clip, paint);

    final lines = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(9, 11), const Offset(15, 11), lines);
    canvas.drawLine(const Offset(9, 14.5), const Offset(15, 14.5), lines);
    canvas.drawLine(const Offset(9, 18), const Offset(13, 18), lines);
  }

  @override
  bool shouldRepaint(covariant _ClipboardPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ArrowUpRightPainter extends CustomPainter {
  _ArrowUpRightPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(7, 17)
      ..lineTo(17, 7)
      ..moveTo(17, 7)
      ..lineTo(9, 7)
      ..moveTo(17, 7)
      ..lineTo(17, 15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowUpRightPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
