import 'dart:convert';

import 'package:chumley_navigator/core/storage/session_storage.dart';
import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _sessionTokenKey = 'sessionToken';
  static const _userKey = 'user';
  static const _authUserKey = 'authUser';
  static const _bearerKey = 'bearer';
  static const _refreshTokenKey = 'refreshToken';

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<String?> getAccessBearer() => getSessionToken();

  static Future<void> setAccessBearer(String bearer) =>
      saveSessionToken(bearer);

  static Future<void> removeAccessBearer() async {
    await SessionStorage.delete();
    final prefs = await getPrefs();
    await prefs.remove(_bearerKey);
    await prefs.remove(_sessionTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await getPrefs();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    final prefs = await getPrefs();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await getPrefs();
    await prefs.remove(_refreshTokenKey);
  }

  static Future<void> saveSessionToken(String token) async {
    await SessionStorage.write(token);
    final prefs = await getPrefs();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_bearerKey);
  }

  static Future<String?> getSessionToken() async {
    final secure = await SessionStorage.read();
    if (secure != null && secure.trim().isNotEmpty) return secure;

    final prefs = await getPrefs();
    final legacy =
        prefs.getString(_sessionTokenKey) ?? prefs.getString(_bearerKey);
    if (legacy != null && legacy.trim().isNotEmpty) {
      await SessionStorage.write(legacy);
      await prefs.remove(_sessionTokenKey);
      await prefs.remove(_bearerKey);
      return legacy;
    }
    return null;
  }

  static Future<void> saveAuthUser(AuthUser user) async {
    final prefs = await getPrefs();
    await prefs.setString(_authUserKey, jsonEncode(user.toJson()));
  }

  static Future<AuthUser?> getAuthUser() async {
    final prefs = await getPrefs();
    final userJson = prefs.getString(_authUserKey);
    if (userJson == null || userJson.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return AuthUser.fromJson(decoded);
      }
      if (decoded is Map) {
        return AuthUser.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_authUserKey);
    }
    return null;
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await getPrefs();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await getPrefs();
    final userJson = prefs.getString(_userKey);
    if (userJson == null || userJson.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_userKey);
    }
    return null;
  }

  static Future<void> clearAuth() async {
    await SessionStorage.delete();
    final prefs = await getPrefs();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_authUserKey);
    await prefs.remove(_bearerKey);
    await prefs.remove(_refreshTokenKey);
  }

  static Future<void> clearAll() async {
    await SessionStorage.delete();
    final prefs = await getPrefs();
    await prefs.clear();
  }
}
