import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:dio/dio.dart';

class DashboardApiService {
  DashboardApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel> fetchProfile({String dateRange = 'all_time'}) async {
    if (!ApiEndpoints.isConfigured) {
      throw const DashboardApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    final authUser = await Prefs.getAuthUser();
    final engineerId = authUser?.engineerId.trim().isNotEmpty == true
        ? authUser!.engineerId
        : authUser?.id ?? '';

    if (engineerId.isEmpty) {
      throw const DashboardApiException(
        'Engineer profile is unavailable. Please sign in again.',
      );
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.profile(engineerId, dateRange: dateRange),
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw DashboardApiException(
          ApiResponseHelper.extractMessage(body, fallback: 'Unable to load dashboard.'),
        );
      }

      return UserModel.fromJson(body);
    } on DashboardApiException {
      rethrow;
    } on DioException catch (e) {
      throw DashboardApiException(NetworkExceptions.getError(e));
    }
  }
}

class DashboardApiException implements Exception {
  const DashboardApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
