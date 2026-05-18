import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class _LeaderEntry {
  const _LeaderEntry({
    required this.firstName,
    required this.lastName,
    required this.score,
    required this.position,
  });
  final String firstName;
  final String lastName;
  final String score;
  final String position;
}

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

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // 2nd left · 1st centre · 3rd right
  static const _podium = [
    _LeaderEntry(firstName: 'Marcus', lastName: 'Whitfield',  score: '75.9', position: '2nd'),
    _LeaderEntry(firstName: 'James',  lastName: 'Hargreaves', score: '78.4', position: '1st'),
    _LeaderEntry(firstName: 'Daniel', lastName: 'Ashford',    score: '73.2', position: '3rd'),
  ];

  static const _rows = [
    _LeaderboardRow(rank: 4,  trend:  3, engineer: 'Oliver Pendleton', kpi: 70.6),
    _LeaderboardRow(rank: 5,  trend:  0, engineer: 'Harvey Trenton',   kpi: 68.1),
    _LeaderboardRow(rank: 6,  trend: -2, engineer: 'Connor Whitlock',  kpi: 65.7),
    _LeaderboardRow(rank: 7,  trend:  1, engineer: 'Aiden Marsh',      kpi: 63.4),
    _LeaderboardRow(rank: 8,  trend: -1, engineer: 'Felix Donovan',    kpi: 61.0),
    _LeaderboardRow(rank: 9,  trend:  2, engineer: 'Theo Blakemore',   kpi: 58.8),
    _LeaderboardRow(rank: 10, trend:  0, engineer: 'Reuben Carlisle',  kpi: 56.3),
    _LeaderboardRow(rank: 11, trend: -3, engineer: 'Joel Hawthorne',   kpi: 53.9),
    _LeaderboardRow(rank: 12, trend:  1, engineer: 'Nathan Vickers',   kpi: 51.2),
    _LeaderboardRow(rank: 13, trend: -1, engineer: 'Eli Brookfield',   kpi: 48.7),
    _LeaderboardRow(rank: 14, trend:  2, engineer: 'Caleb Sherwood',   kpi: 45.5),
  ];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const AspectBranding(),
                SizedBox(height: 6.h),
                Text(
                  'Electrician Leaderboard',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                _leaderboardCard(),
                SizedBox(height: 5.h),
                _leaderboardTable(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Podium card ────────────────────────────────────────────────────────────

  Widget _leaderboardCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 32.h,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9FC3FC), width: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: Offset(0, 4.h),
            blurRadius: 10.r,
            spreadRadius: -1.r,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _podiumColumn(_podium[0])),
          SizedBox(width: 14.w),
          Expanded(child: _podiumColumn(_podium[1])),
          SizedBox(width: 14.w),
          Expanded(child: _podiumColumn(_podium[2])),
        ],
      ),
    );
  }

  // ── Single podium column ───────────────────────────────────────────────────

  Widget _podiumColumn(_LeaderEntry entry) {
    final isFirst   = entry.position == '1st';
    final cardH     = isFirst ? 175.h : 145.h;
    final nameSize  = isFirst ? 14.sp  : 12.sp;
    final iconSize  = isFirst ? 42.sp  : 32.sp;
    final scoreSize = isFirst ? 24.sp  : 20.sp;

    const cardColor   = Color(0xFFF8FFA7);
    const borderColor = Color(0xFF5A9CF6);
    const textColor   = Color(0xFF1A4781);
    const nameColor   = Color(0xFF27549D);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy card
        Container(
          width: double.infinity,
          height: cardH,
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 0.25),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.firstName,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                entry.lastName,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 9.h),
              Icon(Icons.emoji_events_outlined, size: iconSize, color: textColor),
              SizedBox(height: 9.h),
              Text(
                entry.score,
                style: TextStyle(
                  fontSize: scoreSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: 5.h),

        // Rank badge
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 0.25),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            '${entry.position} Place',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: nameColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Table ──────────────────────────────────────────────────────────────────

  Widget _leaderboardTable() {
    return Column(
      children: [
        _leaderboardHeader(),
        SizedBox(height: 3.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _rows.length,
          separatorBuilder: (_, __) => SizedBox(height: 3.h),
          itemBuilder: (_, index) => _leaderboardRow(_rows[index]),
        ),
      ],
    );
  }

  // ── Table header ───────────────────────────────────────────────────────────

  Widget _leaderboardHeader() {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF5A9CF6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _headerCell('Rank',        width: 28.w, align: TextAlign.center),
          _headerCell('Trend',       width: 52.w, align: TextAlign.center),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                'Engineer',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF1FF24),
                ),
              ),
            ),
          ),
          _headerCell('Overall KPI', width: 130.w, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required double width, required TextAlign align}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF1FF24),
        ),
      ),
    );
  }

  // ── Table row ──────────────────────────────────────────────────────────────

  Widget _leaderboardRow(_LeaderboardRow row) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6FF).withValues(alpha: 0.2),
        border: Border.all(color: const Color(0xFF9FC3FC), width: 1),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3.r,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28.w,
            child: Text(
              '${row.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A4781),
              ),
            ),
          ),

          // Trend
          SizedBox(width: 52.w, child: _trendCell(row.trend)),

          // Engineer name
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
                  color: const Color(0xFF1A4781),
                ),
              ),
            ),
          ),

          // KPI bar + value
          SizedBox(width: 130.w, child: _kpiCell(row.kpi)),
        ],
      ),
    );
  }

  // ── Trend cell ─────────────────────────────────────────────────────────────
  // Mirrors: small 8×8 triangle SVG + "↑ +3" / "↓ -2" text
  // trend >= 0 → green up · trend < 0 → red down

  Widget _trendCell(int trend) {
    final isDown  = trend < 0;
    final color   = isDown ? const Color(0xFFFD541C) : const Color(0xFF1CB814);
    final arrow   = isDown ? '▼' : '▲'; // mirrors the rotated SVG triangle
    final label   = isDown ? '↓ $trend' : '↑ +$trend';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small filled triangle — mirrors 8×8 SVG
        Text(
          arrow,
          style: TextStyle(
            fontSize: 7.sp,
            color: color,
            height: 1,
          ),
        ),
        SizedBox(width: 2.w),
        // Direction + value text
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

  // ── KPI cell ───────────────────────────────────────────────────────────────
  // Progress bar fills kpi/80 of width, mirroring HTML percentage widths

  Widget _kpiCell(double kpi) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 12.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF9FC3FC), width: 0.35),
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
              color: const Color(0xFF1A4781),
            ),
          ),
        ),
      ],
    );
  }
}