import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/service/dashboard_api_service.dart';
import 'package:chumley_navigator/screens/job_details/repo/appointments_repository.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';

class DashboardRepository {
  DashboardRepository(
    this._apiService, {
    AppointmentsRepository? appointmentsRepository,
  }) : _appointmentsRepository = appointmentsRepository;

  final DashboardApiService _apiService;
  final AppointmentsRepository? _appointmentsRepository;

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

  /// All engineer appointments (every status) via GET /api/engineer/appointments.
  Future<List<Appointment>> fetchAppointments({UserModel? profileFallback}) async {
    final repo = _appointmentsRepository;
    if (repo != null) {
      try {
        final list = await repo.listAppointments();
        if (list.isNotEmpty) return list;
      } on AppointmentApiException {
        // Fall through to profile payload.
      }
    }
    return profileFallback?.dashboard.appointmentsThisMonth ?? const [];
  }

  Future<UserModel> refreshDashboardData({String dateRange = 'all_time'}) {
    return fetchDashboardData(dateRange: dateRange);
  }
}
