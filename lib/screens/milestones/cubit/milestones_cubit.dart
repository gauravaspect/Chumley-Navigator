import 'package:chumley_navigator/screens/milestones/cubit/milestones_state.dart';
import 'package:chumley_navigator/screens/milestones/repo/milestones_repository.dart';
import 'package:chumley_navigator/screens/milestones/service/milestones_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MilestonesCubit extends Cubit<MilestonesState> {
  MilestonesCubit(this._repository) : super(const MilestonesInitial());

  final MilestonesRepository _repository;

  Future<void> load() async {
    final cached = await _repository.readCachedMilestones();
    emit(MilestonesLoading(cachedMilestones: cached));

    try {
      final milestones = await _repository.fetchMilestones();
      emit(MilestonesLoaded(milestones));
    } on MilestonesApiException catch (e) {
      emit(MilestonesError(message: e.message, cachedMilestones: cached));
    } catch (_) {
      emit(
        MilestonesError(
          message: 'Unable to load milestones. Please try again.',
          cachedMilestones: cached,
        ),
      );
    }
  }

  Future<void> refresh() => load();
}
