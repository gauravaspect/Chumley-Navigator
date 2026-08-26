import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final IconData icon;
}

class EarningCard extends StatefulWidget {
  const EarningCard({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<EarningCard> createState() => _EarningCardState();
}

class _EarningCardState extends State<EarningCard> {
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

  static const _activities = [
    _ActivityItem(
      title: 'Job bonus · Leak Detection',
      subtitle: 'Today, 10:50',
      amount: '+£45.00',
      isCredit: true,
      icon: LucideIcons.poundSterling,
    ),
    _ActivityItem(
      title: 'Instant transfer',
      subtitle: 'Yesterday · to bank ending 4417',
      amount: '−£150.00',
      isCredit: false,
      icon: LucideIcons.wallet,
    ),
    _ActivityItem(
      title: 'June salary',
      subtitle: 'Paid 28 Jun',
      amount: '+£3,180.00',
      isCredit: true,
      icon: LucideIcons.poundSterling,
    ),
  ];

  double get _totalEarnings {
    final breakdown = widget.user.performanceBreakdown;
    final computed = breakdown.avgJobValue * breakdown.cases;
    if (computed > 0) return computed;
    return 3240;
  }

  String get _earningsLabel {
    final amount = _totalEarnings;
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

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final labels = _monthLabels(_months);
    final heights = _barHeightsByRange[_months]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashHeading,
          ),
        ),
        SizedBox(height: 14.h),
        _withdrawCard(theme),
        SizedBox(height: 14.h),
        Container(
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
                                _earningsLabel,
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
                              child: Text(
                                '↑ 18%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 16 / 12,
                                  letterSpacing: 0.3,
                                  color: theme.dashSuccessFg,
                                ),
                              ),
                            ),
                          ],
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
              SizedBox(height: 16.h),
              Divider(height: 1, color: theme.dashBorderLight),
              SizedBox(height: 14.h),
              Text(
                'Activity',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 6.h),
              for (final item in _activities) _activityRow(item, theme),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: Material(
                  color: theme.dashPrimary,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.earningsDetail,
                      arguments: widget.user,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Center(
                      child: Text(
                        'Show more',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _withdrawCard(DashboardTheme theme) {
    final cases = widget.user.performanceBreakdown.cases.toInt();
    final jobsLabel = cases > 0 ? cases : 14;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
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
                      'Available to withdraw',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '£386.68',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        height: 34 / 32,
                        letterSpacing: -1.4,
                        color: theme.dashTitle,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Accrued from $jobsLabel completed jobs',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? theme.dashSurfaceTint
                      : const Color(0xFFD8E6FC),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.wallet,
                  size: 22.sp,
                  color: theme.dashPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: Material(
              color: AppColors.accentLime,
              borderRadius: BorderRadius.circular(14.r),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdraw — coming soon')),
                  );
                },
                borderRadius: BorderRadius.circular(14.r),
                child: Center(
                  child: Text(
                    'Withdraw',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Instant transfer · £1.75 fee · arrives in minutes',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: theme.dashMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(_ActivityItem item, DashboardTheme theme) {
    final iconBg = item.isCredit
        ? theme.dashSuccessBg
        : (theme.isDark ? theme.dashSurfaceTint : const Color(0xFFD8E6FC));
    final iconColor =
        item.isCredit ? theme.dashSuccessFg : theme.dashPrimary;
    final amountColor =
        item.isCredit ? theme.dashSuccessFg : theme.dashTitle;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
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
                    height: 20 / 14,
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
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              height: 21 / 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
