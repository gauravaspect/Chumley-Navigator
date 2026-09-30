import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InsightsTabView extends StatelessWidget {
  const InsightsTabView({
    super.key,
    required this.theme,
    required this.state,
    required this.onRetry,
  });

  final DashboardTheme theme;
  final ChumleyChatState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.briefingLoading && state.briefing == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.briefingError != null && state.briefing == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.briefingError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.errorText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final briefing = state.briefing;
    if (briefing == null) {
      return Center(
        child: Text(
          'No briefing available.',
          style: TextStyle(color: theme.textMuted, fontSize: 13.sp),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
      children: [
        Text(
          '${briefing.areaCount} AREAS',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: theme.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          "Today's headlines",
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 16.h),
        if (briefing.revenue != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.trendingUp,
            title: 'Revenue & Sales',
            columns: [
              _KpiCol(
                'Yesterday',
                _gbp(briefing.revenue!.yesterday),
                _pct(briefing.revenue!.yesterdayPct),
                _variantFromPct(briefing.revenue!.yesterdayPct),
              ),
              _KpiCol(
                'MTD',
                _gbp(briefing.revenue!.mtd),
                _pct(briefing.revenue!.mtdPct),
                _variantFromPct(briefing.revenue!.mtdPct),
              ),
            ],
            summary: briefing.revenue!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.capacity != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.activity,
            title: 'Capacity',
            columns: [
              _KpiCol(
                'Yesterday Completed',
                '${briefing.capacity!.completed}/${briefing.capacity!.total}',
                '${briefing.capacity!.completionRate.round()}%',
                _ChipVariant.good,
              ),
              _KpiCol(
                'Today Scheduled',
                '${briefing.capacity!.today} jobs',
                '${briefing.capacity!.today}',
                _ChipVariant.warn,
              ),
              _KpiCol(
                'Tomorrow Sched.',
                '${briefing.capacity!.tomorrow} jobs',
                '${briefing.capacity!.tomorrow}',
                _ChipVariant.warn,
              ),
            ],
            summary: briefing.capacity!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.cash != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.poundSterling,
            title: 'Cash & Receivables',
            columns: [
              _KpiCol(
                'Collected Yesterday',
                _gbp(briefing.cash!.collectedYesterday),
                _gbpShort(briefing.cash!.collectedYesterday),
                _ChipVariant.good,
              ),
              _KpiCol(
                'Outstanding',
                _gbp(briefing.cash!.outstanding),
                _gbpShort(briefing.cash!.outstanding),
                _ChipVariant.warn,
              ),
              _KpiCol(
                'Overdue >30d',
                _gbp(briefing.cash!.overdue30d),
                _gbpShort(briefing.cash!.overdue30d),
                _ChipVariant.danger,
              ),
            ],
            summary: briefing.cash!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.creditNotes != null)
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.fileText,
            title: 'Credit Notes',
            columns: [
              _KpiCol(
                'MTD',
                _gbp(briefing.creditNotes!.mtd),
                _pct(briefing.creditNotes!.mtdPct),
                _ChipVariant.danger,
              ),
              _KpiCol(
                briefing.creditNotes!.topTrade ?? 'Top trade',
                _gbp(briefing.creditNotes!.topTradeAmount),
                briefing.creditNotes!.topTradePct != null
                    ? '${briefing.creditNotes!.topTradePct}%'
                    : '—',
                _ChipVariant.danger,
              ),
            ],
            summary: briefing.creditNotes!.summary,
          ),
      ],
    );
  }

  static String _gbp(double n) =>
      '£${n.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  static String _gbpShort(double n) {
    final v = n.abs();
    if (v >= 1000000) return '£${(n / 1000000).toStringAsFixed(2)}m';
    if (v >= 1000) return '£${(n / 1000).round()}k';
    return '£${n.round()}';
  }

  static String _pct(double? p) =>
      p == null ? '—' : (p >= 0 ? '+${p.round()}%' : '${p.round()}%');

  static _ChipVariant _variantFromPct(double? p) =>
      (p != null && p < 0) ? _ChipVariant.danger : _ChipVariant.good;
}

enum _ChipVariant { good, warn, danger }

class _KpiCol {
  const _KpiCol(this.label, this.value, this.chip, this.variant);
  final String label;
  final String value;
  final String chip;
  final _ChipVariant variant;
}

class _BriefingCard extends StatelessWidget {
  const _BriefingCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.columns,
    required this.summary,
  });

  final DashboardTheme theme;
  final IconData icon;
  final String title;
  final List<_KpiCol> columns;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ElevatedSurface(
      padding: EdgeInsets.all(16.r),
      backgroundColor: theme.surface,
      borderColor: theme.dashCardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlueTint,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.dashTitle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        columns[i].label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        columns[i].value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _TrendChip(
                        text: columns[i].chip,
                        variant: columns[i].variant,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Text(
              summary,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.textBody,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.text, required this.variant});

  final String text;
  final _ChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      _ChipVariant.good => (AppColors.successText, AppColors.successBackground),
      _ChipVariant.warn => (AppColors.pendingText, AppColors.pendingBackground),
      _ChipVariant.danger => (AppColors.errorText, AppColors.errorBackground),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: colors.$1,
        ),
      ),
    );
  }
}
