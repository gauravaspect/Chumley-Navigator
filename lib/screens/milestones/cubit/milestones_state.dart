import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:equatable/equatable.dart';

sealed class MilestonesState extends Equatable {
  const MilestonesState();

  @override
  List<Object?> get props => [];
}

class MilestonesInitial extends MilestonesState {
  const MilestonesInitial();
}

class MilestonesLoading extends MilestonesState {
  const MilestonesLoading({this.cachedMilestones});

  final MilestonesResponse? cachedMilestones;

  @override
  List<Object?> get props => [cachedMilestones];
}

class MilestonesLoaded extends MilestonesState {
  const MilestonesLoaded(this.milestones);

  final MilestonesResponse milestones;

  @override
  List<Object?> get props => [milestones];
}

class MilestonesError extends MilestonesState {
  const MilestonesError({required this.message, this.cachedMilestones});

  final String message;
  final MilestonesResponse? cachedMilestones;

  @override
  List<Object?> get props => [message, cachedMilestones];
}

extension MilestonesStateX on MilestonesState {
  MilestonesResponse? get milestonesOrNull => switch (this) {
    MilestonesLoaded(:final milestones) => milestones,
    MilestonesLoading(:final cachedMilestones) => cachedMilestones,
    MilestonesError(:final cachedMilestones) => cachedMilestones,
    _ => null,
  };
}
