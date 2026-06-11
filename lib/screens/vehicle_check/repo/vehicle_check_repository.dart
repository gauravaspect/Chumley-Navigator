import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/models/vcr_submit_payload.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vehicle_check_api_service.dart';

class VehicleCheckRepository {
  VehicleCheckRepository(this._apiService);

  final VehicleCheckApiService _apiService;

  Future<VehicleResponse?> readCachedVehicleAllocations() =>
      Prefs.getVehicleAllocations();

  Future<VehicleResponse> fetchVehicleAllocations() async {
    try {
      final response = await _apiService.fetchVehicleAllocations();
      await Prefs.saveVehicleAllocations(response);
      return response;
    } on VehicleCheckApiException {
      final cached = await readCachedVehicleAllocations();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<VehicleResponse> refreshVehicleAllocations() =>
      fetchVehicleAllocations();

  Future<void> submitVcrInspection(VcrSubmitPayload payload) =>
      _apiService.submitVcrInspection(payload);
}
