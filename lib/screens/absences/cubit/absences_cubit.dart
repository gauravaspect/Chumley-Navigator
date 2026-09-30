import 'package:chumley_navigator/screens/absences/cubit/absences_state.dart';
import 'package:chumley_navigator/screens/absences/repo/absences_repository.dart';
import 'package:chumley_navigator/screens/absences/service/absences_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AbsencesCubit extends Cubit<AbsencesState> {
  AbsencesCubit(this._repository) : super(const AbsencesInitial());

  final AbsencesRepository _repository;

  Future<void> load() async {
    final cached = await _repository.readCachedAbsences();
    emit(AbsencesLoading(cachedAbsences: cached?.toResponse()));

    try {
      final response = await _repository.listMyAbsences();
      emit(AbsencesLoaded(response: response));
    } on AbsenceApiException catch (e) {
      emit(
        AbsencesError(message: e.message, cachedAbsences: cached?.toResponse()),
      );
    } catch (_) {
      emit(
        AbsencesError(
          message: 'Unable to load absences. Please try again.',
          cachedAbsences: cached?.toResponse(),
        ),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> submitAbsence({
    required String type,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required bool wholeDay,
  }) async {
    final currentState = state;
    // We allow submission if we are loaded or if there is cached data on error/loading
    final previousResponse = currentState.responseOrNull;
    if (previousResponse == null) return;

    // Transition to loaded with submitting = true
    emit(AbsencesLoaded(response: previousResponse, isSubmitting: true));

    final startStr = _formatDateTime(
      startDate,
      wholeDay ? null : startTime,
      isEnd: false,
    );
    final endStr = _formatDateTime(
      endDate,
      wholeDay ? null : endTime,
      isEnd: true,
    );

    try {
      await _repository.submitAbsence(
        type: type,
        description: description,
        start: startStr,
        end: endStr,
      );

      emit(
        AbsencesLoaded(
          response: previousResponse,
          isSubmitting: false,
          submitSuccess: true,
        ),
      );
      // Reload the absences list from server to get updated data
      await load();
    } on AbsenceApiException catch (e) {
      emit(
        AbsencesLoaded(
          response: previousResponse,
          isSubmitting: false,
          submitError: e.message,
        ),
      );
    } catch (_) {
      emit(
        AbsencesLoaded(
          response: previousResponse,
          isSubmitting: false,
          submitError: 'Unable to submit absence. Please try again.',
        ),
      );
    }
  }

  void resetSubmitStatus() {
    final currentState = state;
    if (currentState is AbsencesLoaded) {
      emit(currentState.copyWith(submitSuccess: false, submitError: null));
    }
  }

  String _formatDateTime(
    DateTime date,
    TimeOfDay? time, {
    required bool isEnd,
  }) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    if (time == null) {
      return isEnd
          ? '$year-$month-${day}T23:59:59Z'
          : '$year-$month-${day}T00:00:00Z';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$year-$month-${day}T$hour:$minute:00Z';
  }
}
