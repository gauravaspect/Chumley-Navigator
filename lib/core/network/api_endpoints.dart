import '../app_constants.dart';

/// API paths and base URL — see [MOBILE_APP_AUTH_GUIDE.md].
class ApiEndpoints {
  static const String mobileExchange = '/api/auth/mobile/exchange';
  static const String signOut = '/api/auth/signout';
  static  String profile(String id, {String dateRange = 'all_time'}) =>
      '/api/engineer/$id?date_range=$dateRange';
  static String getPointsData(String id,{int month =12}) => '/api/engineers/$id/points/summary?months=$month';
  static String getMilestones(String id) => '/api/engineers/$id/milestones';
  static const getVehicleAllocations = '/api/vcr/allocations';
  static const getLeaderboardData = '/api/leaderboard';
  static String getVcrExamples(String section) => '/api/vcr/examples/$section';
  static const submitVcr = '/api/vcr/submit';
  static const listMyAbsences = '/api/engineer/absences';
  static const postMyAbsence = '/api/engineer/absences';
  static String get baseUrl {
    final raw = AppConstants.apiBaseUrl.trim();
    if (raw.isEmpty) return '';
    return raw.endsWith('/') ? raw : '$raw/';
  }
  static const getFixedPriceTrades = "/api/work-orders/catalog/trades";
  static const getFixedPriceCategories = "/api/work-orders/catalog/categories";
  static const getFixedPriceWorkTypes = "/api/work-orders/catalog/work-types";
  static const submitWorkOrder = '/api/work-orders';
  static const getPpmJobs = '/api/demo/ppm-tasks';

  // Chumley / Navigator chat
  static const chatToken = '/api/auth/chat-token';
  static const permissionsMe = '/api/permissions/me';
  static const dailyBriefing = '/api/insights/daily-briefing';
  static const navigatorHealth = '/api/navigator/health';
  static const navigatorConversations = '/api/navigator/conversations';
  static String navigatorConversationMessages(String id) =>
      '/api/navigator/conversations/$id/messages';
  static const navigatorQuery = '/api/navigator/query';
  static String addressVisitSummary(String postcode) =>
      '/api/scheduling/address-visit-summary?postcode=${Uri.encodeComponent(postcode)}';

  static String get chumleyChatBaseUrl {
    final raw = AppConstants.chumleyChatBaseUrl.trim();
    if (raw.isEmpty) return '';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;


  /// Public auth routes must not send a stored session Bearer (see auth guide §6).
  static bool skipsSessionAuth(String path) {
    return path.contains(mobileExchange);
  }
}