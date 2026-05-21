import 'package:chumley_navigator/components/dashboard/earnings_card.dart';
import 'package:chumley_navigator/components/dashboard/kpi_overview.dart';
import 'package:chumley_navigator/components/dashboard/points_card.dart';
import 'package:chumley_navigator/components/dashboard/profle_card.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../components/dashboard/dashboard_calendar.dart';
import '../../components/dashboard/earning_graph.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _sectionGap = 14.0;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      const ProfileCard(),
      const PointsCard(),
      const EarningCard(),
      const DashboardCalendar(),
      const KpiOverview(),
      const EarningGraph(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  FadeSlideIn(
                    delay: Duration(milliseconds: 50 * i),
                    child: sections[i],
                  ),
                  if (i < sections.length - 1) SizedBox(height: _sectionGap.h),
                ],
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
