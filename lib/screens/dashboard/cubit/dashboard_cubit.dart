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
      final user = await _repository.fetchDashboardData();
      final points = await _repository.fetchPoints();
      final ppmTasks = await _fetchPpmBestEffort(stalePpm);
      final appointments = await _repository.fetchAppointments(
        profileFallback: user,
      );
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
