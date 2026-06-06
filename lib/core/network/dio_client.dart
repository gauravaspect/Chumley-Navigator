import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'dio_interceptors.dart';

class DioClient {
  late Dio dio;
  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Content-Type": "application/json"},
      ),
    );
    dio.interceptors.add(DioInterceptor(dio));
  }
}
