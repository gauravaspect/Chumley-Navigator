import 'package:equatable/equatable.dart';

class KpiPool extends Equatable {
  const KpiPool({this.score = 0, this.metrics = const {}});

  final double score;
  final Map<String, dynamic> metrics;

  factory KpiPool.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KpiPool();
    return KpiPool(
      score: _readDouble(json['score']),
      metrics: _readMap(json['metrics']),
    );
  }

  Map<String, dynamic> toJson() => {'score': score, 'metrics': metrics};

  @override
  List<Object?> get props => [score, metrics];
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
