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
    emit(DashboardLoading(cachedUser: staleUser, cachedPoints: stalePoints));

    try {
      final user = await _repository.fetchDashboardData();
      final points = await _repository.fetchPoints();
      emit(DashboardLoaded(user: user, performanceHistory: points));
    } on DashboardApiException catch (e) {
      emit(DashboardError(
        message: e.message,
        cachedUser: staleUser,
        cachedPoints: stalePoints,
      ));
    } catch (_) {
      emit(DashboardError(
        message: 'Unable to load dashboard. Please try again.',
        cachedUser: staleUser,
        cachedPoints: stalePoints,
      ));
    }
  }

  Future<void> refresh() => load();
}
