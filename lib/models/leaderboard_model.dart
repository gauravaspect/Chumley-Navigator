import 'package:chumley_navigator/models/user_model.dart';
import 'package:equatable/equatable.dart';

/// API envelope: `{ success, data: [...], count, cached, stale, source }`.
class LeaderboardResponse extends Equatable {
  const LeaderboardResponse({
    this.users = const [],
    this.count = 0,
    this.cached = false,
    this.stale = false,
    this.source = '',
  });

  final List<LeaderboardUser> users;
  final int count;
  final bool cached;
  final bool stale;
  final String source;

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final users = rawData is List
        ? rawData
            .whereType<Map>()
            .map(
              (item) => LeaderboardUser.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <LeaderboardUser>[];

    return LeaderboardResponse(
      users: users,
      count: _readInt(json['count']),
      cached: json['cached'] == true,
      stale: json['stale'] == true,
      source: (json['source'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [users, count, cached, stale, source];
}

class LeaderboardUser extends Equatable {
  const LeaderboardUser({
    this.id = '',
    this.rank = 0,
    this.name = '',
    this.photoUrl = '',
    this.tradeGroup = '',
    this.postcode = '',
    this.performanceScore = 0,
    this.performanceBreakdown = const PerformanceBreakdown(),
    this.avgReviewRating = 0,
    this.engineerSatisfactionSurvey = 0,
    this.roi = 0,
    this.referrals = 0,
    this.eprTotal = 0,
    this.estimateConversion = '',
    this.absencePercentage = '',
    this.sitesCovered = 0,
    this.skills = 0,
  });

  final String id;
  final int rank;
  final String name;
  final String photoUrl;
  final String tradeGroup;
  final String postcode;
  final double performanceScore;
  final PerformanceBreakdown performanceBreakdown;
  final double avgReviewRating;
  final double engineerSatisfactionSurvey;
  final double roi;
  final int referrals;
  final double eprTotal;
  final String estimateConversion;
  final String absencePercentage;
  final int sitesCovered;
  final int skills;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: (json['id'] ?? '').toString(),
      rank: _readInt(json['rank']),
      name: (json['name'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      tradeGroup: (json['trade_group'] ?? '').toString(),
      postcode: (json['postcode'] ?? '').toString(),
      performanceScore: _readDouble(json['performance_score']),
      performanceBreakdown: PerformanceBreakdown.fromJson(
        _readMap(json['performance_breakdown']),
      ),
      avgReviewRating: _readDouble(json['avg_review_rating']),
      engineerSatisfactionSurvey: _readDouble(
        json['engineer_satisfaction_survey'],
      ),
      roi: _readDouble(json['roi']),
      referrals: _readInt(json['referrals']),
      eprTotal: _readDouble(json['epr_total']),
      estimateConversion: (json['estimate_conversion'] ?? '').toString(),
      absencePercentage: (json['absence_percentage'] ?? '').toString(),
      sitesCovered: _readInt(json['sites_covered']),
      skills: _readInt(json['skills']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    rank,
    name,
    photoUrl,
    tradeGroup,
    postcode,
    performanceScore,
    performanceBreakdown,
    avgReviewRating,
    engineerSatisfactionSurvey,
    roi,
    referrals,
    eprTotal,
    estimateConversion,
    absencePercentage,
    sitesCovered,
    skills,
  ];
}

/// Minimal offline leaderboard cache — display fields only.
class LeaderboardCache extends Equatable {
  const LeaderboardCache({
    this.users = const [],
    this.count = 0,
  });

  final List<LeaderboardUserSummary> users;
  final int count;

  factory LeaderboardCache.fromResponse(LeaderboardResponse response) {
    return LeaderboardCache(
      count: response.count,
      users: response.users
          .map(LeaderboardUserSummary.fromUser)
          .toList(growable: false),
    );
  }

  LeaderboardResponse toResponse() {
    return LeaderboardResponse(
      users: users.map((entry) => entry.toUser()).toList(growable: false),
      count: count,
      cached: true,
      stale: true,
      source: 'local_cache',
    );
  }

  factory LeaderboardCache.fromJson(Map<String, dynamic> json) {
    final rawUsers = json['users'];
    final users = rawUsers is List
        ? rawUsers
            .whereType<Map>()
            .map(
              (item) => LeaderboardUserSummary.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <LeaderboardUserSummary>[];

    return LeaderboardCache(
      users: users,
      count: _readInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'users': users.map((user) => user.toJson()).toList(),
  };

  @override
  List<Object?> get props => [users, count];
}

class LeaderboardUserSummary extends Equatable {
  const LeaderboardUserSummary({
    this.id = '',
    this.rank = 0,
    this.name = '',
    this.performanceScore = 0,
    this.photoUrl = '',
  });

  final String id;
  final int rank;
  final String name;
  final double performanceScore;
  final String photoUrl;

  factory LeaderboardUserSummary.fromUser(LeaderboardUser user) {
    return LeaderboardUserSummary(
      id: user.id,
      rank: user.rank,
      name: user.name,
      performanceScore: user.performanceScore,
      photoUrl: user.photoUrl,
    );
  }

  LeaderboardUser toUser() {
    return LeaderboardUser(
      id: id,
      rank: rank,
      name: name,
      photoUrl: photoUrl,
      performanceScore: performanceScore,
    );
  }

  factory LeaderboardUserSummary.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserSummary(
      id: (json['id'] ?? '').toString(),
      rank: _readInt(json['rank']),
      name: (json['name'] ?? '').toString(),
      performanceScore: _readDouble(json['performance_score']),
      photoUrl: (json['photo_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'name': name,
    'performance_score': performanceScore,
    'photo_url': photoUrl,
  };

  @override
  List<Object?> get props => [id, rank, name, performanceScore, photoUrl];
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

int _readInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
