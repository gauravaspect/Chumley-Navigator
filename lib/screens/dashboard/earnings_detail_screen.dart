import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _ActivityTone { paid, sent, deducted }

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amount;
  final _ActivityTone tone;
  final IconData icon;
}

class EarningsDetailScreen extends StatefulWidget {
  const EarningsDetailScreen({super.key});

  @override
  State<EarningsDetailScreen> createState() => _EarningsDetailScreenState();
}

class _EarningsDetailScreenState extends State<EarningsDetailScreen> {
  int _months = 6;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _barHeightsByRange = {
    3: [0.52, 0.68, 1.0],
    6: [0.44, 0.60, 0.52, 0.75, 0.67, 1.0],
    12: [0.28, 0.32, 0.38, 0.44, 0.50, 0.55, 0.60, 0.66, 0.72, 0.80, 0.88, 1.0],
  };

  static const _monthBreakdown = [
    ('Base pay', '£2,400'),
    ('Job bonuses', '£520'),
    ('Incentives', '£220'),
    ('Reward points', '£100'),
  ];

  static const _activities = [
    _ActivityItem(
      title: 'Job bonus · Leak Detection',
      subtitle: 'Today, 10:50',
      amount: '+£45.00',
      tone: _ActivityTone.paid,
      icon: LucideIcons.poundSterling,
    ),
    _ActivityItem(
      title: 'Instant transfer',
      subtitle: 'Yesterday · to bank ending 4417',
      amount: '−£150.00',
      tone: _ActivityTone.sent,
      icon: LucideIcons.wallet,
    ),
    _ActivityItem(
      title: 'June salary',
      subtitle: 'Paid 28 Jun',
      amount: '+£3,180.00',
      tone: _ActivityTone.paid,
      icon: LucideIcons.poundSterling,
    ),
    _ActivityItem(
      title: 'June KPI adjustment',
      subtitle: 'Applied 28 Jun',
      amount: '−£140.00',
      tone: _ActivityTone.deducted,
      icon: LucideIcons.arrowDown,
    ),
    _ActivityItem(
      title: 'May salary',
      subtitle: 'Paid 28 May',
      amount: '+£2,940.00',
      tone: _ActivityTone.paid,
      icon: LucideIcons.poundSterling,
    ),
    _ActivityItem(
      title: 'May KPI adjustment',
      subtitle: 'Applied 28 May',
      amount: '−£95.00',
      tone: _ActivityTone.deducted,
      icon: LucideIcons.arrowDown,
    ),
    _ActivityItem(
      title: 'Q2 incentive bonus',
      subtitle: 'Paid 15 Apr',
      amount: '+£220.00',
      tone: _ActivityTone.paid,
      icon: LucideIcons.poundSterling,
    ),
  ];

  double _totalEarnings(UserModel? user) {
    if (user == null) return 3240;
    final breakdown = user.performanceBreakdown;
    final computed = breakdown.avgJobValue * breakdown.cases;
    return computed > 0 ? computed : 3240;
  }

  String _formatMoney(double amount) {
    final whole = amount.round();
    final formatted = whole.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '£$formatted';
  }

