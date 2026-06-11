import 'package:equatable/equatable.dart';

class EngineerPerformanceHistory extends Equatable {
  const EngineerPerformanceHistory({
    this.engineerId = '',
    this.engineerName = '',
    this.tradeGroup = '',
    this.monthsRequested = 0,
    this.cumulativeTotal = 0,
    this.thisMonthTotal = 0,
    this.months = const [],
  });

  final String engineerId;
  final String engineerName;
  final String tradeGroup;
  final int monthsRequested;
  final int cumulativeTotal;
  final int thisMonthTotal;
  final List<PerformanceMonth> months;

  factory EngineerPerformanceHistory.fromJson(Map<String, dynamic> json) {
    return EngineerPerformanceHistory(
      engineerId: (json['engineer_id'] ?? '').toString(),
      engineerName: (json['engineer_name'] ?? '').toString(),
      tradeGroup: (json['trade_group'] ?? '').toString(),
      monthsRequested: _readInt(json['months_requested']),
      cumulativeTotal: _readInt(json['cumulative_total']),
      thisMonthTotal: _readInt(json['this_month_total']),
      months: (json['months'] as List? ?? [])
          .map((e) => PerformanceMonth.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'engineer_id': engineerId,
    'engineer_name': engineerName,
    'trade_group': tradeGroup,
    'months_requested': monthsRequested,
    'cumulative_total': cumulativeTotal,
    'this_month_total': thisMonthTotal,
    'months': months.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    engineerId,
    engineerName,
    tradeGroup,
    monthsRequested,
    cumulativeTotal,
    thisMonthTotal,
    months,
  ];
}

class PerformanceMonth extends Equatable {
  const PerformanceMonth({
    this.engineerId = '',
    this.engineerName = '',
    this.tradeGroup = '',
    this.dateRange = '',
    this.monthLabel = '',
    this.tradeBaseline = const TradeBaseline(),
    this.totalPoints = 0,
    this.categories = const PerformanceCategories(),
  });

  final String engineerId;
  final String engineerName;
  final String tradeGroup;
  final String dateRange;
  final String monthLabel;
  final TradeBaseline tradeBaseline;
  final int totalPoints;
  final PerformanceCategories categories;

  factory PerformanceMonth.fromJson(Map<String, dynamic> json) {
    return PerformanceMonth(
      engineerId: (json['engineer_id'] ?? '').toString(),
      engineerName: (json['engineer_name'] ?? '').toString(),
      tradeGroup: (json['trade_group'] ?? '').toString(),
      dateRange: (json['date_range'] ?? '').toString(),
      monthLabel: (json['month_label'] ?? '').toString(),
      tradeBaseline: TradeBaseline.fromJson(_readMap(json['trade_baseline'])),
      totalPoints: _readInt(json['total_points']),
      categories: PerformanceCategories.fromJson(_readMap(json['categories'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'engineer_id': engineerId,
    'engineer_name': engineerName,
    'trade_group': tradeGroup,
    'date_range': dateRange,
    'month_label': monthLabel,
    'trade_baseline': tradeBaseline.toJson(),
    'total_points': totalPoints,
    'categories': categories.toJson(),
  };

  @override
  List<Object?> get props => [
    engineerId,
    engineerName,
    tradeGroup,
    dateRange,
    monthLabel,
    tradeBaseline,
    totalPoints,
    categories,
  ];
}

class TradeBaseline extends Equatable {
  const TradeBaseline({
    this.avgJobValue = 0,
    this.avgConvertedEstimateValue = 0,
  });

  final double avgJobValue;
  final double avgConvertedEstimateValue;

  factory TradeBaseline.fromJson(Map<String, dynamic> json) {
    return TradeBaseline(
      avgJobValue: _readDouble(json['avg_job_value']),
      avgConvertedEstimateValue: _readDouble(
        json['avg_converted_estimate_value'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'avg_job_value': avgJobValue,
    'avg_converted_estimate_value': avgConvertedEstimateValue,
  };

  @override
  List<Object?> get props => [avgJobValue, avgConvertedEstimateValue];
}

class PerformanceCategories extends Equatable {
  const PerformanceCategories({
    this.perJob = const PerformanceCategory(),
    this.reviews = const PerformanceCategory(),
    this.leadConversion = const PerformanceCategory(),
    this.reactiveEstimates = const PerformanceCategory(),
    this.referrals = const PerformanceCategory(),
    this.consistency = const PerformanceCategory(),
    this.driving = const PerformanceCategory(),
    this.milestones = const PerformanceCategory(),
  });

  final PerformanceCategory perJob;
  final PerformanceCategory reviews;
  final PerformanceCategory leadConversion;
  final PerformanceCategory reactiveEstimates;
  final PerformanceCategory referrals;
  final PerformanceCategory consistency;
  final PerformanceCategory driving;
  final PerformanceCategory milestones;

  factory PerformanceCategories.fromJson(Map<String, dynamic> json) {
    return PerformanceCategories(
      perJob: PerformanceCategory.fromJson(_readMap(json['per_job'])),
      reviews: PerformanceCategory.fromJson(_readMap(json['reviews'])),
      leadConversion: PerformanceCategory.fromJson(
        _readMap(json['lead_conversion']),
      ),
      reactiveEstimates: PerformanceCategory.fromJson(
        _readMap(json['reactive_estimates']),
      ),
      referrals: PerformanceCategory.fromJson(_readMap(json['referrals'])),
      consistency: PerformanceCategory.fromJson(_readMap(json['consistency'])),
      driving: PerformanceCategory.fromJson(_readMap(json['driving'])),
      milestones: PerformanceCategory.fromJson(_readMap(json['milestones'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'per_job': perJob.toJson(),
    'reviews': reviews.toJson(),
    'lead_conversion': leadConversion.toJson(),
    'reactive_estimates': reactiveEstimates.toJson(),
    'referrals': referrals.toJson(),
    'consistency': consistency.toJson(),
    'driving': driving.toJson(),
    'milestones': milestones.toJson(),
  };

  @override
  List<Object?> get props => [
    perJob,
    reviews,
    leadConversion,
    reactiveEstimates,
    referrals,
    consistency,
    driving,
    milestones,
  ];
}

class PerformanceCategory extends Equatable {
  const PerformanceCategory({this.total = 0, this.events = const []});

  final int total;
  final List<PerformanceEvent> events;

  factory PerformanceCategory.fromJson(Map<String, dynamic> json) {
    return PerformanceCategory(
      total: _readInt(json['total']),
      events: (json['events'] as List? ?? [])
          .map((e) => PerformanceEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'events': events.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [total, events];
}

class PerformanceEvent extends Equatable {
  const PerformanceEvent({
    this.label = '',
    this.points = 0,
    this.count = 0,
    this.detail = '',
    this.dataQuality = '',
  });

  final String label;
  final int points;
  final int count;
  final String detail;
  final String dataQuality;

  factory PerformanceEvent.fromJson(Map<String, dynamic> json) {
    return PerformanceEvent(
      label: (json['label'] ?? '').toString(),
      points: _readInt(json['points']),
      count: _readInt(json['count']),
      detail: (json['detail'] ?? '').toString(),
      dataQuality: (json['data_quality'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'points': points,
    'count': count,
    'detail': detail,
    'data_quality': dataQuality,
  };

  @override
  List<Object?> get props => [label, points, count, detail, dataQuality];
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
