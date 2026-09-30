import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:equatable/equatable.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading({this.cachedLeaderboard});

  final LeaderboardResponse? cachedLeaderboard;

  @override
  List<Object?> get props => [cachedLeaderboard];
}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(this.leaderboard);

  final LeaderboardResponse leaderboard;

  @override
  List<Object?> get props => [leaderboard];
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError({required this.message, this.cachedLeaderboard});

  final String message;
  final LeaderboardResponse? cachedLeaderboard;

  @override
  List<Object?> get props => [message, cachedLeaderboard];
}

extension LeaderboardStateX on LeaderboardState {
  LeaderboardResponse? get leaderboardOrNull => switch (this) {
    LeaderboardLoaded(:final leaderboard) => leaderboard,
    LeaderboardLoading(:final cachedLeaderboard) => cachedLeaderboard,
    LeaderboardError(:final cachedLeaderboard) => cachedLeaderboard,
    _ => null,
  };
}
