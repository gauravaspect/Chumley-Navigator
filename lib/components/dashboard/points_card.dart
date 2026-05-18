import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../redeem_points/redeem_points_bottom_model.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderAccentBlue, width: 1.25),
        borderRadius: BorderRadius.circular(16.r),
      ),
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
          // ── Top Row ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Star icon + label
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.accentLime,
                      border: Border.all(
                        color: AppColors.starIconBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.star, color: AppColors.textDarkBlue),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Available\nPoints Earned',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: AppColors.primaryBlue,
                      height: 1.3,
                    ),
                  ),
                ],
              ),

              // Action buttons
              Row(
                children: [
                  _IconButton(
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
                      painter: _ClipboardPainter(),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  _IconButton(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.redeemPoints);
                    },
                    child: CustomPaint(
                      size: Size(14.w, 14.w),
                      painter: _ArrowUpRightPainter(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Points Row ────────────────────────────────────────
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
                        color: AppColors.textDarkBlue,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: 'Pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.textBodyMuted,
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
                  color: AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '0 this month',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5.sp,
                    color: AppColors.textBodyMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),

          // ── Redeem Button ─────────────────────────────────────
          SizedBox(height: 22.h),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.redeemPoints);
            },
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
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
        ],
      ),
    );
  }
}

// ── Reusable icon button ──────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  const _IconButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: AppColors.chartFillBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _ClipboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);

    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Clipboard body
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 4, 12, 16),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, paint);

    // Clip at top
    final clip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(9, 2.5, 6, 3),
      const Radius.circular(0.8),
    );
    canvas.drawRRect(clip, paint);

    // Lines
    final lines = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(9, 11), const Offset(15, 11), lines);
    canvas.drawLine(const Offset(9, 14.5), const Offset(15, 14.5), lines);
    canvas.drawLine(const Offset(9, 18), const Offset(13, 18), lines);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ArrowUpRightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);

    final paint = Paint()
      ..color = AppColors.primaryBlue
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
  bool shouldRepaint(covariant CustomPainter _) => false;
}
