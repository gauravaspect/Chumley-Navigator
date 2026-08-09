import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardInitial());

  final DashboardRepository _repository;

  Future<void> load() async {
    final staleUser =
        state.userOrNull ?? await _repository.readCachedProfile();
    final stalePoints =
        state.performanceHistoryOrNull ?? await _repository.readCachedPoints();
    final stalePpm = state.ppmTasksOrEmpty;
    emit(DashboardLoading(
      cachedUser: staleUser,
      cachedPoints: stalePoints,
      cachedPpmTasks: stalePpm,
    ));

    try {
      final user = await _repository.fetchDashboardData();
      final points = await _repository.fetchPoints();
      final ppmTasks = await _fetchPpmBestEffort(stalePpm);
      emit(DashboardLoaded(
        user: user,
        performanceHistory: points,
        ppmTasks: ppmTasks,
      ));
    } on DashboardApiException catch (e) {
      emit(DashboardError(
        message: e.message,
        cachedUser: staleUser,
        cachedPoints: stalePoints,
        cachedPpmTasks: stalePpm,
      ));
    } catch (_) {
      emit(DashboardError(
        message: 'Unable to load dashboard. Please try again.',
        cachedUser: staleUser,
        cachedPoints: stalePoints,
        cachedPpmTasks: stalePpm,
      ));
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
}
