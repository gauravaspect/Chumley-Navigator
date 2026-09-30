import "package:dio/dio.dart";

import "dio_client.dart";

class ApiClient {
  final Dio _dio = DioClient().dio;

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolved = data is FormData
        ? (options ?? Options()).copyWith(contentType: 'multipart/form-data')
        : options;
    return await _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: resolved,
    );
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
