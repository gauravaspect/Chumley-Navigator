import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/podium_column.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _LeaderboardRow {
  const _LeaderboardRow({
    required this.rank,
    required this.trend,
    required this.engineer,
    required this.kpi,
  });
  final int rank;
  final int trend;
  final String engineer;
  final double kpi;
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _podium = [
    PodiumEntry(
      firstName: 'Marcus',
      lastName: 'Whitfield',
      score: '75.9',
      position: '2nd',
    ),
    PodiumEntry(
      firstName: 'James',
      lastName: 'Hargreaves',
      score: '78.4',
      position: '1st',
    ),
    PodiumEntry(
      firstName: 'Daniel',
      lastName: 'Ashford',
      score: '73.2',
      position: '3rd',
    ),
  ];

  static const _rows = [
    _LeaderboardRow(rank: 4, trend: 3, engineer: 'Oliver Pendleton', kpi: 70.6),
    _LeaderboardRow(rank: 5, trend: 0, engineer: 'Harvey Trenton', kpi: 68.1),
    _LeaderboardRow(rank: 6, trend: -2, engineer: 'Connor Whitlock', kpi: 65.7),
    _LeaderboardRow(rank: 7, trend: 1, engineer: 'Aiden Marsh', kpi: 63.4),
    _LeaderboardRow(rank: 8, trend: -1, engineer: 'Felix Donovan', kpi: 61.0),
    _LeaderboardRow(rank: 9, trend: 2, engineer: 'Theo Blakemore', kpi: 58.8),
    _LeaderboardRow(rank: 10, trend: 0, engineer: 'Reuben Carlisle', kpi: 56.3),
    _LeaderboardRow(rank: 11, trend: -3, engineer: 'Joel Hawthorne', kpi: 53.9),
    _LeaderboardRow(rank: 12, trend: 1, engineer: 'Nathan Vickers', kpi: 51.2),
    _LeaderboardRow(rank: 13, trend: -1, engineer: 'Eli Brookfield', kpi: 48.7),
    _LeaderboardRow(rank: 14, trend: 2, engineer: 'Caleb Sherwood', kpi: 45.5),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectBranding(),
                    SizedBox(height: 14.h),
                    Text(
                      'Electrician leaderboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    FadeSlideIn(
                      child: _PodiumCard(
                        theme: theme,
                        entries: _podium,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _LeaderboardHeader(theme: theme),
                    SizedBox(height: 6.h),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _rows.length,
                      separatorBuilder: (_, index) => SizedBox(height: 6.h),
                      itemBuilder: (_, index) => FadeSlideIn(
                        delay: Duration(milliseconds: 35 * index),
                        offsetY: 8,
                        child: _LeaderboardRowTile(
                          theme: theme,
                          row: _rows[index],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _headerCell('Rank', width: 24.w, align: TextAlign.center),
          _headerCell('Trend', width: 40.w, align: TextAlign.center),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _headerCell('Engineer', align: TextAlign.left),
            ),
          ),
          _headerCell('KPI', width: 80.w, align: TextAlign.right),
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
      label: 'Rank ${row.rank}, ${row.engineer}, KPI ${row.kpi}',
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
              SizedBox(
                width: 40.w,
                child: _TrendCell(theme: theme, trend: row.trend),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
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
                width: 80.w,
                child: _KpiCell(theme: theme, kpi: row.kpi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendCell extends StatelessWidget {
  const _TrendCell({
    required this.theme,
    required this.trend,
  });

  final DashboardTheme theme;
  final int trend;

  Color get _color {
    if (trend > 0) {
      return theme.isDark ? AppColors.kpiBarHigh : AppColors.trendUpLight;
    }
    if (trend < 0) {
      return theme.isDark ? AppColors.streakOrange : AppColors.trendDownLight;
    }
    return theme.textMuted;
  }

  IconData get _icon {
    if (trend > 0) return Icons.arrow_upward_rounded;
    if (trend < 0) return Icons.arrow_downward_rounded;
    return Icons.remove_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 10.sp, color: color),
        if (trend != 0) ...[
          SizedBox(width: 2.w),
          Text(
            '${trend.abs()}',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ],
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
    final fill = kpi >= 56
        ? theme.kpiBarHighColor
        : AppColors.kpiBarLow;
    final progress = (kpi / 80).clamp(0.0, 1.0);

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
