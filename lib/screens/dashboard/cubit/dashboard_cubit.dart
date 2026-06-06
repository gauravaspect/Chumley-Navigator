import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/screens/dashboard/repo/dashboard_repository.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardInitial());

  final DashboardRepository _repository;

  Future<void> load() async {
    final cached = await _repository.readCachedProfile();
    emit(DashboardLoading(cachedUser: cached));

    try {
      final user = await _repository.fetchDashboardData();
      emit(DashboardLoaded(user));
    } on DashboardApiException catch (e) {
      emit(DashboardError(message: e.message, cachedUser: cached));
    } catch (_) {
      emit(DashboardError(
        message: 'Unable to load dashboard. Please try again.',
        cachedUser: cached,
      ));
    }
  }

  Future<void> refresh() => load();
}
