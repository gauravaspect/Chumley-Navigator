import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color _tierColor(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:   return AppColors.tierBronze;
    case BadgeTier.silver:   return AppColors.tierSilver;
    case BadgeTier.gold:     return AppColors.tierGold;
    case BadgeTier.platinum: return AppColors.tierPlatinum;
    case BadgeTier.diamond:  return AppColors.tierDiamond;
    case BadgeTier.oneOff:   return AppColors.tierOneOff;
  }
}

String _tierEmoji(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:   return '🥉';
    case BadgeTier.silver:   return '🥈';
    case BadgeTier.gold:     return '🥇';
    case BadgeTier.platinum: return '🏆';
    case BadgeTier.diamond:  return '💎';
    case BadgeTier.oneOff:   return '⭐';
  }
}

const Map<BadgeTier, int> _tierXP = {
  BadgeTier.bronze: 150,
  BadgeTier.silver: 300,
  BadgeTier.gold: 600,
  BadgeTier.platinum: 1000,
  BadgeTier.diamond: 2000,
  BadgeTier.oneOff: 500,
};

class CelebrationCard extends StatefulWidget {
  final MilestoneBadge badge;
  final DashboardTheme theme;
  final VoidCallback onClaim;

  const CelebrationCard({
    super.key,
    required this.badge,
    required this.theme,
    required this.onClaim,
  });

  @override
  State<CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<CelebrationCard> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  late AnimationController _xpController;
  late Animation<double> _xpScaleAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _iconController,
      curve: const ElasticOutCurve(0.8),
    );
    _rotationAnimation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const ElasticOutCurve(0.8),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _iconController.forward();
      }
    });

    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _xpScaleAnimation = CurvedAnimation(
      parent: _xpController,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _xpController.forward();
      }
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tColor = _tierColor(widget.badge.tier);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: tColor.withOpacity(0.25),
                blurRadius: 30.r,
                spreadRadius: 12.r,
              ),
            ],
          ),
          child: Container(
            width: 300.w,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 22.h),
            decoration: BoxDecoration(
              color: widget.theme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: tColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Text(
                      _tierEmoji(widget.badge.tier),
                      style: TextStyle(fontSize: 52.sp),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  widget.badge.tier.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: tColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.badge.badgeName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.theme.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Achievement Unlocked!",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: widget.theme.textMuted,
                  ),
                ),
                SizedBox(height: 16.h),
                ScaleTransition(
                  scale: _xpScaleAnimation,
                  child: Text(
                    "+${_tierXP[widget.badge.tier]} XP",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kpiBarHigh,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kpiBarHigh,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      "Claim Reward",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
