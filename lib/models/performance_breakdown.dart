import 'package:equatable/equatable.dart';

class PerformanceBreakdown extends Equatable {
  const PerformanceBreakdown({
    this.avgJobValue = 0,
    this.avgConvertedEstimateValue = 0,
    this.absencePercentage = 0,
    this.cases = 0,
    this.avgReviewRating = 0,
    this.drivingScore = 0,
    this.unclosedJobs = 0,
    this.paymentCollectionPercentage = 0,
  });

  final double avgJobValue;
  final double avgConvertedEstimateValue;
  final double absencePercentage;
  final double cases;
  final double avgReviewRating;
  final double drivingScore;
  final double unclosedJobs;
  final double paymentCollectionPercentage;

  factory PerformanceBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PerformanceBreakdown();
    return PerformanceBreakdown(
      avgJobValue: _readDouble(json['avg_job_value']),
      avgConvertedEstimateValue: _readDouble(
        json['avg_converted_estimate_value'],
      ),
      absencePercentage: _readDouble(json['absence_percentage']),
      cases: _readDouble(json['cases']),
      avgReviewRating: _readDouble(json['avg_review_rating']),
      drivingScore: _readDouble(json['driving_score']),
      unclosedJobs: _readDouble(json['unclosed_jobs']),
      paymentCollectionPercentage: _readDouble(
        json['payment_collection_percentage'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'avg_job_value': avgJobValue,
    'avg_converted_estimate_value': avgConvertedEstimateValue,
    'absence_percentage': absencePercentage,
    'cases': cases,
    'avg_review_rating': avgReviewRating,
    'driving_score': drivingScore,
    'unclosed_jobs': unclosedJobs,
    'payment_collection_percentage': paymentCollectionPercentage,
  };

  @override
  List<Object?> get props => [
    avgJobValue,
    avgConvertedEstimateValue,
    absencePercentage,
    cases,
    avgReviewRating,
    drivingScore,
    unclosedJobs,
    paymentCollectionPercentage,
  ];
}

double _readDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
