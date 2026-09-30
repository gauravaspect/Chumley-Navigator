import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
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
  const DashboardLoading({
    this.cachedUser,
    this.cachedPoints,
    this.cachedPpmTasks = const [],
    this.cachedAppointments = const [],
  });

  final UserModel? cachedUser;
  final EngineerPerformanceHistory? cachedPoints;
  final List<PpmJobTask> cachedPpmTasks;
  final List<Appointment> cachedAppointments;

  @override
  List<Object?> get props => [
    cachedUser,
    cachedPoints,
    cachedPpmTasks,
    cachedAppointments,
  ];
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.user,
    required this.performanceHistory,
    required this.appointments,
    this.ppmTasks = const [],
  });

  final UserModel user;
  final EngineerPerformanceHistory performanceHistory;
  final List<Appointment> appointments;
  final List<PpmJobTask> ppmTasks;

  @override
  List<Object?> get props => [user, performanceHistory, appointments, ppmTasks];
}

class DashboardError extends DashboardState {
  const DashboardError({
    required this.message,
    this.cachedUser,
    this.cachedPoints,
    this.cachedPpmTasks = const [],
    this.cachedAppointments = const [],
  });

  final String message;
  final UserModel? cachedUser;
  final EngineerPerformanceHistory? cachedPoints;
  final List<PpmJobTask> cachedPpmTasks;
  final List<Appointment> cachedAppointments;

  @override
  List<Object?> get props => [
    message,
    cachedUser,
    cachedPoints,
    cachedPpmTasks,
    cachedAppointments,
  ];
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

  List<PpmJobTask> get ppmTasksOrEmpty => switch (this) {
    DashboardLoaded(:final ppmTasks) => ppmTasks,
    DashboardLoading(:final cachedPpmTasks) => cachedPpmTasks,
    DashboardError(:final cachedPpmTasks) => cachedPpmTasks,
    _ => const [],
  };

  List<Appointment> get appointmentsOrEmpty => switch (this) {
    DashboardLoaded(:final appointments) => appointments,
    DashboardLoading(:final cachedAppointments) => cachedAppointments,
    DashboardError(:final cachedAppointments) => cachedAppointments,
    _ => const [],
  };

  bool get isAppointmentsLoading => switch (this) {
    DashboardInitial() => true,
    DashboardLoading() => true,
    _ => false,
  };
}
