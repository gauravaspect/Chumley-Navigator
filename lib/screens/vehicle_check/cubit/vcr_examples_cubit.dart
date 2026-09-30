import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_state.dart';
import 'package:chumley_navigator/screens/vehicle_check/repo/vcr_examples_repository.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VcrExamplesCubit extends Cubit<VcrExamplesState> {
  VcrExamplesCubit(this._repository) : super(const VcrExamplesInitial());

  final VcrExamplesRepository _repository;

  final Map<String, List<VcrExamplePhoto>> _sectionCache = {};
  final Map<String, VcrExamplesLoaded> _stepCache = {};

  Future<void> fetchExamplesForSections(List<String> sections) async {
    if (sections.isEmpty) return;

    final stepKey = sections.join('|');
    final cachedStep = _stepCache[stepKey];
    if (cachedStep != null) {
      emit(cachedStep);
      return;
    }

    emit(VcrExamplesLoading(sections: sections));

    try {
      final examplesBySection = <String, List<VcrExamplePhoto>>{};

      await Future.wait(
        sections.map((section) async {
          if (_sectionCache.containsKey(section)) {
            examplesBySection[section] = _sectionCache[section]!;
            return;
          }

          final examples = await _repository.fetchExamples(section);
          _sectionCache[section] = examples;
          examplesBySection[section] = examples;
        }),
      );

      final loadedState = VcrExamplesLoaded(
        sections: sections,
        examplesBySection: examplesBySection,
      );
      _stepCache[stepKey] = loadedState;
      emit(loadedState);
    } catch (e) {
      emit(VcrExamplesError(sections: sections, message: e.toString()));
    }
  }
}
