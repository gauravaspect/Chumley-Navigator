import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:dio/dio.dart';

class MilestonesApiService {
  MilestonesApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<MilestonesResponse> fetchMilestones() async {
    if (!ApiEndpoints.isConfigured) {
      throw const MilestonesApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    final authUser = await Prefs.getAuthUser();
    final engineerId = authUser?.engineerId.trim().isNotEmpty == true
        ? authUser!.engineerId
        : authUser?.id ?? '';

    if (engineerId.isEmpty) {
      throw const MilestonesApiException(
        'Engineer profile is unavailable. Please sign in again.',
      );
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.getMilestones(engineerId),
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw MilestonesApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load milestones.',
          ),
        );
      }

      return MilestonesResponse.fromJson(body);
    } on MilestonesApiException {
      rethrow;
    } on DioException catch (e) {
      throw MilestonesApiException(NetworkExceptions.getError(e));
    }
  }
}

class MilestonesApiException implements Exception {
  const MilestonesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
