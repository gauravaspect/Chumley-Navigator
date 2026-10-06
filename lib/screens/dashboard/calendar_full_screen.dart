import 'package:chumley_navigator/components/dashboard/dashboard_calendar.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    DashboardCubit? cubit;
    try {
      cubit = context.read<DashboardCubit>();
    } catch (_) {
      cubit = null;
    }
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          final page = CalendarFullScreen(
            appointments: appointments,
            ppmTasks: ppmTasks,
            isLoading: isLoading,
          );
          if (cubit == null) return page;
          return BlocProvider.value(value: cubit, child: page);
        },
      ),
    );
  }

  static List<Appointment> _activeAppointments(List<Appointment> appointments) {
    return appointments
        .where((a) => a.status.trim().toLowerCase() != 'scheduled')
        .toList();
  }

  static bool _hasDashboardCubit(BuildContext context) {
    try {
      context.read<DashboardCubit>();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    if (_hasDashboardCubit(context)) {
      return BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return _buildScaffold(
            context,
            theme,
            appointments: _activeAppointments(state.appointmentsOrEmpty),
            ppmTasks: state.ppmTasksOrEmpty,
            isLoading: state.isAppointmentsLoading,
          );
        },
      );
    }

    return _buildScaffold(
      context,
      theme,
      appointments: appointments,
      ppmTasks: ppmTasks,
      isLoading: isLoading,
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    DashboardTheme theme, {
    required List<Appointment> appointments,
    required List<PpmJobTask> ppmTasks,
    required bool isLoading,
  }) {
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
