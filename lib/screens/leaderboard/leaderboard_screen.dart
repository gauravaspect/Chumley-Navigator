import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/shimmers/leaderboard_shimmer.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/podium_column.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _LeaderboardRow {
  const _LeaderboardRow({
    required this.rank,
    required this.engineer,
    required this.kpi,
  });

  final int rank;
  final String engineer;
  final double kpi;
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardCubit _cubit;

  final _scrollController = ScrollController();

  /// 0.0 = expanded, 1.0 = collapsed — updated every scroll frame.
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);

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
    _cubit = AppDependencies.createLeaderboardCubit()..load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _cubit.close();
    super.dispose();
  }

  LeaderboardResponse? _leaderboardFromState(LeaderboardState state) =>
      state.leaderboardOrNull;

  List<PodiumEntry> _podiumEntries(List<LeaderboardUser> users) {
    LeaderboardUser? byRank(int rank) {
      for (final user in users) {
        if (user.rank == rank) return user;
      }
      return null;
    }

    PodiumEntry entryFor(LeaderboardUser? user, String position) {
      if (user == null) {
        return PodiumEntry(
          firstName: '—',
          lastName: '',
          score: '—',
          position: position,
        );
      }

      final nameParts = user.name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      return PodiumEntry(
        firstName: nameParts.isNotEmpty ? nameParts.first : 'Engineer',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        score: user.performanceScore.toStringAsFixed(1),
        position: position,
      );
    }

    return [
      entryFor(byRank(2), '2nd'),
      entryFor(byRank(1), '1st'),
      entryFor(byRank(3), '3rd'),
    ];
  }

  List<_LeaderboardRow> _tableRows(List<LeaderboardUser> users) {
    final rows = users
        .where((user) => user.rank > 3)
        .map(
          (user) => _LeaderboardRow(
            rank: user.rank,
            engineer: user.name.trim().isEmpty ? 'Engineer' : user.name.trim(),
            kpi: user.performanceScore,
          ),
        )
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));

    return rows;
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
            child: BlocConsumer<LeaderboardCubit, LeaderboardState>(
              listener: (context, state) {
                if (state is LeaderboardError &&
                    state.cachedLeaderboard == null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final leaderboard = _leaderboardFromState(state);
                final users = leaderboard?.users ?? const <LeaderboardUser>[];
                final showShimmer = state is LeaderboardInitial ||
                    (state is LeaderboardLoading && users.isEmpty);
                final isStale = leaderboard?.stale ?? false;
                final tableRows = _tableRows(users);

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
                              bottom: 112.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 14.h),
                                ValueListenableBuilder<double>(
                                  valueListenable: _collapseProgress,
                                  builder: (context, progress, _) {
                                    return Opacity(
                                      opacity: (1.0 - progress).clamp(0.0, 1.0),
                                      child: Text(
                                        'Engineer leaderboard',
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
                                if (isStale) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Showing cached data',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textMuted,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 14.h),
                                  if (showShimmer)
                                    LeaderboardShimmer(theme: theme)
                                  else if (users.isEmpty)
                                    _LeaderboardEmpty(theme: theme)
                                  else ...[
                                      FadeSlideIn(
                                        child: _PodiumCard(
                                          theme: theme,
                                          entries: _podiumEntries(users),
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      _LeaderboardHeader(theme: theme),
                                      SizedBox(height: 6.h),
                                      if (tableRows.isEmpty)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16.h,
                                          ),
                                          child: Text(
                                            'No additional rankings yet.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: theme.textMuted,
                                            ),
                                          ),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                          const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: tableRows.length,
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 6.h),
                                          itemBuilder: (context, index) {
                                            final row = tableRows[index];
                                            return FadeSlideIn(
                                              delay: Duration(
                                                milliseconds: 35 * index,
                                              ),
                                              offsetY: 8,
                                              child: _LeaderboardRowTile(
                                                theme: theme,
                                                row: row,
                                              ),
                                            );
                                          },
                                        ),
                                    ],
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
                              ),
                            );
                          },
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

class _LeaderboardEmpty extends StatelessWidget {
  const _LeaderboardEmpty({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Text(
        'No leaderboard data available.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: theme.textMuted,
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.theme,
    required this.entries,
  });

  final DashboardTheme theme;
  final List<PodiumEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        top: 14.h,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: PodiumColumn(entry: entries[0])),
          SizedBox(width: 6.w),
          Expanded(child: PodiumColumn(entry: entries[1])),
          SizedBox(width: 6.w),
          Expanded(child: PodiumColumn(entry: entries[2])),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _headerCell('Rank', width: 28.w, align: TextAlign.center),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: _headerCell('Engineer', align: TextAlign.left),
            ),
          ),
          _headerCell('Score', width: 80.w, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    double? width,
    required TextAlign align,
  }) {
    final style = TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: theme.textMuted,
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: Text(text, textAlign: align, style: style),
      );
    }
    return Text(text, textAlign: align, style: style);
  }
}

class _LeaderboardRowTile extends StatelessWidget {
  const _LeaderboardRowTile({
    required this.theme,
    required this.row,
  });

  final DashboardTheme theme;
  final _LeaderboardRow row;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rank ${row.rank}, ${row.engineer}, score ${row.kpi}',
      child: PressableScale(
        onTap: () {},
        scale: 0.99,
        child: Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(
                  '${row.rank}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    row.engineer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.text,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100.w,
                child: _KpiCell(theme: theme, kpi: row.kpi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.theme,
    required this.kpi,
  });

  final DashboardTheme theme;
  final double kpi;

  @override
  Widget build(BuildContext context) {
    final fill = kpi >= 56 ? theme.kpiBarHighColor : AppColors.kpiBarLow;
    final progress = (kpi / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: SizedBox(
              height: 3.h,
              child: ColoredBox(
                color: theme.progressTrack,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: ColoredBox(color: fill),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        SizedBox(
          width: 28.w,
          child: Text(
            kpi.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
