import 'dart:developer';

import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:dio/dio.dart';

class FixedPriceApiService {
  final ApiClient _apiClient;

  FixedPriceApiService(this._apiClient);

  Future<List<FixedPriceModel>> fetchFixedPriceTrades() async {
    if (!ApiEndpoints.isConfigured) {
      throw const FixedPriceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.getFixedPriceTrades);
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw FixedPriceApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load fixed price trades.',
          ),
        );
      }

      return FixedPriceTradesResponse.fromJson(body).trades;
    } on FixedPriceApiException {
      rethrow;
    } on DioException catch (e) {
      throw FixedPriceApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw FixedPriceApiException(e.toString());
    }
  }

  Future<List<FixedPriceCategoryModel>> fetchFixedPriceCategories(
    String tradeId,
  ) async {
    if (!ApiEndpoints.isConfigured) {
      throw const FixedPriceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFixedPriceCategories,
        queryParameters: {'trade_id': tradeId},
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw FixedPriceApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load categories.',
          ),
        );
      }

      return FixedPriceCategoriesResponse.fromJson(body).categories;
    } on FixedPriceApiException {
      rethrow;
    } on DioException catch (e) {
      throw FixedPriceApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw FixedPriceApiException(e.toString());
    }
  }

  Future<List<FixedPriceWorkTypeModel>> fetchFixedPriceWorkTypes(
    String groupId,
  ) async {
    if (!ApiEndpoints.isConfigured) {
      throw const FixedPriceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.getFixedPriceWorkTypes,
        queryParameters: {'group_id': groupId},
      );
      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw FixedPriceApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to load work types.',
          ),
        );
      }

      return FixedPriceWorkTypesResponse.fromJson(body).workTypes;
    } on FixedPriceApiException {
      rethrow;
    } on DioException catch (e) {
      throw FixedPriceApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw FixedPriceApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> submitFixedPriceWorkOrder({
    required FixedPriceSubmitPayload payload,
    required FixedPriceSalesforceContext context,
    bool dryRun = false,
  }) async {
    if (!ApiEndpoints.isConfigured) {
      throw const FixedPriceApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    final validationErrors = payload.validate(salesforceContext: context);
    if (validationErrors.isNotEmpty) {
      throw FixedPriceApiException(validationErrors.first);
    }

    try {
      final requestBody = payload.toSubmitJson(context: context);
      log('submitFixedPriceWorkOrder request dry_run=$dryRun');
      log('submitFixedPriceWorkOrder request body: $requestBody');

      final response = await _apiClient.post(
        ApiEndpoints.submitWorkOrder,
        requestBody,
        queryParameters: {'dry_run': dryRun},
      );
      log('submitFixedPriceWorkOrder response status: ${response.statusCode}');
      log('submitFixedPriceWorkOrder response data: ${response.data}');

      final body = ApiResponseHelper.toMap(response.data);

      if (body['success'] == false) {
        throw FixedPriceApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Unable to submit fixed price work order.',
            statusCode: response.statusCode,
          ),
        );
      }

      return body;
    } on FixedPriceApiException {
      rethrow;
    } on DioException catch (e) {
      log('submitFixedPriceWorkOrder error: ${NetworkExceptions.getError(e)}');
      if (e.response != null) {
        log(
          'submitFixedPriceWorkOrder error status: ${e.response?.statusCode}',
        );
        log('submitFixedPriceWorkOrder error data: ${e.response?.data}');
      }
      throw FixedPriceApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw FixedPriceApiException(e.toString());
    }
  }
}

class FixedPriceApiException implements Exception {
  const FixedPriceApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
