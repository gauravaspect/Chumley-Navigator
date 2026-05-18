import 'package:flutter/material.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Section data ──────────────────────────────────────────────────────────────

class _Section {
  const _Section({required this.title, required this.subtitle, this.points = 0});
  final String title;
  final String subtitle;
  final int points;
}

const _sections = [
  _Section(
    title: 'Every job',
    subtitle: 'AJV & converted estimate vs trade-group average',
  ),
  _Section(
    title: 'Customer reviews',
    subtitle: '5-star and 4-star earnings',
  ),
  _Section(
    title: 'Lead conversion',
    subtitle: 'Conversion rate band for the month',
  ),
  _Section(
    title: 'Estimates produced',
    subtitle: '+5 per reactive lead → estimate',
  ),
  _Section(
    title: 'Referrals',
    subtitle: 'New jobs raised from your jobs (1 pt per £1)',
  ),
  _Section(
    title: 'Consistency',
    subtitle: 'Full week / month attendance',
  ),
  _Section(
    title: 'Driving score',
    subtitle: 'Weekly band',
  ),
  _Section(
    title: 'Milestones',
    subtitle: 'Top of trade group, streak bonuses',
  ),
];

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class RedeemPointsBottomModal extends StatelessWidget {
  const RedeemPointsBottomModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDarkBlue.withOpacity(0.45),
            offset: Offset(0, 20.h),
            blurRadius: 50.r,
            spreadRadius: -10.r,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 20.h,
              bottom: 12.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where your points came from',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkBlue,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLightBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderDefault,
                        width: 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16.sp,
                      color: AppColors.textDarkBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 0,
            thickness: 0.5,
            color: AppColors.borderDefault,
          ),

          // ── Scrollable body ─────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary cards ────────────────────────────────
                  Row(
                    children: [
                      // Dark card — All points
                      Expanded(
                        child: _SummaryCard(
                          title: 'All points',
                          points: 0,
                          body: 'last 0 months',
                          isDark: true,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Light card — This month
                      Expanded(
                        child: _SummaryCard(
                          title: 'This month',
                          points: 0,
                          body: 'live, updates daily',
                          isDark: false,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // ── Loading pill ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLightBlue,
                      border: Border.all(
                          color: AppColors.borderDefault, width: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Loading months…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPlaceholder,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Section list ─────────────────────────────────
                  ..._sections.map((s) => _SectionItem(section: s)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.points,
    required this.body,
    required this.isDark,
  });

  final String title;
  final int points;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryBlue : Colors.white,
        border: isDark
            ? null
            : Border.all(color: AppColors.borderDefault, width: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: isDark
            ? [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.5),
            offset: Offset(0, 6.h),
            blurRadius: 16.r,
            spreadRadius: -8.r,
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.08 * 10.5,
              color: isDark
                  ? Colors.white.withOpacity(0.65)
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          // Points
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$points',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : AppColors.textDarkBlue,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                WidgetSpan(child: SizedBox(width: 4.w)),
                TextSpan(
                  text: 'pts',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.accentLime
                        : AppColors.textBodyMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          // Body
          Text(
            body,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.55)
                  : AppColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section item ──────────────────────────────────────────────────────────────

class _SectionItem extends StatelessWidget {
  const _SectionItem({required this.section});
  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: title + subtitle | points badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkBlue,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      section.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Points badge
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlueTint,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${section.points}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkBlue,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Content area
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              border: Border.all(
                  color: AppColors.borderDefault, width: 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '—',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}