import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/chumley_chat_models.dart';
import 'package:chumley_navigator/screens/chumley_ai/auth/chumley_auth_provider.dart';
import 'package:dio/dio.dart';

/// REST client for the Orchestrator Chumley Chat service (chat JWT auth).
class ChumleyChatApiService {
  ChumleyChatApiService(this._authProvider) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${ApiEndpoints.chumleyChatBaseUrl}/',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  final ChumleyAuthProvider _authProvider;
  late final Dio _dio;

  Future<Options> _authOptions({bool forceRefresh = false}) async {
    final token = await _authProvider.fetchToken(forceRefresh: forceRefresh);
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response<T>> _authed<T>(
    Future<Response<T>> Function(Options options) call,
  ) async {
    try {
      return await call(await _authOptions());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          return await call(await _authOptions(forceRefresh: true));
        } on DioException catch (retry) {
          throw ChumleyChatApiException(NetworkExceptions.getError(retry));
        }
      }
      throw ChumleyChatApiException(NetworkExceptions.getError(e));
    }
  }

  Future<ChumleyChatUser> me() async {
    final response = await _authed((o) => _dio.get<dynamic>('me', options: o));
    return ChumleyChatUser.fromJson(ApiResponseHelper.toMap(response.data));
  }

  Future<List<ChatConversation>> listConversations() async {
    final response =
        await _authed((o) => _dio.get<dynamic>('conversations', options: o));
    final body = ApiResponseHelper.toMap(response.data);
    final list = body['conversations'] as List? ?? [];
    return list
        .whereType<Map>()
        .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChatConversation> startDm(String peerEmail) async {
    final response = await _authed(
      (o) => _dio.post<dynamic>(
        'conversations',
        data: {'peer_email': peerEmail},
        options: o,
      ),
    );
    return ChatConversation.fromJson(ApiResponseHelper.toMap(response.data));
  }

  Future<ChatConversation> createGroup({
    required String name,
    required List<String> memberEmails,
  }) async {
    final response = await _authed(
      (o) => _dio.post<dynamic>(
        'conversations/group',
        data: {'name': name, 'member_emails': memberEmails},
        options: o,
      ),
    );
    return ChatConversation.fromJson(ApiResponseHelper.toMap(response.data));
  }

  Future<({List<ChatMessage> messages, bool hasMore})> listMessages(
    String conversationId, {
    int limit = 50,
    String? before,
  }) async {
    final response = await _authed(
      (o) => _dio.get<dynamic>(
        'conversations/$conversationId/messages',
        queryParameters: {
          'limit': limit,
          if (before != null && before.isNotEmpty) 'before': before,
        },
        options: o,
      ),
    );
    final body = ApiResponseHelper.toMap(response.data);
    final list = body['messages'] as List? ?? [];
    final messages = list
        .whereType<Map>()
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (messages: messages, hasMore: body['has_more'] == true);
  }

  Future<void> markRead(String conversationId) async {
    await _authed(
      (o) => _dio.post<dynamic>(
        'conversations/$conversationId/mark-read',
        data: {},
        options: o,
      ),
    );
  }

  Future<List<ChumleyChatUser>> searchUsers(String query) async {
    final response = await _authed(
      (o) => _dio.get<dynamic>(
        'users',
        queryParameters: {if (query.trim().isNotEmpty) 'q': query.trim()},
        options: o,
      ),
    );
    final body = ApiResponseHelper.toMap(response.data);
    final list = body['users'] as List? ?? [];
    return list
        .whereType<Map>()
        .map((e) => ChumleyChatUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> uploadMedia(MultipartFile file) async {
    final token = await _authProvider.fetchToken();
    final form = FormData.fromMap({'file': file});
    try {
      final response = await _dio.post<dynamic>(
        'media/upload',
        data: form,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );
      return ApiResponseHelper.toMap(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final refreshed = await _authProvider.fetchToken(forceRefresh: true);
        final response = await _dio.post<dynamic>(
          'media/upload',
          data: form,
          options: Options(
            headers: {'Authorization': 'Bearer $refreshed'},
            contentType: 'multipart/form-data',
          ),
        );
        return ApiResponseHelper.toMap(response.data);
      }
      throw ChumleyChatApiException(NetworkExceptions.getError(e));
    }
  }
}

class ChumleyChatApiException implements Exception {
  const ChumleyChatApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
