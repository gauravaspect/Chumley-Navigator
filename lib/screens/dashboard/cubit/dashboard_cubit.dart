import 'package:chumley_navigator/models/appointment.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardInitial());

  final DashboardRepository _repository;

  Future<void> load() async {
    final staleUser = state.userOrNull ?? await _repository.readCachedProfile();
    final stalePoints =
        state.performanceHistoryOrNull ?? await _repository.readCachedPoints();
    final stalePpm = state.ppmTasksOrEmpty;
    final staleAppointments = state.appointmentsOrEmpty;

    emit(
      DashboardLoading(
        cachedUser: staleUser,
        cachedPoints: stalePoints,
        cachedPpmTasks: stalePpm,
        cachedAppointments: staleAppointments,
      ),
    );

    try {
      final userFuture = _repository.fetchDashboardData();
      final pointsFuture = _repository.fetchPoints();
      final ppmFuture = _fetchPpmBestEffort(stalePpm);

      final user = await userFuture;
      final appointmentsFuture = _repository.fetchAppointments(
        profileFallback: user,
      );

      final points = await pointsFuture;
      final ppmTasks = await ppmFuture;
      final appointments = await appointmentsFuture;

      emit(
        DashboardLoaded(
          user: user,
          performanceHistory: points,
          ppmTasks: ppmTasks,
          appointments: appointments,
        ),
      );
    } on DashboardApiException catch (e) {
      emit(
        DashboardError(
          message: e.message,
          cachedUser: staleUser,
          cachedPoints: stalePoints,
          cachedPpmTasks: stalePpm,
          cachedAppointments: staleAppointments,
        ),
      );
    } catch (_) {
      emit(
        DashboardError(
          message: 'Unable to load dashboard. Please try again.',
          cachedUser: staleUser,
          cachedPoints: stalePoints,
          cachedPpmTasks: stalePpm,
          cachedAppointments: staleAppointments,
        ),
      );
    }
  }

  Future<List<PpmJobTask>> _fetchPpmBestEffort(
    List<PpmJobTask> fallback,
  ) async {
    try {
      return await _repository.fetchPpmJobs();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> refresh() => load();

  /// Patch a single appointment in the current schedule (e.g. after status change).
  void upsertAppointment(Appointment updated) {
    final id = updated.id.trim();
    if (id.isEmpty) return;

    List<Appointment> merge(List<Appointment> current) {
      final index = current.indexWhere((a) => a.id.trim() == id);
      if (index < 0) return current;
      final next = List<Appointment>.of(current);
      next[index] = updated;
      return next;
    }

    switch (state) {
      case DashboardLoaded(
        :final user,
        :final performanceHistory,
        :final ppmTasks,
        :final appointments,
      ):
        final next = merge(appointments);
        if (identical(next, appointments)) return;
        emit(
          DashboardLoaded(
            user: user,
            performanceHistory: performanceHistory,
            ppmTasks: ppmTasks,
            appointments: next,
          ),
        );
      case DashboardError(
        :final message,
        :final cachedUser,
        :final cachedPoints,
        :final cachedPpmTasks,
        :final cachedAppointments,
      ):
        final next = merge(cachedAppointments);
        if (identical(next, cachedAppointments)) return;
        emit(
          DashboardError(
            message: message,
            cachedUser: cachedUser,
            cachedPoints: cachedPoints,
            cachedPpmTasks: cachedPpmTasks,
            cachedAppointments: next,
          ),
        );
      case DashboardLoading(
        :final cachedUser,
        :final cachedPoints,
        :final cachedPpmTasks,
        :final cachedAppointments,
      ):
        final next = merge(cachedAppointments);
        if (identical(next, cachedAppointments)) return;
        emit(
          DashboardLoading(
            cachedUser: cachedUser,
            cachedPoints: cachedPoints,
            cachedPpmTasks: cachedPpmTasks,
            cachedAppointments: next,
          ),
        );
      default:
        break;
    }
  }

  /// Re-fetch schedule appointments without a full dashboard reload.
  Future<void> refreshAppointments() async {
    final user = state.userOrNull ?? await _repository.readCachedProfile();
    try {
      final appointments = await _repository.fetchAppointments(
        profileFallback: user,
      );
      switch (state) {
        case DashboardLoaded(
          :final user,
          :final performanceHistory,
          :final ppmTasks,
        ):
          emit(
            DashboardLoaded(
              user: user,
              performanceHistory: performanceHistory,
              ppmTasks: ppmTasks,
              appointments: appointments,
            ),
          );
        case DashboardError(
          :final message,
          :final cachedUser,
          :final cachedPoints,
          :final cachedPpmTasks,
        ):
          emit(
            DashboardError(
              message: message,
              cachedUser: cachedUser,
              cachedPoints: cachedPoints,
              cachedPpmTasks: cachedPpmTasks,
              cachedAppointments: appointments,
            ),
          );
        case DashboardLoading(
          :final cachedUser,
          :final cachedPoints,
          :final cachedPpmTasks,
        ):
          emit(
            DashboardLoading(
              cachedUser: cachedUser,
              cachedPoints: cachedPoints,
              cachedPpmTasks: cachedPpmTasks,
              cachedAppointments: appointments,
            ),
          );
        default:
          break;
      }
    } catch (_) {
      // Keep showing stale appointments on failure.
    }
  }
}
