import 'package:chumley_navigator/data/milestone_definitions.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color tierColor(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return AppColors.tierBronze;
    case BadgeTier.silver:
      return AppColors.tierSilver;
    case BadgeTier.gold:
      return AppColors.tierGold;
    case BadgeTier.platinum:
      return AppColors.tierPlatinum;
    case BadgeTier.diamond:
      return AppColors.tierDiamond;
    case BadgeTier.oneOff:
      return AppColors.tierOneOff;
  }
}

class MilestoneCategoryCard extends StatefulWidget {
  final MilestoneCategory category;
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;
  final String? Function(MilestoneBadge) getButtonLabel;
  final void Function(MilestoneBadge) onClaim;

  const MilestoneCategoryCard({
    super.key,
    required this.category,
    required this.badges,
    required this.theme,
    required this.getButtonLabel,
    required this.onClaim,
  });

  @override
  State<MilestoneCategoryCard> createState() => MilestoneCategoryCardState();
}

class MilestoneCategoryCardState extends State<MilestoneCategoryCard>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _dotControllers = {};
  final ValueNotifier<bool> _justUnlocked = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    for (final badge in widget.badges) {
      _dotControllers[badge.id] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
        value: badge.unlocked ? 1.0 : 0.0,
      );
    }
  }

  @override
  void didUpdateWidget(covariant MilestoneCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final badge in widget.badges) {
      if (!_dotControllers.containsKey(badge.id)) {
        _dotControllers[badge.id] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
          value: badge.unlocked ? 1.0 : 0.0,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _dotControllers.values) {
      controller.dispose();
    }
    _justUnlocked.dispose();
    super.dispose();
  }

  void triggerDotAnimation(MilestoneBadge badge) {
    _dotControllers[badge.id]?.forward(from: 0.0);
  }

  void triggerFlash() {
    _justUnlocked.value = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _justUnlocked.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta[widget.category]!;
    final unlockedCount = widget.badges.where((b) => b.unlocked).length;
    final totalCount = widget.badges.length;

    MilestoneBadge? highestUnlocked;
    MilestoneBadge? nextToUnlock;

    for (final b in widget.badges) {
      if (b.unlocked) {
        highestUnlocked = b;
      } else {
        nextToUnlock ??= b;
      }
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _justUnlocked,
      builder: (context, justUnlockedVal, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.theme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: justUnlockedVal
                  ? AppColors.tierGold.withValues(alpha: 0.7)
                  : widget.theme.surfaceDeep.withValues(alpha: 0),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(meta.icon, color: widget.theme.text, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      meta.label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: widget.theme.text,
                      ),
                    ),
                  ),
                  if (highestUnlocked != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: tierColor(
                          highestUnlocked.tier,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        highestUnlocked.badgeName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: tierColor(highestUnlocked.tier),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    '$unlockedCount / $totalCount',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: widget.theme.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.badges.map((badge) {
                  final isUnlocked = badge.unlocked;
                  final color = tierColor(badge.tier);

                  String tierName = badge.tier.name.toUpperCase();
                  if (badge.tier == BadgeTier.oneOff) {
                    tierName = 'DONE';
                  }

                  final controller = _dotControllers[badge.id];

                  Widget dot = Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked ? color : Colors.transparent,
                      border: isUnlocked
                          ? null
                          : Border.all(color: color, width: 1.5),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 6.r,
                                spreadRadius: 1.r,
                              ),
                            ]
                          : null,
                    ),
                  );

                  if (controller != null) {
                    dot = ScaleTransition(
                      scale: CurvedAnimation(
                        parent: controller,
                        curve: const ElasticOutCurve(0.8),
                      ),
                      child: dot,
                    );
                  }

                  return Column(
                    children: [
                      dot,
                      SizedBox(height: 4.h),
                      Text(
                        tierName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: widget.theme.textMuted,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              if (nextToUnlock != null) ...[
                SizedBox(height: 12.h),
                Stack(
                  children: [
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: widget.theme.surfaceDeep,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: nextToUnlock.progress,
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: tierColor(nextToUnlock.tier),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${nextToUnlock.currentValue ?? 0} / ${nextToUnlock.threshold} ${nextToUnlock.unit}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: widget.theme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                Builder(
                  builder: (context) {
                    final nextBadge = nextToUnlock!;
                    final label = widget.getButtonLabel(nextBadge);
                    if (label == null) return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36.h,
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onClaim(nextBadge);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.kpiBarHigh,
                              width: 1,
                            ),
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.kpiBarHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
