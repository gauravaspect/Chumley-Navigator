import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:dio/dio.dart';

/// Mints and caches short-lived Chumley Chat JWTs from Navigator.
class ChumleyAuthProvider {
  ChumleyAuthProvider(this._apiClient);

  final ApiClient _apiClient;

  String? _token;
  DateTime? _expiresAt;
  Future<String>? _inflight;

  Future<String> fetchToken({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _token != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(_expiresAt!)) {
      return _token!;
    }

    _inflight ??= _mint().whenComplete(() => _inflight = null);
    return _inflight!;
  }

  Future<String> _mint() async {
    if (!ApiEndpoints.isConfigured) {
      throw const ChumleyAuthException(
        'API server URL is not configured.',
      );
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.chatToken);
      final body = ApiResponseHelper.toMap(response.data);
      final token = (body['token'] ?? '').toString();
      if (token.isEmpty) {
        throw const ChumleyAuthException('Chat token missing from response.');
      }
      final ttl = (body['expires_in'] as num?)?.toInt() ?? 300;
      _token = token;
      _expiresAt = DateTime.now().add(Duration(seconds: (ttl - 30).clamp(30, ttl)));
      return token;
    } on DioException catch (e) {
      throw ChumleyAuthException(NetworkExceptions.getError(e));
    } on ChumleyAuthException {
      rethrow;
    } catch (e) {
      throw ChumleyAuthException(e.toString());
    }
  }

  void clear() {
    _token = null;
    _expiresAt = null;
    _inflight = null;
  }
}

class ChumleyAuthException implements Exception {
  const ChumleyAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
