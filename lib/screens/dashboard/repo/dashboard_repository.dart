import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';

class DashboardRepository {
  DashboardRepository(this._apiService);

  final DashboardApiService _apiService;

  Future<UserModel?> readCachedProfile() => Prefs.getUser();

  Future<UserModel> fetchDashboardData({
    String dateRange = 'all_time',
  }) async {
    try {
      final profile = await _apiService.fetchProfile(dateRange: dateRange);
      await Prefs.saveUser(profile);
      return profile;
    } on DashboardApiException {
      final cached = await readCachedProfile();
      if (cached != null && cached.id.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<UserModel> refreshDashboardData({String dateRange = 'all_time'}) {
    return fetchDashboardData(dateRange: dateRange);
  }
}
