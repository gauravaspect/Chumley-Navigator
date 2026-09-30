import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:equatable/equatable.dart';

sealed class VcrExamplesState extends Equatable {
  const VcrExamplesState();

  @override
  List<Object?> get props => [];
}

class VcrExamplesInitial extends VcrExamplesState {
  const VcrExamplesInitial();
}

class VcrExamplesLoading extends VcrExamplesState {
  const VcrExamplesLoading({required this.sections});

  final List<String> sections;

  @override
  List<Object?> get props => [sections];
}

class VcrExamplesLoaded extends VcrExamplesState {
  const VcrExamplesLoaded({
    required this.sections,
    required this.examplesBySection,
  });

  final List<String> sections;
  final Map<String, List<VcrExamplePhoto>> examplesBySection;

  @override
  List<Object?> get props => [sections, examplesBySection];
}

class VcrExamplesError extends VcrExamplesState {
  const VcrExamplesError({required this.sections, required this.message});

  final List<String> sections;
  final String message;

  @override
  List<Object?> get props => [sections, message];
}
