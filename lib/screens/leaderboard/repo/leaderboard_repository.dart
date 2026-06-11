import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/leaderboard_model.dart';
import 'package:chumley_navigator/screens/leaderboard/service/leaderboard_api_service.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._apiService);

  final LeaderboardApiService _apiService;

  Future<LeaderboardResponse?> readCachedLeaderboard() async {
    final cache = await Prefs.getLeaderboardCache();
    return cache?.toResponse();
  }

  Future<LeaderboardResponse> fetchLeaderboard() async {
    try {
      final response = await _apiService.fetchLeaderboard();
      await Prefs.saveLeaderboardCache(
        LeaderboardCache.fromResponse(response),
      );
      return response;
    } on LeaderBoardApiException {
      final cached = await readCachedLeaderboard();
      if (cached != null && cached.users.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<LeaderboardResponse> refreshLeaderboard() => fetchLeaderboard();
}
