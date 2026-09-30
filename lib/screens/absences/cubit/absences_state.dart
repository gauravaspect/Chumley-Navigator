import 'package:chumley_navigator/models/list_absence_model.dart';
import 'package:equatable/equatable.dart';

sealed class AbsencesState extends Equatable {
  const AbsencesState();

  @override
  List<Object?> get props => [];
}

class AbsencesInitial extends AbsencesState {
  const AbsencesInitial();
}

class AbsencesLoading extends AbsencesState {
  const AbsencesLoading({this.cachedAbsences});

  final ListMyAbsenceResponse? cachedAbsences;

  @override
  List<Object?> get props => [cachedAbsences];
}

class AbsencesLoaded extends AbsencesState {
  const AbsencesLoaded({
    required this.response,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });

  final ListMyAbsenceResponse response;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;

  AbsencesLoaded copyWith({
    ListMyAbsenceResponse? response,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
  }) {
    return AbsencesLoaded(
      response: response ?? this.response,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError, // Nullify if not explicitly passed
      submitSuccess: submitSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
    response,
    isSubmitting,
    submitError,
    submitSuccess,
  ];
}

class AbsencesError extends AbsencesState {
  const AbsencesError({required this.message, this.cachedAbsences});

  final String message;
  final ListMyAbsenceResponse? cachedAbsences;

  @override
  List<Object?> get props => [message, cachedAbsences];
}

extension AbsencesStateX on AbsencesState {
  ListMyAbsenceResponse? get responseOrNull => switch (this) {
    AbsencesLoaded(:final response) => response,
    AbsencesLoading(:final cachedAbsences) => cachedAbsences,
    AbsencesError(:final cachedAbsences) => cachedAbsences,
    _ => null,
  };
}
