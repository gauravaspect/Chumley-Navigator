import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chumley_navigator/data/milestone_definitions.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';

Color tierColor(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:   return AppColors.tierBronze;
    case BadgeTier.silver:   return AppColors.tierSilver;
    case BadgeTier.gold:     return AppColors.tierGold;
    case BadgeTier.platinum: return AppColors.tierPlatinum;
    case BadgeTier.diamond:  return AppColors.tierDiamond;
    case BadgeTier.oneOff:   return AppColors.tierOneOff;
  }
}

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);
  final ValueNotifier<MilestoneCategory?> _selectedCategory = ValueNotifier(null);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  static double _easedCollapseProgress(double offset) {
    final raw = (offset / _scrollThreshold).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  void _onScroll() {
    final progress = _easedCollapseProgress(_scrollController.offset);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedCategory.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: _brandingExpandedHeight,
                    bottom: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SummaryBar(badges: allMilestoneBadges, theme: theme),
                      SizedBox(height: 14.h),
                      Text(
                        'YOUR BADGES',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap a category to filter',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _CategoryFilterStrip(selected: _selectedCategory, theme: theme),
                      SizedBox(height: 12.h),
                      ValueListenableBuilder<MilestoneCategory?>(
                        valueListenable: _selectedCategory,
                        builder: (context, selectedCat, _) {
                          final categoriesToRender = selectedCat == null
                              ? MilestoneCategory.values
                              : [selectedCat];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: categoriesToRender.asMap().entries.map((entry) {
                              final index = entry.key;
                              final cat = entry.value;
                              final catBadges = allMilestoneBadges.where((b) => b.category == cat).toList();
                              if (catBadges.isEmpty) return const SizedBox.shrink();

                              return FadeSlideIn(
                                delay: Duration(milliseconds: 40 * index),
                                child: _CategoryCard(
                                  category: cat,
                                  badges: catBadges,
                                  theme: theme,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _collapseProgress,
                  builder: (context, progress, _) {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AspectBranding(
                        progress: progress,
                        expandedHeight: _brandingExpandedHeight,
                        collapsedHeight: _brandingCollapsedHeight,
                        theme: theme,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;

  const _SummaryBar({required this.badges, required this.theme});

  @override
  Widget build(BuildContext context) {
    int unlockedCount = 0;
    final Set<MilestoneCategory> activeCategories = {};
    MilestoneBadge? nextUnlockBadge;
    double highestProgress = -1.0;

    for (final badge in badges) {
      if (badge.unlocked) {
        unlockedCount++;
        activeCategories.add(badge.category);
      } else {
        if (badge.progress > highestProgress) {
          highestProgress = badge.progress;
          nextUnlockBadge = badge;
        }
      }
    }

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.emoji_events_outlined,
            value: unlockedCount.toString(),
            label: 'Badges Earned',
            theme: theme,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatChip(
            icon: Icons.category_outlined,
            value: activeCategories.length.toString(),
            label: 'Categories Active',
            theme: theme,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatChip(
            icon: Icons.lock_open_outlined,
            value: nextUnlockBadge != null ? nextUnlockBadge.badgeName : 'All Done',
            label: 'Next Unlock',
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final DashboardTheme theme;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.text, size: 18.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: theme.text,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: theme.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterStrip extends StatelessWidget {
  final ValueNotifier<MilestoneCategory?> selected;
  final DashboardTheme theme;

  const _CategoryFilterStrip({required this.selected, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ValueListenableBuilder<MilestoneCategory?>(
        valueListenable: selected,
        builder: (context, selectedCat, _) {
          return Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: selectedCat == null,
                onTap: () => selected.value = null,
                theme: theme,
              ),
              ...MilestoneCategory.values.map((cat) {
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: _FilterChip(
                    label: categoryMeta[cat]!.label,
                    isSelected: selectedCat == cat,
                    onTap: () => selected.value = cat,
                    theme: theme,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final DashboardTheme theme;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (theme.isDark ? AppColors.kpiBarHigh : theme.accent)
        : theme.surface;
    final textColor = isSelected ? Colors.white : theme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MilestoneCategory category;
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;

  const _CategoryCard({
    required this.category,
    required this.badges,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta[category]!;
    final unlockedCount = badges.where((b) => b.unlocked).length;
    final totalCount = badges.length;
    
    MilestoneBadge? highestUnlocked;
    MilestoneBadge? nextToUnlock;
    
    for (final b in badges) {
      if (b.unlocked) {
        highestUnlocked = b;
      } else {
        if (nextToUnlock == null) {
          nextToUnlock = b;
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(meta.icon, color: theme.text, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ),
              if (highestUnlocked != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: tierColor(highestUnlocked.tier).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    highestUnlocked.badgeName,
                    style: TextStyle(
                      fontSize: 9.sp,
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
                  fontSize: 11.sp,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: badges.map((badge) {
              final isUnlocked = badge.unlocked;
              final color = tierColor(badge.tier);
              
              String tierName = badge.tier.name.toUpperCase();
              if (badge.tier == BadgeTier.oneOff) {
                tierName = 'DONE';
              }
              
              return Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked ? color : theme.surfaceDeep,
                      border: isUnlocked ? null : Border.all(color: color, width: 1),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tierName,
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: theme.textMuted,
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
                    color: theme.surfaceDeep,
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
                fontSize: 9.sp,
                color: theme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
