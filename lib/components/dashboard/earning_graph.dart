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

  final Map<int, List<String>> labels = {
    3: ['112 EPR', '124 EPR', '131 EPR'],
    6: ['103 EPR', '112 EPR', '119 EPR', '124 EPR', '128 EPR', '131 EPR'],
    8: [
      '98 EPR', '107 EPR', '115 EPR', '103 EPR',
      '112 EPR', '119 EPR', '124 EPR', '131 EPR',
    ],
    12: [
      '84 EPR', '90 EPR', '96 EPR', '101 EPR', '107 EPR', '110 EPR',
      '115 EPR', '118 EPR', '122 EPR', '126 EPR', '128 EPR', '131 EPR',
    ],
  };

  final Map<int, List<double>> barHeights = {
    3: [22, 45, 72],
    6: [18, 28, 36, 42, 54, 72],
    8: [10, 14, 18, 22, 28, 42, 56, 72],
    12: [6, 8, 10, 14, 18, 24, 30, 38, 46, 58, 64, 72],
  };

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final currentLabels = labels[selectedMonth]!;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings in the last $selectedMonth Months',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashTitle,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Monthly earning performance revenue',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashSubtitle,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: theme.dashSurfaceTint,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16.sp,
                        color: theme.dashPrimary,
                      ),
                      dropdownColor: theme.dashCardBg,
                      borderRadius: BorderRadius.circular(12.r),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashPrimary,
                      ),
                      items: months.map((month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text('$month Months'),
                        );
                      }).toList(),
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
    required this.currentLabels,
    required this.currentBars,
  });

  final DashboardTheme theme;
  final List<String> currentLabels;
  final List<double> currentBars;

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
        SizedBox(width: 8.w),
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
                                      : 6.w,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isActive)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 6.h),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.chartBarSelected,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.dashCardShadow,
                                              blurRadius: 8.r,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '£131',
                                          style: TextStyle(
                                            fontSize: 10.sp,
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
                                          height: height.h,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? theme.chartBarSelected
                                                : theme.chartBarFill,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.r),
                                              topRight: Radius.circular(4.r),
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
                        right: index == currentLabels.length - 1 ? 0 : 6.w,
                      ),
                      child: Text(
                        currentLabels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.sp,
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
      width: 28.w,
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
