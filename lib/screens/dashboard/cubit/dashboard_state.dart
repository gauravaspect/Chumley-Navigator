import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:equatable/equatable.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({this.cachedUser, this.cachedPoints});

  final UserModel? cachedUser;
  final EngineerPerformanceHistory? cachedPoints;

  @override
  List<Object?> get props => [cachedUser, cachedPoints];
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.user,
    required this.performanceHistory,
  });

  final UserModel user;
  final EngineerPerformanceHistory performanceHistory;

  @override
  List<Object?> get props => [user, performanceHistory];
}

class DashboardError extends DashboardState {
  const DashboardError({
    required this.message,
    this.cachedUser,
    this.cachedPoints,
  });

  final String message;
  final UserModel? cachedUser;
  final EngineerPerformanceHistory? cachedPoints;

  @override
  List<Object?> get props => [message, cachedUser, cachedPoints];
}

extension DashboardStateX on DashboardState {
  UserModel? get userOrNull => switch (this) {
    DashboardLoaded(:final user) => user,
    DashboardLoading(:final cachedUser) => cachedUser,
    DashboardError(:final cachedUser) => cachedUser,
    _ => null,
  };

  EngineerPerformanceHistory? get performanceHistoryOrNull => switch (this) {
    DashboardLoaded(:final performanceHistory) => performanceHistory,
    DashboardLoading(:final cachedPoints) => cachedPoints,
    DashboardError(:final cachedPoints) => cachedPoints,
    _ => null,
  };
}
