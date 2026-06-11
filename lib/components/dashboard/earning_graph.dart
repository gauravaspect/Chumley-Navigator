import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningGraph extends StatefulWidget {
  const EarningGraph({super.key});

  @override
  State<EarningGraph> createState() => _EarningGraphState();
}

class _EarningGraphState extends State<EarningGraph> {
  int selectedMonth = 8;

  final List<int> months = [3, 6, 8, 12];

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Oldest → newest month abbreviations for the last [count] months.
  List<String> _monthLabels(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final monthsBack = count - 1 - index;
      final date = DateTime(now.year, now.month - monthsBack, 1);
      return _monthNames[date.month - 1];
    });
  }

  final Map<int, List<double>> barHeights = {
    3: [22, 45, 72],
    6: [18, 28, 36, 42, 54, 72],
    8: [10, 14, 18, 22, 28, 42, 56, 72],
    12: [6, 8, 10, 14, 18, 24, 30, 38, 46, 58, 64, 72],
  };

  static double _barGap(int count) {
    if (count <= 6) return 6;
    if (count <= 8) return 3;
    return 2;
  }

  static double _labelFontSize(int count) {
    if (count <= 6) return 9;
    if (count <= 8) return 8;
    return 7;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final currentLabels = _monthLabels(selectedMonth);
    final currentBars = barHeights[selectedMonth]!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: theme.dashCardDecoration(softBorder: true),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earnings in the last $selectedMonth Months',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.dashTitle,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Monthly earning performance revenue',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.dashSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  constraints: BoxConstraints(maxWidth: 96.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                  decoration: BoxDecoration(
                    color: theme.dashSurfaceTint,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      isDense: true,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14.sp,
                        color: theme.dashPrimary,
                      ),
                      dropdownColor: theme.dashCardBg,
                      borderRadius: BorderRadius.circular(12.r),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.dashPrimary,
                      ),
                      items: months.map((month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text('$month mo'),
                        );
                      }).toList(),
                      selectedItemBuilder: (context) {
                        return months
                            .map(
                              (month) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$month mo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.dashPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList();
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedMonth = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _ChartBody(
                key: ValueKey(selectedMonth),
                theme: theme,
                monthCount: selectedMonth,
                barGap: _barGap(selectedMonth).w,
                labelFontSize: _labelFontSize(selectedMonth).sp,
                currentLabels: currentLabels,
                currentBars: currentBars,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({
    super.key,
    required this.theme,
    required this.monthCount,
    required this.barGap,
    required this.labelFontSize,
    required this.currentLabels,
    required this.currentBars,
  });

  final DashboardTheme theme;
  final int monthCount;
  final double barGap;
  final double labelFontSize;
  final List<String> currentLabels;
  final List<double> currentBars;

  bool get _compactChart => monthCount >= 8;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: SizedBox(
            height: 120.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _yAxisText(theme, '£4.0k'),
                _yAxisText(theme, '£3.0k'),
                _yAxisText(theme, '£2.0k'),
                _yAxisText(theme, '£1.0k'),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 120.h,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (_) => Container(
                          height: 1.h,
                          color: theme.chartGridLine,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(currentLabels.length, (index) {
                            final isActive =
                                index == currentLabels.length - 1;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == currentLabels.length - 1
                                      ? 0
                                      : barGap,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isActive && !_compactChart)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 4.h),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.chartBarSelected,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          '£131',
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0,
                                        end: currentBars[index],
                                      ),
                                      duration: Duration(
                                        milliseconds: 400 + (index * 40),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, height, _) {
                                        return Container(
                                          width: double.infinity,
                                          height: height.h,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? theme.chartBarSelected
                                                : theme.chartBarFill,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                _compactChart ? 2.r : 4.r,
                                              ),
                                              topRight: Radius.circular(
                                                _compactChart ? 2.r : 4.r,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1.h,
                        color: theme.dashBorderLight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: List.generate(currentLabels.length, (index) {
                  final isActive = index == currentLabels.length - 1;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == currentLabels.length - 1 ? 0 : barGap,
                      ),
                      child: Text(
                        currentLabels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? theme.dashPrimary
                              : theme.dashSubtitle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _yAxisText(DashboardTheme theme, String text) {
    return SizedBox(
      width: 24.w,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: theme.dashSubtitle,
        ),
      ),
    );
  }
}
