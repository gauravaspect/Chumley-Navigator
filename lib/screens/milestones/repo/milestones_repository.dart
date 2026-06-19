import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:chumley_navigator/screens/milestones/service/milestones_api_service.dart';

class MilestonesRepository {
  MilestonesRepository(this._apiService);

  final MilestonesApiService _apiService;

  Future<MilestonesResponse?> readCachedMilestones() async {
    return await Prefs.getMilestonesCache();
  }

  Future<MilestonesResponse> fetchMilestones() async {
    try {
      final response = await _apiService.fetchMilestones();
      await Prefs.saveMilestonesCache(response);
      return response;
    } on MilestonesApiException {
      final cached = await readCachedMilestones();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<MilestonesResponse> refreshMilestones() => fetchMilestones();
}
