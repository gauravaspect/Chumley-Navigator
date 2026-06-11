import 'package:chumley_navigator/screens/leaderboard/cubit/leaderboard_state.dart';
import 'package:chumley_navigator/screens/leaderboard/repo/leaderboard_repository.dart';
import 'package:chumley_navigator/screens/leaderboard/service/leaderboard_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repository) : super(const LeaderboardInitial());

  final LeaderboardRepository _repository;

  Future<void> load() async {
    final cached = await _repository.readCachedLeaderboard();
    emit(LeaderboardLoading(cachedLeaderboard: cached));

    try {
      final leaderboard = await _repository.fetchLeaderboard();
      emit(LeaderboardLoaded(leaderboard));
    } on LeaderBoardApiException catch (e) {
      emit(LeaderboardError(message: e.message, cachedLeaderboard: cached));
    } catch (_) {
      emit(LeaderboardError(
        message: 'Unable to load leaderboard. Please try again.',
        cachedLeaderboard: cached,
      ));
    }
  }

  Future<void> refresh() => load();
}
