import 'package:chumley_navigator/models/chumley_chat_models.dart';
import 'package:chumley_navigator/models/navigator_ai_models.dart';
import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/screens/chumley_ai/repo/chumley_chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ChumleyChatCubit extends Cubit<ChumleyChatState> {
  ChumleyChatCubit(this._repository) : super(const ChumleyChatState());

  final ChumleyChatRepository _repository;
  final _uuid = const Uuid();

  Future<void> initialize() async {
    final user = await _repository.currentUser();
    emit(state.copyWith(user: user));

    // Always enable Chats for mobile; backend chat-token still enforces access.
    emit(state.copyWith(chumleyChatEnabled: true, permissionsLoaded: true));

    await Future.wait([
      loadBriefing(),
      checkNavigatorHealth(),
      if (user != null && user.email.isNotEmpty) loadAiConversations(),
      _bootstrapChumley(),
    ]);
  }

  Future<void> selectTab(ChumleyPanelTab tab) async {
    emit(state.copyWith(activeTab: tab));
    if (tab == ChumleyPanelTab.insights && state.briefing == null) {
      await loadBriefing();
    }
    if (tab == ChumleyPanelTab.aiChat) {
      await checkNavigatorHealth();
      if (state.aiConversations.isEmpty) {
        await loadAiConversations();
      }
    }
    if (tab == ChumleyPanelTab.chats) {
      await refreshChumleyConversations();
    }
  }

  Future<void> loadBriefing() async {
    emit(state.copyWith(briefingLoading: true, clearBriefingError: true));
    try {
      final briefing = await _repository.fetchDailyBriefing();
      emit(state.copyWith(briefing: briefing, briefingLoading: false));
    } catch (e) {
      emit(state.copyWith(briefingLoading: false, briefingError: e.toString()));
    }
  }

  Future<void> checkNavigatorHealth() async {
    final ok = await _repository.navigatorHealthOk();
    emit(state.copyWith(navigatorOnline: ok));
  }

  Future<void> loadAiConversations() async {
    final user = state.user;
    if (user == null || user.email.isEmpty) return;
    emit(state.copyWith(aiLoading: true, clearAiError: true));
    try {
      var list = await _repository.listAiConversations(user.email);
      if (list.isEmpty) {
        final created = await _repository.createAiConversation(user.email);
        list = [created];
      }
      final activeId = state.activeAiConversationId ?? list.first.id;
      emit(
        state.copyWith(
          aiConversations: list,
          activeAiConversationId: activeId,
          aiLoading: false,
        ),
      );
      await selectAiConversation(activeId);
    } catch (e) {
      emit(state.copyWith(aiLoading: false, aiError: e.toString()));
    }
  }

  Future<void> createAiConversation() async {
    final user = state.user;
    if (user == null || user.email.isEmpty) return;
    try {
      final created = await _repository.createAiConversation(user.email);
      emit(
        state.copyWith(
          aiConversations: [created, ...state.aiConversations],
          activeAiConversationId: created.id,
          aiMessages: const [],
          showAiPastChats: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(aiError: e.toString()));
    }
  }

  void toggleAiPastChats() {
    emit(state.copyWith(showAiPastChats: !state.showAiPastChats));
  }

  void dismissAiPastChats() {
    emit(state.copyWith(showAiPastChats: false));
  }

  Future<void> selectAiConversation(String id) async {
    emit(
      state.copyWith(
        activeAiConversationId: id,
        aiLoading: true,
        showAiPastChats: false,
        clearAiError: true,
      ),
    );
    try {
      final messages = await _repository.listAiMessages(id);
      emit(state.copyWith(aiMessages: messages, aiLoading: false));
    } catch (e) {
      emit(state.copyWith(aiLoading: false, aiError: e.toString()));
    }
  }

  Future<void> sendAiMessage(String text) async {
    final trimmed = text.trim();
    final user = state.user;
    final conversationId = state.activeAiConversationId;
    if (trimmed.isEmpty || user == null || conversationId == null) return;
    if (!state.navigatorOnline) {
      emit(state.copyWith(aiError: 'Navigator unavailable'));
      return;
    }

    final roleResult = await _repository.resolveNavigatorRole(user);
    if (roleResult.error != null) {
      emit(state.copyWith(aiError: roleResult.error));
      return;
    }

    final userMsg = NavigatorAiMessage(
      role: 'user',
      content: trimmed,
      timestamp: DateTime.now(),
    );

    var conversations = [...state.aiConversations];
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx >= 0 && conversations[idx].title == 'New Chat') {
      final title = trimmed.length > 40
          ? '${trimmed.substring(0, 40)}...'
          : trimmed;
      conversations[idx] = conversations[idx].copyWith(title: title);
    }

    emit(
      state.copyWith(
        aiMessages: [...state.aiMessages, userMsg],
        aiConversations: conversations,
        aiSending: true,
        clearAiError: true,
      ),
    );

    try {
      final data = await _repository.queryAi(
        query: trimmed,
        role: roleResult.mappedRole!,
        conversationId: conversationId,
        user: user,
      );

      var activeId = conversationId;
      final newId = data['conversation_id']?.toString();
      if (newId != null && newId.isNotEmpty && newId != conversationId) {
        activeId = newId;
        conversations = conversations
            .map((c) => c.id == conversationId ? c.copyWith(id: newId) : c)
            .toList();
      }

      final answer =
          (data['answer'] ?? data['message'] ?? 'No response from AI.')
              .toString();
      final recommendation = data['recommendation']?.toString();
      final content = recommendation == null || recommendation.isEmpty
          ? answer
          : '$answer\n\n**Recommendation:** $recommendation';
      final followUps = data['follow_up_prompts'] is List
          ? (data['follow_up_prompts'] as List)
                .map((e) => e.toString())
                .toList()
          : <String>[];
      final vizRaw = data['visualization'];
      final visualizations = vizRaw is List
          ? vizRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];

      final assistant = NavigatorAiMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
        followUps: followUps,
        visualizations: visualizations,
      );

      emit(
        state.copyWith(
          aiConversations: conversations,
          activeAiConversationId: activeId,
          aiMessages: [...state.aiMessages, assistant],
          aiSending: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          aiSending: false,
          aiError: e.toString(),
          aiMessages: [
            ...state.aiMessages,
            NavigatorAiMessage(
              role: 'assistant',
              content:
                  "I wasn't able to process that request. Please try again.\n\nError: $e",
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _bootstrapChumley() async {
    try {
      final me = await _repository.chumleyMe();
      emit(state.copyWith(chumleyMe: me));
      await refreshChumleyConversations();
      await _repository.connectSocket(
        onFrame: _onSocketFrame,
        onConnectionChanged: (connected) {
          if (!isClosed) {
            emit(state.copyWith(socketConnected: connected));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(chumleyError: e.toString()));
    }
  }

  Future<void> refreshChumleyConversations() async {
    emit(state.copyWith(chumleyLoading: true, clearChumleyError: true));
    try {
      final list = await _repository.listChumleyConversations();
      final unread = list.fold<int>(0, (sum, c) => sum + c.unreadCount);
      emit(
        state.copyWith(
          chumleyConversations: list,
          chumleyLoading: false,
          unreadTotal: unread,
        ),
      );
    } catch (e) {
      emit(state.copyWith(chumleyLoading: false, chumleyError: e.toString()));
    }
  }

  Future<void> openChumleyConversation(String id) async {
    emit(
      state.copyWith(
        activeChumleyConversationId: id,
        chumleyMessagesLoading: true,
        clearChumleyError: true,
        activeTab: ChumleyPanelTab.chats,
      ),
    );
    try {
      final result = await _repository.listChumleyMessages(id);
      await _repository.markChumleyRead(id);
      final updated = state.chumleyConversations.map((c) {
        if (c.id != id) return c;
        return ChatConversation(
          id: c.id,
          participants: c.participants,
          participantNames: c.participantNames,
          isGroup: c.isGroup,
          name: c.name,
          lastMessageAt: c.lastMessageAt,
          lastMessagePreview: c.lastMessagePreview,
          lastMessageAuthorEmail: c.lastMessageAuthorEmail,
          unreadCount: 0,
        );
      }).toList();
      final unread = updated.fold<int>(0, (sum, c) => sum + c.unreadCount);
      emit(
        state.copyWith(
          chumleyMessages: result.messages,
          chumleyMessagesLoading: false,
          chumleyConversations: updated,
          unreadTotal: unread,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          chumleyMessagesLoading: false,
          chumleyError: e.toString(),
        ),
      );
    }
  }

  Future<void> startDm(String peerEmail) async {
    try {
      final conv = await _repository.startDm(peerEmail.trim().toLowerCase());
      emit(
        state.copyWith(
          chumleyConversations: [
            conv,
            ...state.chumleyConversations.where((c) => c.id != conv.id),
          ],
        ),
      );
      await openChumleyConversation(conv.id);
    } catch (e) {
      emit(state.copyWith(chumleyError: e.toString()));
    }
  }

  Future<void> sendChumleyMessage(String text) async {
    final trimmed = text.trim();
    final conversationId = state.activeChumleyConversationId;
    final me = state.chumleyMe;
    if (trimmed.isEmpty || conversationId == null || me == null) return;

    final clientId = _uuid.v4();
    final optimistic = ChatMessage(
      id: 'temp-$clientId',
      conversationId: conversationId,
      text: trimmed,
      authorEmail: me.email,
      authorName: me.name,
      createdAt: DateTime.now(),
      clientId: clientId,
      pending: true,
    );

    emit(
      state.copyWith(
        chumleyMessages: [...state.chumleyMessages, optimistic],
        chumleySending: true,
        clearChumleyError: true,
      ),
    );

    _repository.sendChumleyWsMessage(
      conversationId: conversationId,
      text: trimmed,
      clientId: clientId,
    );

    emit(state.copyWith(chumleySending: false));
  }

  void _onSocketFrame(Map<String, dynamic> frame) {
    if (isClosed) return;
    final type = (frame['type'] ?? '').toString();

    switch (type) {
      case 'ready':
        final online = frame['online'];
        if (online is List) {
          emit(
            state.copyWith(
              onlineEmails: online.map((e) => e.toString()).toSet(),
            ),
          );
        }
        if (state.activeTab != ChumleyPanelTab.chats) {
          refreshChumleyConversations();
        }
        break;
      case 'message':
        final message = ChatMessage.fromJson(frame);
        _appendInboundMessage(message);
        if (state.activeTab != ChumleyPanelTab.chats ||
            state.activeChumleyConversationId != message.conversationId) {
          refreshChumleyConversations();
        }
        break;
      case 'ack':
        final clientId = frame['client_id']?.toString();
        final id = frame['id']?.toString();
        if (clientId == null || id == null) return;
        final updated = state.chumleyMessages.map((m) {
          if (m.clientId == clientId) {
            return m.copyWith(id: id, pending: false);
          }
          return m;
        }).toList();
        emit(state.copyWith(chumleyMessages: updated));
        break;
      case 'presence':
        final email = frame['email']?.toString();
        if (email == null) return;
        final online = {...state.onlineEmails};
        if (frame['online'] == true) {
          online.add(email);
        } else {
          online.remove(email);
        }
        emit(state.copyWith(onlineEmails: online));
        break;
      case 'typing_start':
        final email = frame['email']?.toString();
        final conversationId = frame['conversation_id']?.toString();
        if (email != null &&
            conversationId == state.activeChumleyConversationId) {
          emit(state.copyWith(typingEmails: {...state.typingEmails, email}));
        }
        break;
      case 'typing_stop':
        final email = frame['email']?.toString();
        if (email != null) {
          final typing = {...state.typingEmails}..remove(email);
          emit(state.copyWith(typingEmails: typing));
        }
        break;
      case 'error':
        final reason = frame['reason']?.toString() ?? 'Chat error';
        emit(state.copyWith(chumleyError: reason));
        break;
      default:
        break;
    }
  }

  void _appendInboundMessage(ChatMessage message) {
    if (message.conversationId != state.activeChumleyConversationId) {
      return;
    }
    final exists = state.chumleyMessages.any(
      (m) =>
          m.id == message.id ||
          (message.clientId != null && m.clientId == message.clientId),
    );
    if (exists) {
      final updated = state.chumleyMessages.map((m) {
        if (m.clientId != null && m.clientId == message.clientId) {
          return message;
        }
        if (m.id == message.id) return message;
        return m;
      }).toList();
      emit(state.copyWith(chumleyMessages: updated));
      return;
    }
    emit(state.copyWith(chumleyMessages: [...state.chumleyMessages, message]));
    _repository.markChumleyRead(message.conversationId);
  }

  void clearAiError() {
    emit(state.copyWith(clearAiError: true));
  }

  void clearChumleyError() {
    emit(state.copyWith(clearChumleyError: true));
  }

  void backToChumleyList() {
    emit(
      state.copyWith(
        clearActiveChumleyConversationId: true,
        chumleyMessages: const [],
      ),
    );
  }

  Future<void> onAppResumed() async {
    await refreshChumleyConversations();
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}
