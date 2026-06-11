import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:dio/dio.dart';

class LeaderboardApiService {
  LeaderboardApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<LeaderboardResponse> fetchLeaderboard() async {
    if (!ApiEndpoints.isConfigured) {
      throw const LeaderBoardApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.getLeaderboardData,
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw LeaderBoardApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load leaderboard.',
          ),
        );
      }

      return LeaderboardResponse.fromJson(body);
    } on LeaderBoardApiException {
      rethrow;
    } on DioException catch (e) {
      throw LeaderBoardApiException(NetworkExceptions.getError(e));
    }
  }
}

class LeaderBoardApiException implements Exception {
  const LeaderBoardApiException(this.message);

  final String message;

  @override
  String toString() => message;
}