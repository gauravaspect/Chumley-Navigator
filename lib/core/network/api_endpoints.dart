import '../app_constants.dart';

/// API paths and base URL — see [MOBILE_APP_AUTH_GUIDE.md].
class ApiEndpoints {
  static const String mobileExchange = '/api/auth/mobile/exchange';
  static const String signOut = '/api/auth/signout';
  static  String profile(String id, {String dateRange = 'all_time'}) =>
      '/api/engineer/$id?date_range=$dateRange';


  static String get baseUrl {
    final raw = AppConstants.apiBaseUrl.trim();
    if (raw.isEmpty) return '';
    return raw.endsWith('/') ? raw : '$raw/';
  }

  static bool get isConfigured => baseUrl.isNotEmpty;


  /// Public auth routes must not send a stored session Bearer (see auth guide §6).
  static bool skipsSessionAuth(String path) {
    return path.contains(mobileExchange);
  }
}