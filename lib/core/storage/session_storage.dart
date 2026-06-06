import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Aspect session token — see MOBILE_APP_AUTH_GUIDE.md §6–7.
class SessionStorage {
  SessionStorage._();

  static const _sessionKey = 'aspect_session';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read() => _storage.read(key: _sessionKey);

  static Future<void> write(String token) =>
      _storage.write(key: _sessionKey, value: token);

  static Future<void> delete() => _storage.delete(key: _sessionKey);
}
