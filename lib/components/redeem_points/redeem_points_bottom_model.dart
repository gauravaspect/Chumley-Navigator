import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Section data ──────────────────────────────────────────────────────────────

class _Section {
  const _Section({
    required this.title,
    required this.subtitle,
    this.points = 0,
  });
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
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border(
              top: BorderSide(color: theme.border, width: 0.5),
              left: BorderSide(color: theme.border, width: 0.5),
              right: BorderSide(color: theme.border, width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
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
                            'WHERE YOUR POINTS CAME FROM',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.6,
                              color: theme.textMuted,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Points breakdown',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: theme.surfaceDeep,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.border, width: 0.5),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: theme.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 0, thickness: 0.5, color: theme.border),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              theme: theme,
                              title: 'All points',
                              points: 0,
                              body: 'last 0 months',
                              emphasized: true,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _SummaryCard(
                              theme: theme,
                              title: 'This month',
                              points: 0,
                              body: 'live, updates daily',
                              emphasized: false,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceDeep,
                          border: Border.all(color: theme.border, width: 0.5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Loading months…',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ..._sections.map(
                        (s) => _SectionItem(theme: theme, section: s),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.theme,
    required this.title,
    required this.points,
    required this.body,
    required this.emphasized,
  });

  final DashboardTheme theme;
  final String title;
  final int points;
  final String body;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.brandRed : theme.surfaceDeep,
        border: Border.all(
          color: emphasized ? AppColors.brandRed : theme.border,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: emphasized
                  ? Colors.white.withValues(alpha: 0.7)
                  : theme.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$points',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: emphasized ? Colors.white : theme.text,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                WidgetSpan(child: SizedBox(width: 4.w)),
                TextSpan(
                  text: 'pts',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: emphasized
                        ? Colors.white.withValues(alpha: 0.85)
                        : theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 10.sp,
              color: emphasized
                  ? Colors.white.withValues(alpha: 0.55)
                  : theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section item ──────────────────────────────────────────────────────────────

class _SectionItem extends StatelessWidget {
  const _SectionItem({required this.theme, required this.section});

  final DashboardTheme theme;
  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      section.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  border: Border.all(color: theme.border, width: 0.5),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${section.points}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandRed,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.surfaceDeep,
              border: Border.all(color: theme.border, width: 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '—',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
