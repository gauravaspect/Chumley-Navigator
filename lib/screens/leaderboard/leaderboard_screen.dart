import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const AspectBranding(),
                SizedBox(height: 8.h),
                Text(
                  'Electrician Leaderboard',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18.h),
                FadeSlideIn(child: _leaderboardCard()),
                SizedBox(height: 12.h),
                _leaderboardTable(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leaderboardCard() {
    return ElevatedSurface(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 28.h,
        bottom: 14.h,
      ),
      borderRadius: 20.r,
      borderColor: AppColors.borderLightBlue.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: PodiumColumn(entry: _podium[0])),
          SizedBox(width: 12.w),
          Expanded(child: PodiumColumn(entry: _podium[1])),
          SizedBox(width: 12.w),
          Expanded(child: PodiumColumn(entry: _podium[2])),
        ],
      ),
    );
  }

  Widget _leaderboardTable() {
    return Column(
      children: [
        _leaderboardHeader(),
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
            child: _LeaderboardRowTile(row: _rows[index]),
          ),
        ),
      ],
    );
  }

  Widget _leaderboardHeader() {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: ElevatedSurface.softShadows(elevation: 0.65),
      ),
      child: Row(
        children: [
          _headerCell('Rank', width: 28.w, align: TextAlign.center),
          _headerCell('Trend', width: 52.w, align: TextAlign.center),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                'Engineer',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.highlightYellow,
                ),
              ),
            ),
          ),
          _headerCell('Overall KPI', width: 130.w, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    required double width,
    required TextAlign align,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.highlightYellow,
        ),
      ),
    );
  }
}

class _LeaderboardRowTile extends StatelessWidget {
  const _LeaderboardRowTile({required this.row});

  final _LeaderboardRow row;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      scale: 0.99,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.chartFillBlue.withValues(alpha: 0.22),
          border: Border.all(
            color: AppColors.borderLightBlue.withValues(alpha: 0.45),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: ElevatedSurface.softShadows(elevation: 0.45),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28.w,
              child: Text(
                '${row.rank}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlueDark,
                ),
              ),
            ),
            SizedBox(width: 52.w, child: _TrendCell(trend: row.trend)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  row.engineer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlueDark,
                  ),
                ),
              ),
            ),
            SizedBox(width: 130.w, child: _KpiCell(kpi: row.kpi)),
          ],
        ),
      ),
    );
  }
}

class _TrendCell extends StatelessWidget {
  const _TrendCell({required this.trend});

  final int trend;

  @override
  Widget build(BuildContext context) {
    final isDown = trend < 0;
    final color = isDown ? AppColors.streakOrange : const Color(0xFF1CB814);
    final arrow = isDown ? '▼' : '▲';
    final label = isDown ? '↓ $trend' : '↑ +$trend';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arrow,
          style: TextStyle(fontSize: 7.sp, color: color, height: 1),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({required this.kpi});

  final double kpi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 12.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: ElevatedSurface.tintedFill,
              border: Border.all(
                color: AppColors.borderLightBlue.withValues(alpha: 0.4),
                width: 0.35,
              ),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: FractionallySizedBox(
              widthFactor: (kpi / 80).clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1CB814),
                  borderRadius: BorderRadius.circular(999.r),
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
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlueDark,
            ),
          ),
        ),
      ],
    );
  }
}
