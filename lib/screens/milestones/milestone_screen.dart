import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chumley_navigator/data/milestone_definitions.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:confetti/confetti.dart';
import 'package:chumley_navigator/widgets/ui/celebration_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/screens/milestones/cubit/milestones_cubit.dart';
import 'package:chumley_navigator/screens/milestones/cubit/milestones_state.dart';
import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:chumley_navigator/shimmers/shimmer_box.dart';

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

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);
  final ValueNotifier<MilestoneCategory?> _selectedCategory = ValueNotifier(
    null,
  );

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  final ValueNotifier<int> _totalXP = ValueNotifier(2450);

  late ConfettiController _confettiController;
  final ValueNotifier<bool> _flashActive = ValueNotifier(false);
  BadgeTier? _lastUnlockedTier;

  final Map<MilestoneCategory, GlobalKey<_CategoryCardState>> _cardKeys = {};

  static const Map<BadgeTier, int> _tierXP = {
    BadgeTier.bronze: 150,
    BadgeTier.silver: 300,
    BadgeTier.gold: 600,
    BadgeTier.platinum: 1000,
    BadgeTier.diamond: 2000,
    BadgeTier.oneOff: 500,
  };

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

  void _addXP(int amount) {
    _totalXP.value += amount;
    if (amount >= 300) {
      _triggerScreenFlash();
    }
  }

  void _triggerScreenFlash() {
    _flashActive.value = true;
    Future.delayed(const Duration(milliseconds: 180), () {
      _flashActive.value = false;
    });
  }

  void _triggerDotAnimation(MilestoneBadge badge) {
    _cardKeys[badge.category]?.currentState?.triggerDotAnimation(badge);
  }

  void _triggerCardFlash(MilestoneCategory category) {
    _cardKeys[category]?.currentState?.triggerFlash();
  }

  String? _getButtonLabel(MilestoneBadge badge) {
    if (badge.progress >= 1.0 && !badge.unlocked) {
      return "Claim Badge!";
    }
    return null;
  }

  void _onClaim(MilestoneBadge badge) {
    setState(() {
      badge.unlocked = true;
      _lastUnlockedTier = badge.tier;
    });
    _addXP(_tierXP[badge.tier] ?? 500);
    _showCelebration(badge);
  }

  void _showCelebration(MilestoneBadge badge) {
    _confettiController.play();
    final theme = DashboardTheme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Celebration",
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, anim, secondaryAnim) => CelebrationCard(
        badge: badge,
        theme: theme,
        onClaim: () {
          Navigator.of(ctx).pop();
          _triggerDotAnimation(badge);
          _triggerCardFlash(badge.category);
          _triggerScreenFlash();
        },
      ),
    );
  }



  late final MilestonesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _cubit = AppDependencies.createMilestonesCubit()..load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedCategory.dispose();
    _collapseProgress.dispose();
    _totalXP.dispose();
    _confettiController.dispose();
    _flashActive.dispose();
    _cubit.close();
    super.dispose();
  }

  String _formatNumber(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ListenableBuilder(
        listenable: ThemeScope.of(context),
        builder: (context, _) {
          final theme = DashboardTheme.of(context);

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primaryBlue,
                secondary: AppColors.accentBlue,
              ),
            ),
            child: BlocConsumer<MilestonesCubit, MilestonesState>(
              listener: (context, state) {
                if (state is MilestonesError && state.cachedMilestones == null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
                final data = state.milestonesOrNull;
                if (data != null) {
                  _totalXP.value = data.currentPoints;
                }
              },
              builder: (context, state) {
                final milestoneData = state.milestonesOrNull;
                final showShimmer = state is MilestonesInitial ||
                    (state is MilestonesLoading && milestoneData == null);

                if (showShimmer) {
                  return Scaffold(
                    backgroundColor: theme.base,
                    body: SafeArea(
                      child: Stack(
                        children: [
                          _MilestoneScreenShimmer(theme: theme),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AspectBranding(
                              progress: 0.0,
                              expandedHeight: _brandingExpandedHeight,
                              collapsedHeight: _brandingCollapsedHeight,
                              theme: theme,
                              title: Text(
                                'Milestones',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: theme.textBody,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Scaffold(
                  backgroundColor: theme.base,
                  body: SafeArea(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          color: theme.dashPrimary,
                          onRefresh: _cubit.refresh,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: _brandingExpandedHeight + 28,
                              bottom: 24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ValueListenableBuilder<double>(
                                  valueListenable: _collapseProgress,
                                  builder: (context, progress, _) {
                                    return Opacity(
                                      opacity: (1.0 - progress).clamp(0.0, 1.0),
                                      child: Text(
                                        'Milestones',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.6,
                                          color: theme.textBody,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 14.h),
                                _SummaryBar(badges: allMilestoneBadges, theme: theme),
                                SizedBox(height: 14.h),
                                if (milestoneData != null)
                                  _OverallMilestonesCard(
                                    milestoneData: milestoneData,
                                    theme: theme,
                                  ),
                                Text(
                                  'YOUR BADGES',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: theme.textMuted,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Tap a category to filter',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textMuted,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _CategoryFilterStrip(
                                  selected: _selectedCategory,
                                  theme: theme,
                                ),
                                SizedBox(height: 12.h),
                                ValueListenableBuilder<MilestoneCategory?>(
                                  valueListenable: _selectedCategory,
                                  builder: (context, selectedCat, _) {
                                    final categoriesToRender = selectedCat == null
                                        ? MilestoneCategory.values
                                        : [selectedCat];

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: categoriesToRender.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final cat = entry.value;
                                        final catBadges = allMilestoneBadges
                                            .where((b) => b.category == cat)
                                            .toList();
                                        if (catBadges.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return FadeSlideIn(
                                          delay: Duration(milliseconds: 40 * index),
                                          child: _CategoryCard(
                                            key: _cardKeys.putIfAbsent(
                                              cat,
                                              () => GlobalKey<_CategoryCardState>(),
                                            ),
                                            category: cat,
                                            badges: catBadges,
                                            theme: theme,
                                            getButtonLabel: _getButtonLabel,
                                            onClaim: _onClaim,
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
                                title: Text(
                                  'Milestones',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: theme.textBody,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // XP Bar Positioned
                        ValueListenableBuilder<double>(
                          valueListenable: _collapseProgress,
                          builder: (context, progress, _) {
                            final topOffset = _brandingExpandedHeight -
                                (_brandingExpandedHeight - _brandingCollapsedHeight) *
                                    progress;
                            return Positioned(
                              top: topOffset,
                              left: 0,
                              right: 0,
                              child: ValueListenableBuilder<int>(
                                valueListenable: _totalXP,
                                builder: (context, totalXpValue, _) {
                                  final nextMilestone = milestoneData?.nextMilestone;
                                  final target = nextMilestone?.pointsRequired ?? milestoneData?.currentMilestone?.pointsRequired ?? 1000;
                                  final double progressFraction = target > 0 ? (totalXpValue / target).clamp(0.0, 1.0) : 1.0;

                                  return Container(
                                    height: 20.h,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    color: theme.base,
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 3.h,
                                            decoration: BoxDecoration(
                                              color: theme.surfaceDeep,
                                              borderRadius: BorderRadius.circular(1.5.r),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(
                                                begin: 0.0,
                                                end: progressFraction,
                                              ),
                                              duration: const Duration(milliseconds: 1400),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, val, child) {
                                                return FractionallySizedBox(
                                                  alignment: Alignment.centerLeft,
                                                  widthFactor: val,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors.kpiBarHigh,
                                                          Color(0xFFFBBF24),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0.0,
                                            end: totalXpValue.toDouble(),
                                          ),
                                          duration: const Duration(milliseconds: 1400),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, animValue, _) {
                                            final formatted = animValue
                                                .round()
                                                .toString()
                                                .replaceAllMapped(
                                                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                                  (Match m) => '${m[1]},',
                                                );
                                            final targetStr = nextMilestone != null
                                                ? '${_formatNumber(target)} XP'
                                                : 'Max Level';
                                            return Text(
                                              '$formatted / $targetStr',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: theme.textMuted,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Screen Flash overlay
                        ValueListenableBuilder<bool>(
                          valueListenable: _flashActive,
                          builder: (context, active, child) => IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: active ? 0.12 : 0.0,
                              duration: Duration(milliseconds: active ? 80 : 400),
                              child: Container(color: AppColors.kpiBarHigh),
                            ),
                          ),
                        ),
                        // Confetti overlay
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            numberOfParticles: 30,
                            colors: [
                              AppColors.kpiBarHigh,
                              tierColor(_lastUnlockedTier ?? BadgeTier.gold),
                              const Color(0xFFF5C842),
                              Colors.white,
                              const Color(0xFFC084FC),
                            ],
                            gravity: 0.25,
                            emissionFrequency: 0.04,
                            minBlastForce: 5,
                            maxBlastForce: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBar extends StatefulWidget {
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;

  const _SummaryBar({required this.badges, required this.theme});

  @override
  State<_SummaryBar> createState() => _SummaryBarState();
}

class _SummaryBarState extends State<_SummaryBar> {
  final List<ValueNotifier<double>> _pulses = [
    ValueNotifier(0.0),
    ValueNotifier(0.0),
    ValueNotifier(0.0),
  ];

  int _prevUnlockedCount = 0;
  int _prevActiveCategoriesCount = 0;

  @override
  void initState() {
    super.initState();
    _prevUnlockedCount = widget.badges.where((b) => b.unlocked).length;
    final Set<MilestoneCategory> activeCategories = {};
    for (final b in widget.badges) {
      if (b.unlocked) activeCategories.add(b.category);
    }
    _prevActiveCategoriesCount = activeCategories.length;
  }

  @override
  void didUpdateWidget(covariant _SummaryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    int unlockedCount = 0;
    final Set<MilestoneCategory> activeCategories = {};
    for (final b in widget.badges) {
      if (b.unlocked) {
        unlockedCount++;
        activeCategories.add(b.category);
      }
    }
    if (unlockedCount > _prevUnlockedCount) {
      _triggerPulse(0);
      _prevUnlockedCount = unlockedCount;
    }
    if (activeCategories.length > _prevActiveCategoriesCount) {
      _triggerPulse(1);
      _prevActiveCategoriesCount = activeCategories.length;
    }
  }

  void _triggerPulse(int index) {
    _pulses[index].value = 1.0;
  }

  @override
  void dispose() {
    for (final p in _pulses) {
      p.dispose();
    }
    super.dispose();
  }

  Widget _buildChip(int index, String label, String value, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _triggerPulse(index),
        child: ValueListenableBuilder<double>(
          valueListenable: _pulses[index],
          builder: (context, pulseVal, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: pulseVal),
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                if (pulseVal == 1.0) {
                  _pulses[index].value = 0.0;
                }
              },
              builder: (context, opacity, child) {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: widget.theme.text, size: 18.sp),
                          SizedBox(height: 4.h),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.text,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: widget.theme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              gradient: RadialGradient(
                                center: Alignment.topCenter,
                                radius: 1.0,
                                colors: [
                                  AppColors.kpiBarHigh.withOpacity(0.4),
                                  AppColors.kpiBarHigh.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int unlockedCount = 0;
    final Set<MilestoneCategory> activeCategories = {};
    for (final badge in widget.badges) {
      if (badge.unlocked) {
        unlockedCount++;
        activeCategories.add(badge.category);
      }
    }

    return Row(
      children: [
        _buildChip(
          0,
          'Badges Earned',
          unlockedCount.toString(),
          Icons.emoji_events_outlined,
        ),
        SizedBox(width: 8.w),
        _buildChip(
          1,
          'Categories Active',
          activeCategories.length.toString(),
          Icons.category_outlined,
        ),
        SizedBox(width: 8.w),
        _buildChip(2, 'Day Streak', '14', Icons.local_fire_department_outlined),
      ],
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
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(17.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final MilestoneCategory category;
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;
  final String? Function(MilestoneBadge) getButtonLabel;
  final void Function(MilestoneBadge) onClaim;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.badges,
    required this.theme,
    required this.getButtonLabel,
    required this.onClaim,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
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
  void didUpdateWidget(covariant _CategoryCard oldWidget) {
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
                  ? AppColors.tierGold.withOpacity(.7)
                  : widget.theme.surfaceDeep.withOpacity(0),
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
                        ).withOpacity(0.15),
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
                                color: color.withOpacity(.5),
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

class _OverallMilestonesCard extends StatelessWidget {
  final MilestonesResponse milestoneData;
  final DashboardTheme theme;

  const _OverallMilestonesCard({required this.milestoneData, required this.theme});

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
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getMilestoneColor(milestoneData.currentMilestone!.title).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    milestoneData.currentMilestone!.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _getMilestoneColor(milestoneData.currentMilestone!.title),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          // Step progression line & nodes
          Stack(
            alignment: Alignment.center,
            children: [
              // The line behind dots
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
              // The active line
              Positioned(
                left: 20.w,
                right: 20.w,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate fraction of line filled
                    int totalTiers = milestones.length;
                    int unlockedCount = milestones.where((m) => m.isUnlocked).length;
                    double fraction = 0.0;
                    if (totalTiers > 1) {
                      fraction = ((unlockedCount - 1).clamp(0, totalTiers - 1)) / (totalTiers - 1);
                    }
                    final filledWidth = constraints.maxWidth * fraction;
                    Color activeLineColor = AppColors.primaryBlue;
                    if (milestoneData.currentMilestone != null) {
                      activeLineColor = _getMilestoneColor(milestoneData.currentMilestone!.title);
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
              // The node row
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
                        color: isUnlocked ? color : theme.textMuted.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: color.withOpacity(.3),
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
          // Labels
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
                        fontWeight: isUnlocked ? FontWeight.w700 : FontWeight.w500,
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

class _MilestoneScreenShimmer extends StatelessWidget {
  final DashboardTheme theme;
  const _MilestoneScreenShimmer({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 72 + 28, // _brandingExpandedHeight + 28
        bottom: 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemedShimmerBox(theme: theme, height: 22.h, width: 120.w),
          SizedBox(height: 14.h),
          // Summary bar shimmer
          Row(
            children: [
              Expanded(child: ThemedShimmerBox(theme: theme, height: 74.h)),
              SizedBox(width: 8.w),
              Expanded(child: ThemedShimmerBox(theme: theme, height: 74.h)),
              SizedBox(width: 8.w),
              Expanded(child: ThemedShimmerBox(theme: theme, height: 74.h)),
            ],
          ),
          SizedBox(height: 14.h),
          // Overall progression card shimmer
          ThemedShimmerBox(theme: theme, height: 120.h),
          SizedBox(height: 14.h),
          // YOUR BADGES title and subtitle shimmer
          ThemedShimmerBox(theme: theme, height: 18.h, width: 100.w),
          SizedBox(height: 4.h),
          ThemedShimmerBox(theme: theme, height: 14.h, width: 150.w),
          SizedBox(height: 8.h),
          // Category filter strip shimmer
          Row(
            children: [
              ThemedShimmerBox(theme: theme, height: 34.h, width: 60.w, radius: 17),
              SizedBox(width: 8.w),
              ThemedShimmerBox(theme: theme, height: 34.h, width: 80.w, radius: 17),
              SizedBox(width: 8.w),
              ThemedShimmerBox(theme: theme, height: 34.h, width: 80.w, radius: 17),
              SizedBox(width: 8.w),
              ThemedShimmerBox(theme: theme, height: 34.h, width: 80.w, radius: 17),
            ],
          ),
          SizedBox(height: 12.h),
          // Category cards shimmers
          ThemedShimmerBox(theme: theme, height: 160.h),
          SizedBox(height: 10.h),
          ThemedShimmerBox(theme: theme, height: 160.h),
        ],
      ),
    );
  }
}
