import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../redeem_points/redeem_points_bottom_model.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final iconColor = theme.dashPrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: theme.dashCardDecoration(),
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
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: theme.dashStarBg,
                        border: Border.all(
                          color: theme.dashStarBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.star, color: theme.dashTitle),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Available\nPoints Earned',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: theme.dashPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _IconButton(
                      backgroundColor: theme.dashIconButtonBg,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.90,
                            child: const RedeemPointsBottomModal(),
                          ),
                        );
                      },
                      child: CustomPaint(
                        size: Size(14.w, 14.w),
                        painter: _ClipboardPainter(color: iconColor),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    _IconButton(
                      backgroundColor: theme.dashIconButtonBg,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.redeemPoints);
                      },
                      child: CustomPaint(
                        size: Size(14.w, 14.w),
                        painter: _ArrowUpRightPainter(color: iconColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 21.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                          color: theme.dashTitle,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'Pts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: theme.dashMuted,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.dashChipBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '0 this month',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5.sp,
                      color: theme.dashMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Material(
              color: theme.dashPrimary,
              borderRadius: BorderRadius.circular(8.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.redeemPoints);
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Redeem Points',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.highlightYellow,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward,
                        size: 20.sp,
                        color: AppColors.highlightYellow,
                      ),
                    ],
                  ),
                ),
              ),
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
