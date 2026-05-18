import 'package:chumley_navigator/components/dashboard/earnings_card.dart';
import 'package:chumley_navigator/components/dashboard/kpi_overview.dart';
import 'package:chumley_navigator/components/dashboard/points_card.dart';
import 'package:chumley_navigator/components/dashboard/profle_card.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../components/dashboard/dashboard_calendar.dart';
import '../../components/dashboard/earning_graph.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          // ── Body ───────────────────────────────────────────────────
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ProfileCard(),
                PointsCard(),
                EarningCard(),
                DashboardCalendar(),
                KpiOverview(),
                EarningGraph(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
