import 'package:dio/dio.dart';

import '../storage/prefs.dart';
import 'api_endpoints.dart';

class DioInterceptor extends Interceptor {
  static Future<void> Function()? onUnauthorized;

  final Dio dio;

  DioInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiEndpoints.skipsSessionAuth(options.uri.path)) {
      final token = await Prefs.getSessionToken();
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isExchange = ApiEndpoints.skipsSessionAuth(
      err.requestOptions.uri.path,
    );

    if (err.response?.statusCode == 401 && !isExchange) {
      await Prefs.clearAuth();
      await onUnauthorized?.call();
    }

    return handler.next(err);
  }
}
