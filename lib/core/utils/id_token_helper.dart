import 'dart:convert';

/// Lightweight Microsoft id_token checks (JWT payload only, no signature verify).
class IdTokenHelper {
  static bool isExpired(
    String jwt, {
    Duration clockSkew = const Duration(seconds: 60),
  }) {
    final exp = _readExp(jwt);
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiry.subtract(clockSkew));
  }

  static String? readAudience(String jwt) {
    final payload = _decodePayload(jwt);
    final aud = payload?['aud'];
    if (aud is String) return aud;
    if (aud is List && aud.isNotEmpty) return aud.first.toString();
    return null;
  }

  static int? _readExp(String jwt) {
    final exp = _decodePayload(jwt)?['exp'];
    if (exp is int) return exp;
    return int.tryParse(exp?.toString() ?? '');
  }

  static Map<String, dynamic>? _decodePayload(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }
}
