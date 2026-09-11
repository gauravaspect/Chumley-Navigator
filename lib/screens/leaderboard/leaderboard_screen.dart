import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_cubit.dart';
import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_state.dart';
import 'package:chumley_navigator/shimmers/leaderboard_shimmer.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardCubit _cubit;
  UserModel? _me;
  String _period = 'This month';

  @override
  void initState() {
    super.initState();
    _cubit = AppDependencies.createLeaderboardCubit()..load();
    Prefs.getUser().then((user) {
      if (!mounted) return;
      setState(() => _me = user);
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  LeaderboardResponse? _leaderboardFromState(LeaderboardState state) =>
      state.leaderboardOrNull;

  bool _isMe(LeaderboardUser user) {
    final me = _me;
    if (me == null) return false;
    final myName = me.name.trim().toLowerCase();
    if (myName.isEmpty) return false;
    return user.name.trim().toLowerCase() == myName;
  }

  LeaderboardUser? _byRank(List<LeaderboardUser> users, int rank) {
    for (final user in users) {
      if (user.rank == rank) return user;
    }
    return null;
  }

  LeaderboardUser? _myEntry(List<LeaderboardUser> users) {
    for (final user in users) {
      if (_isMe(user)) return user;
    }
    return null;
  }

  String _ordinal(int rank) {
    if (rank <= 0) return '—';
    if (rank % 100 >= 11 && rank % 100 <= 13) return '${rank}th';
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _firstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'Engineer';
  }

  int _deltaFor(int rank) => (rank % 3) + 1;

  Future<void> _pickPeriod() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        const options = ['This month', 'Last month', 'This quarter'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                ListTile(
                  title: Text(option),
                  trailing: option == _period
                      ? Icon(LucideIcons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _period = selected);
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
                final showShimmer =
                    state is LeaderboardInitial ||
                    (state is LeaderboardLoading && users.isEmpty);
                final me = _myEntry(users);
                final top1 = _byRank(users, 1);
                final top2 = _byRank(users, 2);
                final top3 = _byRank(users, 3);
                final ranking = users.where((u) => u.rank > 3).toList()
                  ..sort((a, b) => a.rank.compareTo(b.rank));

                return Scaffold(
                  backgroundColor: theme.base,
                  body: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: theme.isDark
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF4F9FF),
                                Color(0xFFEDF4FE),
                                Color(0xFFE2ECFA),
                              ],
                              stops: [0, 0.55, 1],
                            ),
                      color: theme.isDark ? theme.base : null,
                    ),
                    child: SafeArea(
                      child: RefreshIndicator(
                        color: theme.dashPrimary,
                        onRefresh: _cubit.refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                      color: theme.dashHeading,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _pickPeriod,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 9.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.dashPrimary,
                                      borderRadius: BorderRadius.circular(11.r),
                                    ),
                                    child: Text(
                                      _period,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            if (showShimmer)
                              LeaderboardShimmer(theme: theme)
                            else if (users.isEmpty)
                              _LeaderboardEmpty(theme: theme)
                            else ...[
                              if (me != null) ...[
                                FadeSlideIn(
                                  child: _StandingCard(
                                    theme: theme,
                                    ordinal: _ordinal(me.rank),
                                    delta: _deltaFor(me.rank),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                              ],
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 40),
                                child: _TopThreePodium(
                                  theme: theme,
                                  first: top1,
                                  second: top2,
                                  third: top3,
                                  initialsOf: _initials,
                                  firstNameOf: _firstName,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Full ranking',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: theme.dashHeading,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'KPI score',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w400,
                                      color: theme.dashMuted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              if (ranking.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Text(
                                    'No additional rankings yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.dashMuted,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: theme.dashCardDecoration(
                                    radius: 18,
                                  ),
                                  child: Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < ranking.length;
                                        i++
                                      ) ...[
                                        if (i > 0)
                                          Divider(
                                            height: 1,
                                            color: theme.dashBorderLight
                                                .withValues(alpha: 0.35),
                                          ),
                                        FadeSlideIn(
                                          delay: Duration(milliseconds: 30 * i),
                                          offsetY: 6,
                                          child: _RankRow(
                                            theme: theme,
                                            user: ranking[i],
                                            isMe: _isMe(ranking[i]),
                                            initials: _initials(
                                              ranking[i].name,
                                            ),
                                            delta: _deltaFor(ranking[i].rank),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
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
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: theme.dashMuted,
        ),
      ),
    );
  }
}

class _StandingCard extends StatelessWidget {
  const _StandingCard({
    required this.theme,
    required this.ordinal,
    required this.delta,
  });

  final DashboardTheme theme;
  final String ordinal;
  final int delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: theme.dashPrimary,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1F3A).withValues(alpha: 0.09),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18.r),
            ),
            alignment: Alignment.center,
            child: Text(
              ordinal,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "You're $ordinal this month",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F8EF),
                        borderRadius: BorderRadius.circular(500.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.arrowUp,
                            size: 10.sp,
                            color: const Color(0xFF15803D),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '$delta',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Keep going!',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  const _TopThreePodium({
    required this.theme,
    required this.first,
    required this.second,
    required this.third,
    required this.initialsOf,
    required this.firstNameOf,
  });

  final DashboardTheme theme;
  final LeaderboardUser? first;
  final LeaderboardUser? second;
  final LeaderboardUser? third;
  final String Function(String) initialsOf;
  final String Function(String) firstNameOf;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumPerson(
            theme: theme,
            user: second,
            place: 2,
            initialsOf: initialsOf,
            firstNameOf: firstNameOf,
            elevated: false,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _PodiumPerson(
            theme: theme,
            user: first,
            place: 1,
            initialsOf: initialsOf,
            firstNameOf: firstNameOf,
            elevated: true,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _PodiumPerson(
            theme: theme,
            user: third,
            place: 3,
            initialsOf: initialsOf,
            firstNameOf: firstNameOf,
            elevated: false,
          ),
        ),
      ],
    );
  }
}

