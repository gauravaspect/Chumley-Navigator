import 'package:equatable/equatable.dart';

class ChumleyChatUser extends Equatable {
  const ChumleyChatUser({
    this.email = '',
    this.name = '',
    this.pillar = '',
  });

  final String email;
  final String name;
  final String pillar;

  factory ChumleyChatUser.fromJson(Map<String, dynamic> json) {
    return ChumleyChatUser(
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      pillar: (json['pillar'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [email, name, pillar];
}

class ChatConversation extends Equatable {
  const ChatConversation({
    this.id = '',
    this.participants = const [],
    this.participantNames = const {},
    this.isGroup = false,
    this.name,
    this.lastMessageAt,
    this.lastMessagePreview = '',
    this.lastMessageAuthorEmail = '',
    this.unreadCount = 0,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final bool isGroup;
  final String? name;
  final DateTime? lastMessageAt;
  final String lastMessagePreview;
  final String lastMessageAuthorEmail;
  final int unreadCount;

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final namesRaw = json['participant_names'];
    final names = <String, String>{};
    if (namesRaw is Map) {
      namesRaw.forEach((key, value) {
        names[key.toString()] = value?.toString() ?? '';
      });
    }

    return ChatConversation(
      id: (json['id'] ?? '').toString(),
      participants: _stringList(json['participants']),
      participantNames: names,
      isGroup: json['is_group'] == true,
      name: json['name']?.toString(),
      lastMessageAt: DateTime.tryParse(
        (json['last_message_at'] ?? '').toString(),
      ),
      lastMessagePreview: (json['last_message_preview'] ?? '').toString(),
      lastMessageAuthorEmail:
          (json['last_message_author_email'] ?? '').toString(),
      unreadCount: _readInt(json['unread_count']),
    );
  }

  String titleFor(String myEmail) {
    if (isGroup && (name?.trim().isNotEmpty ?? false)) return name!.trim();
    final others = participants
        .where((e) => e.toLowerCase() != myEmail.toLowerCase())
        .toList();
    if (others.isEmpty) return name?.trim().isNotEmpty == true ? name! : 'Chat';
    return others
        .map((e) => participantNames[e]?.trim().isNotEmpty == true
            ? participantNames[e]!
            : e)
        .join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        participantNames,
        isGroup,
        name,
        lastMessageAt,
        lastMessagePreview,
        lastMessageAuthorEmail,
        unreadCount,
      ];
}

class ChatMessageContext extends Equatable {
  const ChatMessageContext({
    this.type = '',
    this.label = '',
    this.url = '',
    this.sensitive = false,
  });

  final String type;
  final String label;
  final String url;
  final bool sensitive;

  factory ChatMessageContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatMessageContext();
    return ChatMessageContext(
      type: (json['type'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      sensitive: json['sensitive'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        'url': url,
        'sensitive': sensitive,
      };

  @override
  List<Object?> get props => [type, label, url, sensitive];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    this.id = '',
    this.conversationId = '',
    this.text = '',
    this.authorEmail = '',
    this.authorName = '',
    this.createdAt,
    this.clientId,
    this.context,
    this.pending = false,
    this.failed = false,
  });

  final String id;
  final String conversationId;
  final String text;
  final String authorEmail;
  final String authorName;
  final DateTime? createdAt;
  final String? clientId;
  final ChatMessageContext? context;
  final bool pending;
  final bool failed;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final ctx = json['context'];
    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      authorEmail: (json['author_email'] ?? '').toString(),
      authorName: (json['author_name'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      clientId: json['client_id']?.toString(),
      context: ctx is Map
          ? ChatMessageContext.fromJson(Map<String, dynamic>.from(ctx))
          : null,
    );
  }

  ChatMessage copyWith({
    String? id,
    bool? pending,
    bool? failed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      text: text,
      authorEmail: authorEmail,
      authorName: authorName,
      createdAt: createdAt,
      clientId: clientId,
      context: context,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        text,
        authorEmail,
        authorName,
        createdAt,
        clientId,
        context,
        pending,
        failed,
      ];
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => e?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
