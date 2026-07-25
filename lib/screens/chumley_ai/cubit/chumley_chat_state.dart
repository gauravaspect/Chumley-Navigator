import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/models/chumley_chat_models.dart';
import 'package:chumley_navigator/models/navigator_ai_models.dart';
import 'package:equatable/equatable.dart';

enum ChumleyPanelTab { insights, aiChat, chats }

class ChumleyChatState extends Equatable {
  const ChumleyChatState({
    this.user,
    this.activeTab = ChumleyPanelTab.chats,
    this.chumleyChatEnabled = false,
    this.permissionsLoaded = false,
    this.briefing,
    this.briefingLoading = false,
    this.briefingError,
    this.navigatorOnline = true,
    this.aiConversations = const [],
    this.activeAiConversationId,
    this.aiMessages = const [],
    this.aiLoading = false,
    this.aiSending = false,
    this.aiError,
    this.showAiPastChats = false,
    this.chumleyMe,
    this.chumleyConversations = const [],
    this.chumleyLoading = false,
    this.chumleyError,
    this.activeChumleyConversationId,
    this.chumleyMessages = const [],
    this.chumleyMessagesLoading = false,
    this.chumleySending = false,
    this.socketConnected = false,
    this.unreadTotal = 0,
    this.typingEmails = const {},
    this.onlineEmails = const {},
  });

  final AuthUser? user;
  final ChumleyPanelTab activeTab;
  final bool chumleyChatEnabled;
  final bool permissionsLoaded;

  final DailyBriefing? briefing;
  final bool briefingLoading;
  final String? briefingError;

  final bool navigatorOnline;
  final List<NavigatorAiConversation> aiConversations;
  final String? activeAiConversationId;
  final List<NavigatorAiMessage> aiMessages;
  final bool aiLoading;
  final bool aiSending;
  final String? aiError;
  final bool showAiPastChats;

  final ChumleyChatUser? chumleyMe;
  final List<ChatConversation> chumleyConversations;
  final bool chumleyLoading;
  final String? chumleyError;
  final String? activeChumleyConversationId;
  final List<ChatMessage> chumleyMessages;
  final bool chumleyMessagesLoading;
  final bool chumleySending;
  final bool socketConnected;
  final int unreadTotal;
  final Set<String> typingEmails;
  final Set<String> onlineEmails;

  NavigatorAiConversation? get activeAiConversation {
    final id = activeAiConversationId;
    if (id == null) return null;
    for (final c in aiConversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  ChatConversation? get activeChumleyConversation {
    final id = activeChumleyConversationId;
    if (id == null) return null;
    for (final c in chumleyConversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  ChumleyChatState copyWith({
    AuthUser? user,
    ChumleyPanelTab? activeTab,
    bool? chumleyChatEnabled,
    bool? permissionsLoaded,
    DailyBriefing? briefing,
    bool? briefingLoading,
    String? briefingError,
    bool clearBriefingError = false,
    bool? navigatorOnline,
    List<NavigatorAiConversation>? aiConversations,
    String? activeAiConversationId,
    bool clearActiveAiConversationId = false,
    List<NavigatorAiMessage>? aiMessages,
    bool? aiLoading,
    bool? aiSending,
    String? aiError,
    bool clearAiError = false,
    bool? showAiPastChats,
    ChumleyChatUser? chumleyMe,
    List<ChatConversation>? chumleyConversations,
    bool? chumleyLoading,
    String? chumleyError,
    bool clearChumleyError = false,
    String? activeChumleyConversationId,
    bool clearActiveChumleyConversationId = false,
    List<ChatMessage>? chumleyMessages,
    bool? chumleyMessagesLoading,
    bool? chumleySending,
    bool? socketConnected,
    int? unreadTotal,
    Set<String>? typingEmails,
    Set<String>? onlineEmails,
  }) {
    return ChumleyChatState(
      user: user ?? this.user,
      activeTab: activeTab ?? this.activeTab,
      chumleyChatEnabled: chumleyChatEnabled ?? this.chumleyChatEnabled,
      permissionsLoaded: permissionsLoaded ?? this.permissionsLoaded,
      briefing: briefing ?? this.briefing,
      briefingLoading: briefingLoading ?? this.briefingLoading,
      briefingError:
          clearBriefingError ? null : (briefingError ?? this.briefingError),
      navigatorOnline: navigatorOnline ?? this.navigatorOnline,
      aiConversations: aiConversations ?? this.aiConversations,
      activeAiConversationId: clearActiveAiConversationId
          ? null
          : (activeAiConversationId ?? this.activeAiConversationId),
      aiMessages: aiMessages ?? this.aiMessages,
      aiLoading: aiLoading ?? this.aiLoading,
      aiSending: aiSending ?? this.aiSending,
      aiError: clearAiError ? null : (aiError ?? this.aiError),
      showAiPastChats: showAiPastChats ?? this.showAiPastChats,
      chumleyMe: chumleyMe ?? this.chumleyMe,
      chumleyConversations: chumleyConversations ?? this.chumleyConversations,
      chumleyLoading: chumleyLoading ?? this.chumleyLoading,
      chumleyError:
          clearChumleyError ? null : (chumleyError ?? this.chumleyError),
      activeChumleyConversationId: clearActiveChumleyConversationId
          ? null
          : (activeChumleyConversationId ?? this.activeChumleyConversationId),
      chumleyMessages: chumleyMessages ?? this.chumleyMessages,
      chumleyMessagesLoading:
          chumleyMessagesLoading ?? this.chumleyMessagesLoading,
      chumleySending: chumleySending ?? this.chumleySending,
      socketConnected: socketConnected ?? this.socketConnected,
      unreadTotal: unreadTotal ?? this.unreadTotal,
      typingEmails: typingEmails ?? this.typingEmails,
      onlineEmails: onlineEmails ?? this.onlineEmails,
    );
  }

  @override
  List<Object?> get props => [
        user,
        activeTab,
        chumleyChatEnabled,
        permissionsLoaded,
        briefing,
        briefingLoading,
        briefingError,
        navigatorOnline,
        aiConversations,
        activeAiConversationId,
        aiMessages,
        aiLoading,
        aiSending,
        aiError,
        showAiPastChats,
        chumleyMe,
        chumleyConversations,
        chumleyLoading,
        chumleyError,
        activeChumleyConversationId,
        chumleyMessages,
        chumleyMessagesLoading,
        chumleySending,
        socketConnected,
        unreadTotal,
        typingEmails,
        onlineEmails,
      ];
}
