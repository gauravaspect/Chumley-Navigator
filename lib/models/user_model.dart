import 'package:equatable/equatable.dart';

import 'kpi_pool.dart';
import 'performance_breakdown.dart';
import 'user_bio.dart';
import 'user_dashboard.dart';

export 'appointment.dart';
export 'kpi_pool.dart';
export 'performance_breakdown.dart';
export 'user_bio.dart';
export 'user_dashboard.dart';

class UserModel extends Equatable {
  const UserModel({
    this.id = '',
    this.name = '',
    this.position = '',
    this.overallRating = 0,
    this.photoUrl = '',
    this.dateRange = '',
    this.dateDescription = '',
    this.conversion = const KpiPool(),
    this.productivity = const KpiPool(),
    this.procedural = const KpiPool(),
    this.vehicular = const KpiPool(),
    this.cSat = const KpiPool(),
    this.aspect = const KpiPool(),
    this.bio = const UserBio(),
    this.dashboard = const UserDashboard(),
    this.performanceScore = 0,
    this.performanceBreakdown = const PerformanceBreakdown(),
  });

  final String id;
  final String name;
  final String position;
  final double overallRating;
  final String photoUrl;
  final String dateRange;
  final String dateDescription;
  final KpiPool conversion;
  final KpiPool productivity;
  final KpiPool procedural;
  final KpiPool vehicular;
  final KpiPool cSat;
  final KpiPool aspect;
  final UserBio bio;
  final UserDashboard dashboard;
  final double performanceScore;
  final PerformanceBreakdown performanceBreakdown;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return UserModel(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      position: (data['position'] ?? '').toString(),
      overallRating: _readDouble(data['overall_rating']),
      photoUrl: (data['photo_url'] ?? '').toString(),
      dateRange: (data['date_range'] ?? '').toString(),
      dateDescription: (data['date_description'] ?? '').toString(),
      conversion: KpiPool.fromJson(_readMap(data['conversion'])),
      productivity: KpiPool.fromJson(_readMap(data['productivity'])),
      procedural: KpiPool.fromJson(_readMap(data['procedural'])),
      vehicular: KpiPool.fromJson(_readMap(data['vehicular'])),
      cSat: KpiPool.fromJson(_readMap(data['c_sat'])),
      aspect: KpiPool.fromJson(_readMap(data['aspect'])),
      bio: UserBio.fromJson(_readMap(data['bio'])),
      dashboard: UserDashboard.fromJson(_readMap(data['dashboard'])),
      performanceScore: _readDouble(data['performance_score']),
      performanceBreakdown: PerformanceBreakdown.fromJson(
        _readMap(data['performance_breakdown']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'overall_rating': overallRating,
    'photo_url': photoUrl,
    'date_range': dateRange,
    'date_description': dateDescription,
    'conversion': conversion.toJson(),
    'productivity': productivity.toJson(),
    'procedural': procedural.toJson(),
    'vehicular': vehicular.toJson(),
    'c_sat': cSat.toJson(),
    'aspect': aspect.toJson(),
    'bio': bio.toJson(),
    'dashboard': dashboard.toJson(),
    'performance_score': performanceScore,
    'performance_breakdown': performanceBreakdown.toJson(),
  };

  /// Minimal fields for offline profile/header — no KPI pools or appointments.
  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'name': name,
    'position': position,
    'photo_url': photoUrl,
    'overall_rating': overallRating,
    'performance_score': performanceScore,
    'bio': bio.toJson(),
  };

  factory UserModel.fromCacheJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      position: (json['position'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      overallRating: _readDouble(json['overall_rating']),
      performanceScore: _readDouble(json['performance_score']),
      bio: UserBio.fromJson(_readMap(json['bio'])),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    position,
    overallRating,
    photoUrl,
    dateRange,
    dateDescription,
    conversion,
    productivity,
    procedural,
    vehicular,
    cSat,
    aspect,
    bio,
    dashboard,
    performanceScore,
    performanceBreakdown,
  ];

  /// True when the full profile API payload is available (not slim prefs cache).
  bool get hasFullDashboardProfile {
    if (id.isEmpty) return false;
    if (dateRange.isNotEmpty || dateDescription.isNotEmpty) return true;
    if (conversion.score != 0 ||
        productivity.score != 0 ||
        procedural.score != 0 ||
        vehicular.score != 0 ||
        cSat.score != 0) {
      return true;
    }
    if (dashboard.appointmentsThisMonth.isNotEmpty) return true;
    if (performanceBreakdown.cases != 0 ||
        performanceBreakdown.avgJobValue != 0) {
      return true;
    }
    return false;
  }
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

double _readDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
