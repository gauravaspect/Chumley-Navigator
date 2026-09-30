import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/models/list_absence_model.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response_helper.dart';
import '../../../core/network/network_exceptions.dart';

class AbsencesApiService {
  final ApiClient _apiClient;
  AbsencesApiService(this._apiClient);

  Future<ListMyAbsenceResponse> listMyAbsences() async {
    if (!ApiEndpoints.isConfigured) {
      throw const AbsenceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }
    try {
      final response = await _apiClient.get(ApiEndpoints.listMyAbsences);
      final body = ApiResponseHelper.toMap(response.data);
      return ListMyAbsenceResponse.fromJson(body);
    } on AbsenceApiException {
      rethrow;
    } on DioException catch (e) {
      throw AbsenceApiException(NetworkExceptions.getError(e));
    }
  }

  Future<void> submitAbsence({
    required String type,
    required String description,
    required String start,
    required String end,
  }) async {
    if (!ApiEndpoints.isConfigured) {
      throw const AbsenceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }
    try {
      final response = await _apiClient.post(ApiEndpoints.postMyAbsence, {
        'type': type,
        'start': start,
        'end': end,
        'description': description,
      });
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw AbsenceApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to submit absence.',
          ),
        );
      }
    } on AbsenceApiException {
      rethrow;
    } on DioException catch (e) {
      throw AbsenceApiException(NetworkExceptions.getError(e));
    }
  }
}

class AbsenceApiException implements Exception {
  const AbsenceApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
