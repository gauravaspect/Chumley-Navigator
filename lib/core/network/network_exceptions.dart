import 'package:dio/dio.dart';

import 'api_response_helper.dart';

class NetworkExceptions {
  static String getError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return "Connection Timed Out";

      case DioExceptionType.receiveTimeout:
        return "Server timeout";

      case DioExceptionType.badResponse:
        return ApiResponseHelper.extractMessage(
          e.response?.data,
          fallback: "Server error",
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return "Cannot reach the server. Check your connection and API URL.";

      case DioExceptionType.cancel:
        return "Request was cancelled.";

      case DioExceptionType.badCertificate:
        return "Secure connection failed. Contact support if this continues.";

      default:
        return "Unexpected Error occurred";
    }
  }
}
