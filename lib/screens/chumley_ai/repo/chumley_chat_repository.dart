import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/models/chumley_chat_models.dart';
import 'package:chumley_navigator/models/navigator_ai_models.dart';
import 'package:chumley_navigator/screens/chumley_ai/auth/chumley_auth_provider.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/chumley_chat_api_service.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/chumley_chat_socket.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/navigator_chat_api_service.dart';
import 'package:chumley_navigator/screens/chumley_ai/service/navigator_role_mapping.dart';

class ChumleyChatRepository {
  ChumleyChatRepository({
    required ChumleyAuthProvider authProvider,
    required NavigatorChatApiService navigatorApi,
    required ChumleyChatApiService chumleyApi,
  }) : _authProvider = authProvider,
       _navigatorApi = navigatorApi,
       _chumleyApi = chumleyApi;

  final ChumleyAuthProvider _authProvider;
  final NavigatorChatApiService _navigatorApi;
  final ChumleyChatApiService _chumleyApi;

  ChumleyChatSocket? _socket;

  Future<AuthUser?> currentUser() => Prefs.getAuthUser();

  Future<bool> fetchChumleyChatEnabled() =>
      _navigatorApi.fetchChumleyChatPermission();

  Future<DailyBriefing> fetchDailyBriefing() =>
      _navigatorApi.fetchDailyBriefing();

  Future<bool> navigatorHealthOk() => _navigatorApi.healthOk();

  Future<List<NavigatorAiConversation>> listAiConversations(String email) =>
      _navigatorApi.listConversations(email);

  Future<NavigatorAiConversation> createAiConversation(String email) =>
      _navigatorApi.createConversation(email);

  Future<List<NavigatorAiMessage>> listAiMessages(String id) =>
      _navigatorApi.listMessages(id);

  Future<({String? error, String? mappedRole})> resolveNavigatorRole(
    AuthUser user,
  ) async {
    final error = NavigatorRoleMapping.validateForQuery(
      appRole: user.role,
      engineerId: user.engineerId,
      tradeGroups: user.tradeGroups,
    );
    if (error != null) return (error: error, mappedRole: null);
    return (error: null, mappedRole: NavigatorRoleMapping.mapRole(user.role));
  }

  Future<Map<String, dynamic>> queryAi({
    required String query,
    required String role,
    required String conversationId,
    required AuthUser user,
  }) {
    return _navigatorApi.query(
      query: query,
      role: role,
      conversationId: conversationId,
      userEmail: user.email,
      engineerId: user.engineerId,
      tradeGroup: user.tradeGroups.isNotEmpty ? user.tradeGroups.first : null,
      tradeGroups: user.tradeGroups.isNotEmpty ? user.tradeGroups : null,
    );
  }

  Future<ChumleyChatUser> chumleyMe() => _chumleyApi.me();

  Future<List<ChatConversation>> listChumleyConversations() =>
      _chumleyApi.listConversations();

  Future<ChatConversation> startDm(String peerEmail) =>
      _chumleyApi.startDm(peerEmail);

  Future<({List<ChatMessage> messages, bool hasMore})> listChumleyMessages(
    String id,
  ) => _chumleyApi.listMessages(id);

  Future<void> markChumleyRead(String id) => _chumleyApi.markRead(id);

  Future<List<ChumleyChatUser>> searchUsers(String q) =>
      _chumleyApi.searchUsers(q);

  Future<void> connectSocket({
    required void Function(Map<String, dynamic> frame) onFrame,
    void Function(bool connected)? onConnectionChanged,
  }) async {
    await _socket?.dispose();
    _socket = ChumleyChatSocket(
      authProvider: _authProvider,
      onFrame: onFrame,
      onConnectionChanged: onConnectionChanged,
    );
    await _socket!.connect();
  }

  void sendChumleyWsMessage({
    required String conversationId,
    required String text,
    String? clientId,
  }) {
    _socket?.sendMessage(
      conversationId: conversationId,
      text: text,
      clientId: clientId,
    );
  }

  Future<void> disconnectSocket() async {
    await _socket?.dispose();
    _socket = null;
  }

  void clearSession() {
    _authProvider.clear();
  }

  Future<void> dispose() async {
    await disconnectSocket();
    clearSession();
  }
}
