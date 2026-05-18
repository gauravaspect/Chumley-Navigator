import 'package:flutter/material.dart';
import 'package:chumley_navigator/utils/colors.dart';
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
    3: [
      '112 EPR',
      '124 EPR',
      '131 EPR',
    ],
    6: [
      '103 EPR',
      '112 EPR',
      '119 EPR',
      '124 EPR',
      '128 EPR',
      '131 EPR',
    ],
    8: [
      '98 EPR',
      '107 EPR',
      '115 EPR',
      '103 EPR',
      '112 EPR',
      '119 EPR',
      '124 EPR',
      '131 EPR',
    ],
    12: [
      '84 EPR',
      '90 EPR',
      '96 EPR',
      '101 EPR',
      '107 EPR',
      '110 EPR',
      '115 EPR',
      '118 EPR',
      '122 EPR',
      '126 EPR',
      '128 EPR',
      '131 EPR',
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
    final currentLabels = labels[selectedMonth]!;
    final currentBars = barHeights[selectedMonth]!;

    return Container(
      padding: EdgeInsets.all(20.r),
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.accentBlue,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─────────────────────────────────────────
          // HEADER
          // ─────────────────────────────────────────

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings in the last $selectedMonth Months',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadingDark,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Monthly earning performance revenue',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // ─────────────────────────────────────
              // DROPDOWN
              // ─────────────────────────────────────

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chartFillBlue,
                  borderRadius:
                  BorderRadius.circular(16.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.sp,
                      color: AppColors.primaryBlue,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius:
                    BorderRadius.circular(12.r),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue,
                    ),
                    items: months.map((month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text('$month Months'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedMonth = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ─────────────────────────────────────────
          // GRAPH AREA
          // ─────────────────────────────────────────

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // Y AXIS

              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    _yAxisText('£4.0k'),
                    _yAxisText('£3.0k'),
                    _yAxisText('£2.0k'),
                    _yAxisText('£1.0k'),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // GRAPH

              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 120.h,
                      child: Stack(
                        children: [
                          // GRID LINES

                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: List.generate(
                              4,
                                  (_) => Container(
                                height: 1.h,
                                color: AppColors.chartGridLine,
                              ),
                            ),
                          ),

                          // BARS

                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 4.h,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,
                                children:
                                List.generate(
                                  currentLabels.length,
                                      (index) {
                                    final bool
                                    isActive =
                                        index ==
                                            currentLabels
                                                .length -
                                                1;

                                    return Expanded(
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(
                                          right: index ==
                                              currentLabels.length -
                                                  1
                                              ? 0
                                              : 6.w,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .end,
                                          children: [
                                            if (isActive)
                                              Container(
                                                margin:
                                                EdgeInsets
                                                    .only(
                                                  bottom:
                                                  6.h,
                                                ),
                                                padding:
                                                EdgeInsets.symmetric(
                                                  horizontal:
                                                  6.w,
                                                  vertical:
                                                  3.h,
                                                ),
                                                decoration:
                                                BoxDecoration(
                                                  color: AppColors.primaryBlue,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    6.r,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors
                                                          .black
                                                          .withOpacity(
                                                        0.12,
                                                      ),
                                                      blurRadius:
                                                      8.r,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  '£131',
                                                  style:
                                                  TextStyle(
                                                    fontSize:
                                                    10.sp,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),

                                            AnimatedContainer(
                                              duration:
                                              const Duration(
                                                milliseconds:
                                                350,
                                              ),
                                              curve:
                                              Curves.easeOut,
                                              height:
                                              currentBars[
                                              index]
                                                  .h,
                                              decoration:
                                              BoxDecoration(
                                                color:
                                                isActive
                                                    ? AppColors.primaryBlue
                                                    : AppColors.borderLightBlue,
                                                borderRadius:
                                                BorderRadius.only(
                                                  topLeft:
                                                  Radius.circular(
                                                    4.r,
                                                  ),
                                                  topRight:
                                                  Radius.circular(
                                                    4.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // BOTTOM LINE

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1.h,
                              color: AppColors.borderDefault,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // X AXIS LABELS

                    Row(
                      children: List.generate(
                        currentLabels.length,
                            (index) {
                          final bool isActive =
                              index ==
                                  currentLabels.length -
                                      1;

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index ==
                                    currentLabels
                                        .length -
                                        1
                                    ? 0
                                    : 6.w,
                              ),
                              child: Text(
                                currentLabels[index],
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: isActive
                                      ? AppColors.primaryBlue
                                      : AppColors.textChartLegend,
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _yAxisText(String text) {
    return SizedBox(
      width: 28.w,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textChartLegend,
        ),
      ),
    );
  }
}