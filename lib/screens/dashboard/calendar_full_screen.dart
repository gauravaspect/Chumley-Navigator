import 'package:chumley_navigator/components/dashboard/dashboard_calendar.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full month calendar + schedule, opened from the dashboard "View all" link.
class CalendarFullScreen extends StatelessWidget {
  const CalendarFullScreen({
    super.key,
    this.appointments = const [],
    this.ppmTasks = const [],
    this.isLoading = false,
  });

  final List<Appointment> appointments;
  final List<PpmJobTask> ppmTasks;
  final bool isLoading;

  static Future<void> open(
    BuildContext context, {
    required List<Appointment> appointments,
    List<PpmJobTask> ppmTasks = const [],
    bool isLoading = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalendarFullScreen(
          appointments: appointments,
          ppmTasks: ppmTasks,
          isLoading: isLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Scaffold(
      backgroundColor: theme.base,
      appBar: AppBar(
        backgroundColor: theme.base,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.dashTitle),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Calendar',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: theme.dashHeading,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: DashboardCalendar(
            appointments: appointments,
            ppmTasks: ppmTasks,
            showHeader: false,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }
}
