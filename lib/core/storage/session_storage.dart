import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Aspect session token — see MOBILE_APP_AUTH_GUIDE.md §6–7.
class SessionStorage {
  SessionStorage._();

  static const _sessionKey = 'aspect_session';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String? _inMemoryToken;

  /// Retrieves the session token, using in-memory cache if available,
  /// falling back to secure storage.
  static Future<String?> read() async {
    if (_inMemoryToken != null && _inMemoryToken!.trim().isNotEmpty) {
      return _inMemoryToken;
    }
    final token = await _storage.read(key: _sessionKey);
    _inMemoryToken = token;
    return token;
  }

  /// Writes session token to in-memory cache and secure storage.
  static Future<void> write(String token) async {
    _inMemoryToken = token;
    await _storage.write(key: _sessionKey, value: token);
  }

  /// Clears session token from in-memory cache and secure storage.
  static Future<void> delete() async {
    _inMemoryToken = null;
    await _storage.delete(key: _sessionKey);
  }
}