class _PodiumPerson extends StatelessWidget {
  const _PodiumPerson({
    required this.theme,
    required this.user,
    required this.place,
    required this.initialsOf,
    required this.firstNameOf,
    required this.elevated,
  });

  final DashboardTheme theme;
  final LeaderboardUser? user;
  final int place;
  final String Function(String) initialsOf;
  final String Function(String) firstNameOf;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final name = user?.name.trim().isNotEmpty == true
        ? firstNameOf(user!.name)
        : '—';
    final score = user != null
        ? user!.performanceScore.toStringAsFixed(1)
        : '—';
    final initials = user != null ? initialsOf(user!.name) : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (elevated) ...[
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFD8E6FC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.award,
              size: 20.sp,
              color: theme.dashPrimary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          width: elevated ? 64.w : 52.w,
          height: elevated ? 64.w : 52.w,
          decoration: BoxDecoration(
            color: elevated
                ? theme.dashPrimary
                : (theme.isDark
                      ? theme.dashSurfaceTint
                      : const Color(0xFFE9EDF5)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              fontSize: elevated ? 18.sp : 14.sp,
              fontWeight: FontWeight.w700,
              color: elevated ? Colors.white : theme.dashSubtitle,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          score,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.dashMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: elevated
                ? AppColors.accentLime
                : (theme.isDark
                      ? theme.dashSurfaceTint
                      : const Color(0xFFE9EDF5)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            '$place',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: theme.dashTitle,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.theme,
    required this.user,
    required this.isMe,
    required this.initials,
    required this.delta,
  });

  final DashboardTheme theme;
  final LeaderboardUser user;
  final bool isMe;
  final String initials;
  final int delta;

  static String _cleanName(String raw) {
    return raw
        .replaceAll(RegExp(r'\s*[\(\[][A-Za-z0-9\s]+[\)\]]\s*$'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: isMe ? EdgeInsets.all(6.r) : EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: isMe ? 10.w : 14.w,
        vertical: 11.h,
      ),
      decoration: isMe
          ? BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFD8E6FC),
              borderRadius: BorderRadius.circular(14.r),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 22.w,
            child: Text(
              '${user.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isMe ? theme.dashPrimary : theme.dashMuted,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isMe
                  ? theme.dashPrimary
                  : (theme.isDark
                        ? theme.dashSurfaceTint
                        : const Color(0xFFE9EDF5)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: isMe ? Colors.white : theme.dashSubtitle,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _cleanName(user.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dashPrimary,
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Text(
                      'You',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.performanceScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isMe ? theme.dashPrimary : theme.dashTitle,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.arrowUp,
                    size: 11.sp,
                    color: const Color(0xFF15803D),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '$delta',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
