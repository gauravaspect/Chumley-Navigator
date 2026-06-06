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
  const DashboardLoading({this.cachedUser});

  final UserModel? cachedUser;

  @override
  List<Object?> get props => [cachedUser];
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class DashboardError extends DashboardState {
  const DashboardError({
    required this.message,
    this.cachedUser,
  });

  final String message;
  final UserModel? cachedUser;

  @override
  List<Object?> get props => [message, cachedUser];
}

extension DashboardStateX on DashboardState {
  UserModel? get userOrNull => switch (this) {
    DashboardLoaded(:final user) => user,
    DashboardLoading(:final cachedUser) => cachedUser,
    DashboardError(:final cachedUser) => cachedUser,
    _ => null,
  };
}
