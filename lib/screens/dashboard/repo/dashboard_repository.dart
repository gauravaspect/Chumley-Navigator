import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';

class DashboardRepository {
  DashboardRepository(this._apiService);

  final DashboardApiService _apiService;

  Future<UserModel?> readCachedProfile() => Prefs.getUser();

  Future<UserModel> fetchDashboardData({String dateRange = 'all_time'}) async {
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

  Future<EngineerPerformanceHistory?> readCachedPoints() => Prefs.getPoints();

  Future<EngineerPerformanceHistory> fetchPoints({int months = 12}) async {
    try {
      final points = await _apiService.fetchPoints(months: months);
      await Prefs.savePoints(points);
      return points;
    } on DashboardApiException {
      final cached = await readCachedPoints();
      if (cached != null && cached.engineerId.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<PpmJobTask>> fetchPpmJobs() {
    return _apiService.fetchPpmJobs();
  }

  Future<UserModel> refreshDashboardData({String dateRange = 'all_time'}) {
    return fetchDashboardData(dateRange: dateRange);
  }
}
