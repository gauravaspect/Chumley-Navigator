import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/data/milestone_definitions.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:chumley_navigator/screens/milestones/cubit/milestones_cubit.dart';
import 'package:chumley_navigator/screens/milestones/cubit/milestones_state.dart';
import 'package:chumley_navigator/screens/milestones/widgets/milestone_category_card.dart';
import 'package:chumley_navigator/screens/milestones/widgets/milestone_category_filter_strip.dart';
import 'package:chumley_navigator/screens/milestones/widgets/milestone_overall_card.dart';
import 'package:chumley_navigator/screens/milestones/widgets/milestone_screen_shimmer.dart';
import 'package:chumley_navigator/screens/milestones/widgets/milestone_summary_bar.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/celebration_card.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  final Map<MilestoneCategory, GlobalKey<MilestoneCategoryCardState>>
  _cardKeys = {};

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
      barrierColor: Colors.black.withValues(alpha: 0.65),
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
                if (state is MilestonesError &&
                    state.cachedMilestones == null) {
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
                final showShimmer =
                    state is MilestonesInitial ||
                    (state is MilestonesLoading && milestoneData == null);

                if (showShimmer) {
                  return Scaffold(
                    backgroundColor: theme.base,
                    body: SafeArea(
                      child: Stack(
                        children: [
                          MilestoneScreenShimmer(theme: theme),
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
                                MilestoneSummaryBar(
                                  badges: allMilestoneBadges,
                                  theme: theme,
                                ),
                                SizedBox(height: 14.h),
                                if (milestoneData != null)
                                  MilestoneOverallCard(
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
                                MilestoneCategoryFilterStrip(
                                  selected: _selectedCategory,
                                  theme: theme,
                                ),
                                SizedBox(height: 12.h),
                                ValueListenableBuilder<MilestoneCategory?>(
                                  valueListenable: _selectedCategory,
                                  builder: (context, selectedCat, _) {
                                    final categoriesToRender =
                                        selectedCat == null
                                        ? MilestoneCategory.values
                                        : [selectedCat];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: categoriesToRender
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final cat = entry.value;
                                            final catBadges = allMilestoneBadges
                                                .where((b) => b.category == cat)
                                                .toList();
                                            if (catBadges.isEmpty) {
                                              return const SizedBox.shrink();
                                            }

                                            return FadeSlideIn(
                                              delay: Duration(
                                                milliseconds: 40 * index,
                                              ),
                                              child: MilestoneCategoryCard(
                                                key: _cardKeys.putIfAbsent(
                                                  cat,
                                                  () =>
                                                      GlobalKey<
                                                        MilestoneCategoryCardState
                                                      >(),
                                                ),
                                                category: cat,
                                                badges: catBadges,
                                                theme: theme,
                                                getButtonLabel: _getButtonLabel,
                                                onClaim: _onClaim,
                                              ),
                                            );
                                          })
                                          .toList(),
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
                            final topOffset =
                                _brandingExpandedHeight -
                                (_brandingExpandedHeight -
                                        _brandingCollapsedHeight) *
                                    progress;
                            return Positioned(
                              top: topOffset,
                              left: 0,
                              right: 0,
                              child: ValueListenableBuilder<int>(
                                valueListenable: _totalXP,
                                builder: (context, totalXpValue, _) {
                                  final nextMilestone =
                                      milestoneData?.nextMilestone;
                                  final target =
                                      nextMilestone?.pointsRequired ??
                                      milestoneData
                                          ?.currentMilestone
                                          ?.pointsRequired ??
                                      1000;
                                  final double progressFraction = target > 0
                                      ? (totalXpValue / target).clamp(0.0, 1.0)
                                      : 1.0;

                                  return Container(
                                    height: 20.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    color: theme.base,
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 3.h,
                                            decoration: BoxDecoration(
                                              color: theme.surfaceDeep,
                                              borderRadius:
                                                  BorderRadius.circular(1.5.r),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(
                                                begin: 0.0,
                                                end: progressFraction,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 1400,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, val, child) {
                                                return FractionallySizedBox(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  widthFactor: val,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  AppColors
                                                                      .kpiBarHigh,
                                                                  Color(
                                                                    0xFFFBBF24,
                                                                  ),
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
                                          duration: const Duration(
                                            milliseconds: 1400,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, animValue, _) {
                                            final formatted = animValue
                                                .round()
                                                .toString()
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d)(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                );
                                            final targetStr =
                                                nextMilestone != null
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
                              duration: Duration(
                                milliseconds: active ? 80 : 400,
                              ),
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
