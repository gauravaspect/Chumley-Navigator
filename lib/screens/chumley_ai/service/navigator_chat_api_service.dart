import 'package:chumley_navigator/core/network/api_client.dart';
import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:chumley_navigator/core/network/network_exceptions.dart';
import 'package:chumley_navigator/models/navigator_ai_models.dart';
import 'package:dio/dio.dart';

class NavigatorChatApiService {
  NavigatorChatApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<bool> fetchChumleyChatPermission() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.permissionsMe);
      final body = ApiResponseHelper.toMap(response.data);
      final permissions = body['permissions'];
      if (permissions is Map) {
        return permissions['chumley_chat.use'] == true;
      }
      return false;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<DailyBriefing> fetchDailyBriefing() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dailyBriefing);
      final body = ApiResponseHelper.toMap(response.data);
      if (body['success'] == false) {
        throw NavigatorChatApiException(
          ApiResponseHelper.extractMessage(
            body,
            fallback: 'Briefing unavailable',
          ),
        );
      }
      return DailyBriefing.fromJson(body);
    } on NavigatorChatApiException {
      rethrow;
    } on DioException catch (e) {
      throw NavigatorChatApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw NavigatorChatApiException(e.toString());
    }
  }

  Future<bool> healthOk() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.navigatorHealth);
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }

  Future<List<NavigatorAiConversation>> listConversations(String userEmail) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.navigatorConversations,
        queryParameters: {'user_email': userEmail},
      );
      final data = response.data;
      final list = data is List
          ? data
          : (ApiResponseHelper.toMap(data)['conversations'] as List? ?? []);
      return list
          .whereType<Map>()
          .map((e) => NavigatorAiConversation.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } on DioException catch (e) {
      throw NavigatorChatApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw NavigatorChatApiException(e.toString());
    }
  }

  Future<NavigatorAiConversation> createConversation(String userEmail) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.navigatorConversations,
        {'user_email': userEmail},
      );
      final body = ApiResponseHelper.toMap(response.data);
      return NavigatorAiConversation.fromJson(body);
    } on DioException catch (e) {
      throw NavigatorChatApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw NavigatorChatApiException(e.toString());
    }
  }

  Future<List<NavigatorAiMessage>> listMessages(String conversationId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.navigatorConversationMessages(conversationId),
      );
      final data = response.data;
      final list = data is List
          ? data
          : (ApiResponseHelper.toMap(data)['messages'] as List? ?? []);
      return list
          .whereType<Map>()
          .map((e) => NavigatorAiMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw NavigatorChatApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw NavigatorChatApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> query({
    required String query,
    required String role,
    required String conversationId,
    required String userEmail,
    String? engineerId,
    String? tradeGroup,
    List<String>? tradeGroups,
  }) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.navigatorQuery, {
        'query': query,
        'role': role,
        'conversation_id': conversationId,
        'user_email': userEmail,
        if (engineerId != null && engineerId.isNotEmpty) 'engineer_id': engineerId,
        if (tradeGroup != null && tradeGroup.isNotEmpty) 'trade_group': tradeGroup,
        if (tradeGroups != null && tradeGroups.isNotEmpty) 'trade_groups': tradeGroups,
        'date_range': 'all_time',
      });
      return ApiResponseHelper.toMap(response.data);
    } on DioException catch (e) {
      throw NavigatorChatApiException(NetworkExceptions.getError(e));
    } catch (e) {
      throw NavigatorChatApiException(e.toString());
    }
  }
}

class NavigatorChatApiException implements Exception {
  const NavigatorChatApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
