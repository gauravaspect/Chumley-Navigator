import 'package:chumley_navigator/screens/vehicle_check/service/vcr_examples_api_service.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';

class VcrExamplesRepository {
  VcrExamplesRepository(this._apiService);

  final VcrExamplesApiService _apiService;

  Future<List<VcrExamplePhoto>> fetchExamples(String section) {
    return _apiService.fetchExamples(section);
  }
}
