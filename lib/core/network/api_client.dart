import "package:dio/dio.dart";

import "dio_client.dart";

class ApiClient {
  final Dio _dio = DioClient().dio;

  Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  Future<Response> post(
    String endpoint,
    dynamic data, {
    Options? options,
  }) async {
    final resolved = data is FormData
        ? (options ?? Options()).copyWith(contentType: 'multipart/form-data')
        : options;
    return await _dio.post(endpoint, data: data, options: resolved);
  }

  Future<Response> put(String endpoint, dynamic data) async {
    final options = data is FormData
        ? Options(contentType: 'multipart/form-data')
        : null;
    return await _dio.put(endpoint, data: data, options: options);
  }

  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}
