import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningCard extends StatelessWidget {
  const EarningCard({
    super.key,
    required this.user,
  });

  final UserModel user;

  double get _totalEarnings {
    final breakdown = user.performanceBreakdown;
    return breakdown.avgJobValue * breakdown.cases;
  }

  String get _earningsLabel {
    final amount = _totalEarnings;
    return '£${amount.toStringAsFixed(2)}';
  }

  bool get _hasRatingTrend => user.overallRating > 0;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: theme.dashCardDecoration(softBorder: true),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: theme.dashSubtitle,
                  ),
                ),
                SizedBox(height: 4.h),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 8 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _earningsLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.sp,
                      color: theme.dashTitle,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            if (_hasRatingTrend)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.dashSuccessBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: theme.dashSuccessFg,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        user.overallRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                          color: theme.dashSuccessFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
