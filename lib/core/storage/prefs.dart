import 'dart:convert';

import 'package:chumley_navigator/core/storage/session_storage.dart';
import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/list_absence_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/models/milestones_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _sessionTokenKey = 'sessionToken';
  static const _userKey = 'user';
  static const _leaderboardKey = 'leaderboard';
  static const _authUserKey = 'authUser';
  static const _bearerKey = 'bearer';
  static const _refreshTokenKey = 'refreshToken';
  static const _pointsKey = 'performanceHistory';
  static const _vehicleAllocationsKey = 'vehicleAllocations';
  static const _absencesKey = 'absences';
  static const _milestonesKey = 'milestones_cache';

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
    await prefs.setString(_userKey, jsonEncode(user.toCacheJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await getPrefs();
    final userJson = prefs.getString(_userKey);
    if (userJson == null || userJson.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromCacheJson(decoded);
      }
      if (decoded is Map) {
        return UserModel.fromCacheJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_userKey);
    }
    return null;
  }

  static Future<void> saveLeaderboardCache(LeaderboardCache cache) async {
    final prefs = await getPrefs();
    await prefs.setString(_leaderboardKey, jsonEncode(cache.toJson()));
  }

  static Future<LeaderboardCache?> getLeaderboardCache() async {
    final prefs = await getPrefs();
    final json = prefs.getString(_leaderboardKey);
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return LeaderboardCache.fromJson(decoded);
      }
      if (decoded is Map) {
        return LeaderboardCache.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_leaderboardKey);
    }
    return null;
  }

  static Future<void> savePoints(EngineerPerformanceHistory points) async {
    final prefs = await getPrefs();
    await prefs.setString(_pointsKey, jsonEncode(points.toJson()));
  }

  static Future<void> saveVehicleAllocations(VehicleResponse response) async {
    final prefs = await getPrefs();
    await prefs.setString(
      _vehicleAllocationsKey,
      jsonEncode(response.toJson()),
    );
  }

  static Future<VehicleResponse?> getVehicleAllocations() async {
    final prefs = await getPrefs();
    final json = prefs.getString(_vehicleAllocationsKey);
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return VehicleResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return VehicleResponse.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_vehicleAllocationsKey);
    }
    return null;
  }

  static Future<EngineerPerformanceHistory?> getPoints() async {
    final prefs = await getPrefs();
    final json = prefs.getString(_pointsKey);
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return EngineerPerformanceHistory.fromJson(decoded);
      }
      if (decoded is Map) {
        return EngineerPerformanceHistory.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_pointsKey);
    }
    return null;
  }

  static Future<void> saveAbsences(AbsenceCache cache) async {
    final prefs = await getPrefs();
    await prefs.setString(_absencesKey, jsonEncode(cache.toJson()));
  }

  static Future<AbsenceCache?> getAbsences() async {
    final prefs = await getPrefs();
    final json = prefs.getString(_absencesKey);
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return AbsenceCache.fromJson(decoded);
      }
      if (decoded is Map) {
        return AbsenceCache.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_absencesKey);
    }
    return null;
  }

  static Future<void> saveMilestonesCache(MilestonesResponse cache) async {
    final prefs = await getPrefs();
    await prefs.setString(_milestonesKey, jsonEncode(cache.toJson()));
  }

  static Future<MilestonesResponse?> getMilestonesCache() async {
    final prefs = await getPrefs();
    final json = prefs.getString(_milestonesKey);
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return MilestonesResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return MilestonesResponse.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await prefs.remove(_milestonesKey);
    }
    return null;
  }

  static Future<void> clearAuth() async {
    await SessionStorage.delete();
    final prefs = await getPrefs();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_leaderboardKey);
    await prefs.remove(_authUserKey);
    await prefs.remove(_bearerKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_pointsKey);
    await prefs.remove(_vehicleAllocationsKey);
    await prefs.remove(_absencesKey);
    await prefs.remove(_milestonesKey);
  }

  static Future<void> clearAll() async {
    await SessionStorage.delete();
    final prefs = await getPrefs();
    await prefs.clear();
  }
}
