import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/models/vcr_submit_payload.dart';
import 'package:dio/dio.dart';

class VehicleCheckApiService {
  VehicleCheckApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<VehicleResponse> fetchVehicleAllocations() async {
    if (!ApiEndpoints.isConfigured) {
      throw const VehicleCheckApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.getVehicleAllocations);
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw VehicleCheckApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load vehicle allocations.',
          ),
        );
      }

      return VehicleResponse.fromJson(body);
    } on VehicleCheckApiException {
      rethrow;
    } on DioException catch (e) {
      throw VehicleCheckApiException(NetworkExceptions.getError(e));
    }
  }

  Future<void> submitVcrInspection(VcrSubmitPayload payload) async {
    if (!ApiEndpoints.isConfigured) {
      throw const VehicleCheckApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    if (payload.vehicleId.trim().isEmpty) {
      throw const VehicleCheckApiException(
        'Vehicle is required before submitting the inspection.',
      );
    }

    if (payload.files.isEmpty) {
      throw const VehicleCheckApiException(
        'Add at least one inspection photo before submitting.',
      );
    }

    for (final entry in payload.files) {
      final withinLimit =
          await ApiResponseHelper.isFileWithinUploadLimit(entry.file);
      if (!withinLimit) {
        throw VehicleCheckApiException(
          'Photo "${entry.slotId}" is too large. '
          '${ApiResponseHelper.fileSizeLabel(await entry.file.length())} — '
          'use images under 4 MB each.',
        );
      }
    }

    try {
      final formData = FormData.fromMap({
        'vehicle_id': payload.vehicleId.trim(),
        'description': payload.description.trim(),
        'internal_notes': payload.internalNotes.trim(),
        'inspection_result': payload.inspectionResult.trim(),
      });

      for (final entry in payload.files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              entry.file.path,
              filename: '${entry.slotId}.jpg',
            ),
          ),
        );
      }

      final response = await _apiClient.post(ApiEndpoints.submitVcr, formData);
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw VehicleCheckApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to submit vehicle inspection.',
            statusCode: response.statusCode,
          ),
        );
      }
    } on VehicleCheckApiException {
      rethrow;
    } on DioException catch (e) {
      throw VehicleCheckApiException(NetworkExceptions.getError(e));
    }
  }
}

class VehicleCheckApiException implements Exception {
  const VehicleCheckApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
