import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneOverallCard extends StatelessWidget {
  final MilestonesResponse milestoneData;
  final DashboardTheme theme;

  const MilestoneOverallCard({
    super.key,
    required this.milestoneData,
    required this.theme,
  });

  Color _getMilestoneColor(String title) {
    switch (title.toLowerCase()) {
      case 'bronze':
        return AppColors.tierBronze;
      case 'silver':
        return AppColors.tierSilver;
      case 'gold':
        return AppColors.tierGold;
      case 'platinum':
        return AppColors.tierPlatinum;
      case 'diamond':
        return AppColors.tierDiamond;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestones = milestoneData.milestones;
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: theme.text, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Overall Tier Progression',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
              ),
              if (milestoneData.currentMilestone != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getMilestoneColor(
                      milestoneData.currentMilestone!.title,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    milestoneData.currentMilestone!.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _getMilestoneColor(
                        milestoneData.currentMilestone!.title,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 20.w,
                right: 20.w,
                child: Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: theme.surfaceDeep,
                    borderRadius: BorderRadius.circular(1.5.r),
                  ),
                ),
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int totalTiers = milestones.length;
                    int unlockedCount = milestones
                        .where((m) => m.isUnlocked)
                        .length;
                    double fraction = 0.0;
                    if (totalTiers > 1) {
                      fraction =
                          ((unlockedCount - 1).clamp(0, totalTiers - 1)) /
                          (totalTiers - 1);
                    }
                    final filledWidth = constraints.maxWidth * fraction;
                    Color activeLineColor = AppColors.primaryBlue;
                    if (milestoneData.currentMilestone != null) {
                      activeLineColor = _getMilestoneColor(
                        milestoneData.currentMilestone!.title,
                      );
                    }

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: filledWidth,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: activeLineColor,
                          borderRadius: BorderRadius.circular(1.5.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: milestones.map((item) {
                  final isUnlocked = item.isUnlocked;
                  final color = _getMilestoneColor(item.title);

                  return Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked ? color : theme.surface,
                      border: Border.all(
                        color: isUnlocked
                            ? color
                            : theme.textMuted.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 6.r,
                                spreadRadius: 1.r,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isUnlocked ? Icons.check : Icons.lock_outline,
                        size: 12.sp,
                        color: isUnlocked ? Colors.white : theme.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: milestones.map((item) {
              final isUnlocked = item.isUnlocked;
              return SizedBox(
                width: 64.w,
                child: Column(
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isUnlocked
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isUnlocked ? theme.text : theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${item.pointsRequired} XP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
