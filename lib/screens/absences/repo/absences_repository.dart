import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/screens/absences/service/absences_api_service.dart';

import '../../../models/list_absence_model.dart';

class AbsencesRepository {
  final AbsencesApiService _apiService;
  AbsencesRepository(this._apiService);

  Future<AbsenceCache?> readCachedAbsences() => Prefs.getAbsences();

  Future<ListMyAbsenceResponse> listMyAbsences() async {
    try {
      final response = await _apiService.listMyAbsences();
      await Prefs.saveAbsences(AbsenceCache.fromResponse(response));
      return response;
    } on AbsenceApiException {
      final cached = await readCachedAbsences();
      if (cached != null) {
        return cached.toResponse();
      }
      rethrow;
    }
  }

  Future<void> submitAbsence({
    required String type,
    required String description,
    required String start,
    required String end,
  }) async {
    await _apiService.submitAbsence(
      type: type,
      description: description,
      start: start,
      end: end,
    );
  }
}
