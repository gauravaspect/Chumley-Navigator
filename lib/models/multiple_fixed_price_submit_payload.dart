import 'package:chumley_navigator/models/auth_user.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:equatable/equatable.dart';

class MultipleFixedPriceJobBreakdown extends Equatable {
  const MultipleFixedPriceJobBreakdown({
    required this.collectionFee,
    required this.ulez,
    required this.materialsWithMarkup,
    required this.adminFeePercentage,
    required this.materialsMarkupBandPercent,
  });

  final double collectionFee;
  final double ulez;
  final double materialsWithMarkup;
  final double adminFeePercentage;
  final double materialsMarkupBandPercent;

  Map<String, dynamic> toJson() => {
    'collection_fee': collectionFee,
    'ulez': ulez,
    'materials_with_markup': materialsWithMarkup,
    'admin_fee_percentage': adminFeePercentage,
    'materials_markup_band_percent': materialsMarkupBandPercent,
  };

  @override
  List<Object?> get props => [
    collectionFee,
    ulez,
    materialsWithMarkup,
    adminFeePercentage,
    materialsMarkupBandPercent,
  ];
}

class MultipleFixedPriceJobPayload extends Equatable {
  const MultipleFixedPriceJobPayload({
    required this.workTypeId,
    required this.scopeOfWorks,
    required this.durationHours,
    required this.chosenRate,
    required this.ulezChargeApplicable,
    required this.useAsMainJobType,
    required this.rates,
    required this.breakdown,
  });

  final String workTypeId;
  final String scopeOfWorks;
  final double durationHours;
  final int chosenRate;
  final bool ulezChargeApplicable;
  final bool useAsMainJobType;
  final FixedPriceEstimateRates rates;
  final MultipleFixedPriceJobBreakdown breakdown;

  static int chosenRateFromLabourLevel(String labourRateLevel) =>
      FixedPriceSubmitPayload.chosenRateFromLabourLevel(labourRateLevel);

  Map<String, dynamic> toJson() => {
    'work_type_id': workTypeId,
    'scope_of_works': scopeOfWorks,
    'duration_hours': durationHours,
    'chosen_rate': chosenRate,
    'ulez_charge_applicable': ulezChargeApplicable,
    'use_as_main_job_type': useAsMainJobType,
    'rates': rates.toJson(),
    'breakdown': breakdown.toJson(),
  };

  List<String> validate() {
    final errors = <String>[];
    if (workTypeId.trim().isEmpty) errors.add('Work type is required.');
    if (scopeOfWorks.trim().isEmpty) errors.add('Scope of work is required.');
    if (durationHours <= 0) {
      errors.add('Duration hours must be greater than 0.');
    }
    if (chosenRate < 1 || chosenRate > 3) {
      errors.add('Chosen rate must be 1, 2, or 3.');
    }
    return errors;
  }

  @override
  List<Object?> get props => [
    workTypeId,
    scopeOfWorks,
    durationHours,
    chosenRate,
    ulezChargeApplicable,
    useAsMainJobType,
    rates,
    breakdown,
  ];
}

class MultipleFixedPriceSubmitPayload extends Equatable {
  const MultipleFixedPriceSubmitPayload({
    required this.sourceWorkOrderId,
    required this.userId,
    required this.customerDecision,
    required this.jobs,
    this.rejectionReason = '',
  });

  /// Salesforce Composite accepts at most 25 records; 6 jobs stays within limit
  /// even when both material types are present.
  static const int maxJobs = 6;

  static const String defaultRejectionReason =
      'Customer declined the fixed price estimate.';

  final String sourceWorkOrderId;
  final String userId;
  final String customerDecision;
  final String rejectionReason;
  final List<MultipleFixedPriceJobPayload> jobs;

  Map<String, dynamic> toSubmitJson() => {
    'source_work_order_id': sourceWorkOrderId,
    'user_id': userId,
    'customer_decision': customerDecision,
    if (customerDecision.trim().toLowerCase() == 'reject')
      'rejection_reason': rejectionReason.trim().isEmpty
          ? defaultRejectionReason
          : rejectionReason.trim(),
    'jobs': jobs.map((j) => j.toJson()).toList(),
  };

  List<String> validate() {
    final errors = <String>[];
    if (sourceWorkOrderId.trim().isEmpty) {
      errors.add('Source work order is required.');
    }
    if (userId.trim().isEmpty) {
      errors.add('User id is required to raise this work order.');
    } else if (!AuthUser.isSalesforceId(userId)) {
      errors.add(
        'A valid Salesforce engineer id is required to raise this work order.',
      );
    }
    if (customerDecision.trim().isEmpty) {
      errors.add('Customer decision is required.');
    }
    if (customerDecision.trim().toLowerCase() == 'reject' &&
        rejectionReason.trim().isEmpty) {
      errors.add(
        'Rejection reason is required when the estimate is rejected.',
      );
    }
    if (jobs.isEmpty) {
      errors.add('At least one job is required.');
    } else if (jobs.length > maxJobs) {
      errors.add(
        'A maximum of $maxJobs fixed price jobs can be submitted at once.',
      );
    }
    for (final job in jobs) {
      errors.addAll(job.validate());
    }
    return errors;
  }

  @override
  List<Object?> get props => [
    sourceWorkOrderId,
    userId,
    customerDecision,
    rejectionReason,
    jobs,
  ];
}
