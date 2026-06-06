import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/service/auth_service.dart';
import 'package:dio/dio.dart';

import 'package:chumley_navigator/core/app_constants.dart';
import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/core/utils/id_token_helper.dart';

/// Microsoft token exchange — see MOBILE_APP_AUTH_GUIDE_V2.md §6–7, §11.
class LoginApiService {
  LoginApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginExchangeResponse> exchangeTokens(MicrosoftAuthTokens tokens) async {
    if (!ApiEndpoints.isConfigured) {
      throw const LoginApiException(
        'API server URL is not configured. Set API_BASE_URL when running the app.',
      );
    }

    if (IdTokenHelper.isExpired(tokens.idToken)) {
      throw const LoginApiException(
        'Your Microsoft sign-in expired. Please sign in again.',
      );
    }

    final audience = IdTokenHelper.readAudience(tokens.idToken);
    if (audience != null &&
        audience.isNotEmpty &&
        audience != AppConstants.clientId) {
      throw const LoginApiException(
        'Microsoft sign-in used the wrong app registration. Contact IT to verify the mobile Azure client ID.',
      );
    }

    try {
      final response = await _apiClient.post(ApiEndpoints.mobileExchange, {
        'id_token': tokens.idToken,
        'access_token': tokens.accessToken,
      });
      final body = ApiResponseHelper.toMap(response.data);
      final sessionToken = (body['session_token'] ?? '').toString();
      final userBody = body['user'];

      if (sessionToken.isEmpty) {
        throw const LoginApiException('Missing session token from server.');
      }
      if (userBody is! Map) {
        throw const LoginApiException('Missing user details from server.');
      }

      final user = AuthUser.fromJson(Map<String, dynamic>.from(userBody));
      if (user.role != 'engineer') {
        throw const LoginApiException(
          'This app is for Aspect field engineers. Please use the web dashboard to sign in as a manager or admin.',
        );
      }

      return LoginExchangeResponse(
        sessionToken: sessionToken,
        expiresAt: DateTime.tryParse((body['expires_at'] ?? '').toString()),
        user: user,
      );
    } on DioException catch (e) {
      final data = ApiResponseHelper.toMap(e.response?.data);
      final error = (data['error'] ?? data['message'] ?? '').toString();
      throw LoginApiException(
        _messageForError(
          error: error,
          exception: e,
          statusCode: e.response?.statusCode,
          detectedRole: (data['detected_role'] ?? '').toString(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    if (!ApiEndpoints.isConfigured) return;
    try {
      await _apiClient.post(ApiEndpoints.signOut, {});
    } on DioException {
      // Local sign-out still proceeds if the server is unreachable.
    }
  }

  String _messageForError({
    required String error,
    required DioException exception,
    required int? statusCode,
    required String detectedRole,
  }) {
    final code = error.trim().toLowerCase().replaceAll(' ', '_');

    switch (code) {
      case 'invalid_token':
        return 'Sign-in could not be verified. Please try again.';
      case 'not_an_engineer':
        if (detectedRole.isNotEmpty) {
          return 'This app is for Aspect field engineers (your account is registered as $detectedRole). Please use the web dashboard to sign in.';
        }
        return 'This app is for Aspect field engineers. Please use the web dashboard to sign in as a manager or admin.';
      case 'user_not_found':
        return 'Your Microsoft account is not linked to an active engineer record. Contact your manager or IT.';
      case 'expired_token':
        return 'Your Microsoft sign-in expired. Please sign in again.';
    }

    if (statusCode == 403) {
      return 'You do not have access to the engineer app.';
    }

    if (statusCode == 401) {
      return 'Your Microsoft sign-in expired. Please sign in again.';
    }

    return NetworkExceptions.getError(exception);
  }
}

class LoginExchangeResponse {
  const LoginExchangeResponse({
    required this.sessionToken,
    required this.user,
    this.expiresAt,
  });

  final String sessionToken;
  final DateTime? expiresAt;
  final AuthUser user;
}

class LoginApiException implements Exception {
  const LoginApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