  List<String> _monthLabels(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final monthsBack = count - 1 - index;
      final date = DateTime(now.year, now.month - monthsBack, 1);
      return _monthNames[date.month - 1];
    });
  }

  Future<void> _pickPeriod() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in const [3, 6, 12])
                ListTile(
                  title: Text('$option months'),
                  trailing: option == _months
                      ? Icon(LucideIcons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _months = selected);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as UserModel?;
    final total = _totalEarnings(user);
    final labels = _monthLabels(_months);
    final heights = _barHeightsByRange[_months]!;
    final currentMonth = _monthNames[DateTime.now().month - 1];
    final cases = user?.performanceBreakdown.cases.toInt() ?? 14;

    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          appBar: AppBar(
            backgroundColor: theme.base,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
                color: theme.dashPrimary,
                size: 22.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Earnings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.dashHeading,
              ),
            ),
            centerTitle: true,
          ),
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
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              children: [
                _totalEarnedCard(theme, total, labels, heights),
                SizedBox(height: 14.h),
                _withdrawStrip(theme),
                SizedBox(height: 18.h),
                _thisMonthSection(theme, currentMonth),
                SizedBox(height: 18.h),
                Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.dashHeading,
                  ),
                ),
                SizedBox(height: 10.h),
                _activityCard(theme),
                SizedBox(height: 12.h),
                Text(
                  'Accrued from $cases completed jobs · Instant transfer £1.75 fee',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.dashMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _totalEarnedCard(
    DashboardTheme theme,
    double total,
    List<String> labels,
    List<double> heights,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: theme.dashCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total earned',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashMuted,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _formatMoney(total),
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              height: 34 / 32,
                              letterSpacing: -1.4,
                              color: theme.dashTitle,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.dashSuccessBg,
                            borderRadius: BorderRadius.circular(500.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.arrowUp,
                                size: 12.sp,
                                color: theme.dashSuccessFg,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '18%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.dashSuccessFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Last $_months months',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashMuted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickPeriod,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.dashPrimary,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_months months',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            height: 120.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heights[i].clamp(0.08, 1.0),
                              widthFactor: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == labels.length - 1
                                      ? theme.dashPrimary
                                      : const Color(0xFFC9DCF7),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: theme.dashMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _withdrawStrip(DashboardTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: theme.dashCardDecoration(radius: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available to withdraw',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.dashMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '£386.68',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: theme.dashTitle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 36.h,
            child: Material(
              color: AppColors.accentLime,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: () => _snack('Withdraw — coming soon'),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Center(
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thisMonthSection(DashboardTheme theme, String currentMonth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'This month',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashHeading,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: theme.isDark
                    ? theme.dashSurfaceTint
                    : const Color(0xFFD8E6FC),
                borderRadius: BorderRadius.circular(500.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: theme.dashPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    currentMonth,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: theme.dashCardDecoration(radius: 18),
          child: Column(
            children: [
              for (var i = 0; i < _monthBreakdown.length; i++) ...[
                if (i > 0) Divider(height: 1, color: theme.dashBorderLight),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _monthBreakdown[i].$1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: theme.dashSubtitle,
                          ),
                        ),
                      ),
                      Text(
                        _monthBreakdown[i].$2,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.dashTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h, top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? theme.dashSurfaceTint
                      : const Color(0xFFF1F3F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total this month',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.dashTitle,
                        ),
                      ),
                    ),
                    Text(
                      '£3,240',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.dashPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityCard(DashboardTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: theme.dashCardDecoration(radius: 18),
      child: Column(
        children: [
          for (var i = 0; i < _activities.length; i++) ...[
            if (i > 0) Divider(height: 1, color: theme.dashBorderLight),
            _activityRow(_activities[i], theme),
          ],
        ],
      ),
    );
  }

  Widget _activityRow(_ActivityItem item, DashboardTheme theme) {
    final Color iconBg;
    final Color iconColor;
    final Color amountColor;
    final Color chipBg;
    final Color chipFg;
    final String chipLabel;

    switch (item.tone) {
      case _ActivityTone.paid:
        iconBg = theme.dashSuccessBg;
        iconColor = theme.dashSuccessFg;
        amountColor = theme.dashSuccessFg;
        chipBg = theme.dashSuccessBg;
        chipFg = theme.dashSuccessFg;
        chipLabel = 'Paid';
      case _ActivityTone.sent:
        iconBg = theme.isDark
            ? theme.dashSurfaceTint
            : const Color(0xFFD8E6FC);
        iconColor = theme.dashPrimary;
        amountColor = theme.dashTitle;
        chipBg = theme.isDark
            ? theme.dashSurfaceTint
            : const Color(0xFFD8E6FC);
        chipFg = theme.dashPrimary;
        chipLabel = 'Sent';
      case _ActivityTone.deducted:
        iconBg = theme.isDark
            ? const Color(0xFF3F1D1D)
            : const Color(0xFFFDECEC);
        iconColor = const Color(0xFFC42A2A);
        amountColor = const Color(0xFFC42A2A);
        chipBg = theme.isDark
            ? const Color(0xFF3F1D1D)
            : const Color(0xFFFDECEC);
        chipFg = const Color(0xFFC42A2A);
        chipLabel = 'Deducted';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 18.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
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
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.dashMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(500.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: chipFg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      chipLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: chipFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
