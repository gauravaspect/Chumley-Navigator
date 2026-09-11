import 'dart:async';
import 'dart:convert';

import 'package:chumley_navigator/core/network/api_endpoints.dart';
import 'package:chumley_navigator/screens/chumley_ai/auth/chumley_auth_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef ChumleySocketFrameHandler = void Function(Map<String, dynamic> frame);

/// WebSocket client for Chumley Chat (ping, reconnect, frames).
class ChumleyChatSocket {
  ChumleyChatSocket({
    required ChumleyAuthProvider authProvider,
    required this.onFrame,
    this.onConnectionChanged,
  }) : _authProvider = authProvider;

  final ChumleyAuthProvider _authProvider;
  final ChumleySocketFrameHandler onFrame;
  final void Function(bool connected)? onConnectionChanged;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;
  bool _connecting = false;
  int _backoffSeconds = 1;

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_connecting || _channel != null) return;
    _intentionalClose = false;
    _connecting = true;
    try {
      final token = await _authProvider.fetchToken();
      final base = ApiEndpoints.chumleyChatBaseUrl;
      if (base.isEmpty) {
        throw StateError('CHUMLEY_CHAT_BASE_URL is not configured');
      }
      final wsBase = base
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      final uri = Uri.parse(
        '$wsBase/ws',
      ).replace(queryParameters: {'token': token});

      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      _backoffSeconds = 1;
      onConnectionChanged?.call(true);

      _subscription = channel.stream.listen(
        (event) {
          final data = event is String ? event : event.toString();
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map) {
              onFrame(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {
            // ignore malformed frames
          }
        },
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        send({'type': 'ping'});
      });
    } catch (_) {
      onConnectionChanged?.call(false);
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void send(Map<String, dynamic> frame) {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(jsonEncode(frame));
  }

  void sendMessage({
    required String conversationId,
    required String text,
    String? clientId,
    Map<String, dynamic>? context,
  }) {
    send({
      'type': 'send',
      'conversation_id': conversationId,
      'text': text,
      if (clientId != null) 'client_id': clientId,
      if (context != null) 'context': context,
    });
  }

  void typingStart(String conversationId) {
    send({'type': 'typing_start', 'conversation_id': conversationId});
  }

  void typingStop(String conversationId) {
    send({'type': 'typing_stop', 'conversation_id': conversationId});
  }

  void _handleDisconnect() {
    _tearDownSocket(keepReconnect: !_intentionalClose);
    onConnectionChanged?.call(false);
    if (!_intentionalClose) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = _backoffSeconds;
    _backoffSeconds = (_backoffSeconds * 2).clamp(1, 30);
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_intentionalClose) {
        connect();
      }
    });
  }

  void _tearDownSocket({required bool keepReconnect}) {
    _pingTimer?.cancel();
    _pingTimer = null;
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    if (!keepReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
  }

  Future<void> dispose() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _tearDownSocket(keepReconnect: false);
  }
}
