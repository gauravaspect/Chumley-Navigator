import 'package:equatable/equatable.dart';

/// Client-side fixed price agreement payload (wizard output).
///
/// See [fixed_price_payload.md] for field definitions.
/// Use [toSalesforceJson] when posting to Salesforce-validated endpoints.
class FixedPriceSubmitPayload extends Equatable {
  const FixedPriceSubmitPayload({
    required this.workOrderId,
    required this.customerEmail,
    required this.earliestRequestedDate,
    required this.tradeId,
    required this.categoryId,
    required this.workTypeId,
    required this.scopeOfWork,
    this.additionalScope2 = '',
    this.additionalScope3 = '',
    required this.collectionFeeApplicable,
    required this.listPriceServiceCode,
    required this.operativeMaterials,
    required this.chargeDrainagePatches,
    required this.aspectMaterials,
    required this.ulezChargeApplicable,
    required this.labourRateLevel,
    this.zonalDiscountPercentage = 10,
    this.otherDiscounts = const FixedPriceOtherDiscounts(),
    required this.customerConfirmationChoice,
    this.durationHours,
    this.jobType = 'Fixed Price (Single)',
    this.status = 'Pending Confirmation',
    this.generateDepositInvoice = true,
    this.workCommencingImmediately = true,
    this.paymentLinkSent = true,
    required this.pricingSummary,
    this.sourceWorkOrderId,
  });

  final String workOrderId;
  final String? sourceWorkOrderId;
  final String customerEmail;
  final String earliestRequestedDate;
  final String jobType;
  final String status;
  final String tradeId;
  final String categoryId;
  final String workTypeId;
  final String scopeOfWork;
  final String additionalScope2;
  final String additionalScope3;
  final bool collectionFeeApplicable;
  final String listPriceServiceCode;
  final FixedPriceMaterialsLine operativeMaterials;
  final bool chargeDrainagePatches;
  final FixedPriceMaterialsLine aspectMaterials;
  final bool ulezChargeApplicable;
  final String labourRateLevel;
  final double zonalDiscountPercentage;
  final FixedPriceOtherDiscounts otherDiscounts;
  final String customerConfirmationChoice;
  final double? durationHours;
  final bool generateDepositInvoice;
  final bool workCommencingImmediately;
  final bool paymentLinkSent;
  final FixedPricePricingSummary pricingSummary;

  static const double drainagePatchesFee = 45.0;
  static const double ulezFlatRate = 12.5;
  static const double collectionFlatRate = 20.0;

  static const Map<String, double> listPriceByServiceCode = {
    'standard': 80.0,
    'emergency': 150.0,
    'diagnostic': 95.0,
    'none': 0.0,
  };

  /// Flat attendance fees (legacy UI labels). Prefer [hourlyRateForLevel].
  static const Map<String, double> attendanceFeeByRateLevel = {
    'Rate 1': 80.0,
    'Rate 2': 90.0,
    'Rate 3': 100.0,
  };

  static const FixedPriceZonedRates defaultZonedRates = FixedPriceZonedRates(
    zone1: 80.0,
    zone2: 90.0,
    zone3: 100.0,
  );

  /// Hourly rate for a labour level from zoned rates (Rate 1→zone1, etc.).
  static double hourlyRateForLevel(
    String labourRateLevel, [
    FixedPriceZonedRates zonedRates = defaultZonedRates,
  ]) {
    switch (labourRateLevel.trim()) {
      case 'Rate 2':
        return zonedRates.zone2;
      case 'Rate 3':
        return zonedRates.zone3;
      case 'Rate 1':
      default:
        return zonedRates.zone1;
    }
  }

  /// Labour charge = duration_hours × selected zoned hourly rate.
  static double labourCharge({
    required String labourRateLevel,
    required double? durationHours,
    FixedPriceZonedRates zonedRates = defaultZonedRates,
  }) {
    final hours = durationHours ?? 0.0;
    if (hours <= 0) return 0.0;
    return hours * hourlyRateForLevel(labourRateLevel, zonedRates);
  }

  /// Builds pricing summary from wizard selections (mirrors [FixedPricePage]).
  factory FixedPriceSubmitPayload.fromWizard({
    required String workOrderId,
    String? sourceWorkOrderId,
    required String customerEmail,
    required String earliestRequestedDate,
    required String tradeId,
    required String categoryId,
    required String workTypeId,
    required String scopeOfWork,
    String additionalScope2 = '',
    String additionalScope3 = '',
    required bool collectionFeeApplicable,
    required String listPriceServiceCode,
    required double operativeMaterialsCost,
    String operativeMaterialsDescription = '',
    required bool chargeDrainagePatches,
    required double aspectMaterialsCost,
    String aspectMaterialsDescription = '',
    required bool ulezChargeApplicable,
    required String labourRateLevel,
    double zonalDiscountPercentage = 10,
    FixedPriceOtherDiscounts otherDiscounts = const FixedPriceOtherDiscounts(),
    required String customerConfirmationChoice,
    double? durationHours,
    bool generateDepositInvoice = true,
    bool workCommencingImmediately = true,
    bool paymentLinkSent = true,
    String jobType = 'Fixed Price (Single)',
    String status = 'Pending Confirmation',
  }) {
    final listPrice = listPriceByServiceCode[listPriceServiceCode] ?? 0.0;
    final attendance = labourCharge(
      labourRateLevel: labourRateLevel,
      durationHours: durationHours,
    );
    final materialsCharge = operativeMaterialsCost + aspectMaterialsCost;
    final ulez = ulezChargeApplicable ? ulezFlatRate : 0.0;
    final collection = collectionFeeApplicable ? collectionFlatRate : 0.0;
    final drainage = chargeDrainagePatches ? drainagePatchesFee : 0.0;
    final subtotal =
        listPrice + materialsCharge + attendance + ulez + collection + drainage;
    final vat = subtotal * 0.2;
    final totalInclVat = subtotal + vat;
    final deposit = totalInclVat * 0.5;

    return FixedPriceSubmitPayload(
      workOrderId: workOrderId,
      sourceWorkOrderId: sourceWorkOrderId,
      customerEmail: customerEmail,
      earliestRequestedDate: earliestRequestedDate,
      jobType: jobType,
      status: status,
      tradeId: tradeId,
      categoryId: categoryId,
      workTypeId: workTypeId,
      scopeOfWork: scopeOfWork,
      additionalScope2: additionalScope2,
      additionalScope3: additionalScope3,
      collectionFeeApplicable: collectionFeeApplicable,
      listPriceServiceCode: listPriceServiceCode,
      operativeMaterials: FixedPriceMaterialsLine(
        cost: operativeMaterialsCost,
        description: operativeMaterialsDescription,
      ),
      chargeDrainagePatches: chargeDrainagePatches,
      aspectMaterials: FixedPriceMaterialsLine(
        cost: aspectMaterialsCost,
        description: aspectMaterialsDescription,
      ),
      ulezChargeApplicable: ulezChargeApplicable,
      labourRateLevel: labourRateLevel,
      zonalDiscountPercentage: zonalDiscountPercentage,
      otherDiscounts: otherDiscounts,
      customerConfirmationChoice: customerConfirmationChoice,
      durationHours: durationHours,
      generateDepositInvoice: generateDepositInvoice,
      workCommencingImmediately: workCommencingImmediately,
      paymentLinkSent: paymentLinkSent,
      pricingSummary: FixedPricePricingSummary(
        listPriceServiceCost: listPrice,
        materialsCharge: materialsCharge,
        attendanceFee: attendance,
        ulezCharge: ulez,
        collectionFee: collection,
        drainagePatchesFee: drainage,
        subtotal: subtotal,
        vatAmount: vat,
        totalInclVat: totalInclVat,
        depositRequired: deposit,
      ),
    );
  }

  String get mergedScopeOfWorks {
    return [
      scopeOfWork.trim(),
      additionalScope2.trim(),
      additionalScope3.trim(),
    ].where((part) => part.isNotEmpty).join('\n\n');
  }

  /// Audit / Navigator-style payload documented in [fixed_price_payload.md].
  Map<String, dynamic> toJson() => {
        'work_order_id': workOrderId,
        if (sourceWorkOrderId != null) 'source_work_order_id': sourceWorkOrderId,
        'customer_email': customerEmail,
        'earliest_requested_date': earliestRequestedDate,
        'job_type': jobType,
        'status': status,
        'trade_id': tradeId,
        'category_id': categoryId,
        'work_type_id': workTypeId,
        'scope_of_work': scopeOfWork,
        'additional_scope_2': additionalScope2,
        'additional_scope_3': additionalScope3,
        if (durationHours != null) 'duration_hours': durationHours,
        'collection_fee_applicable': collectionFeeApplicable,
        'list_price_service_code': listPriceServiceCode,
        'operative_materials': operativeMaterials.toJson(),
        'charge_drainage_patches': chargeDrainagePatches,
        'aspect_materials': aspectMaterials.toJson(),
        'ulez_charge_applicable': ulezChargeApplicable,
        'labour_rate_level': labourRateLevel,
        'zonal_discount_percentage': zonalDiscountPercentage,
        'other_discounts': otherDiscounts.toJson(),
        'customer_confirmation_choice': customerConfirmationChoice,
        'generate_deposit_invoice': generateDepositInvoice,
        'work_commencing_immediately': workCommencingImmediately,
        'payment_link_sent': paymentLinkSent,
        'pricing_summary': pricingSummary.toJson(),
      };

  /// Salesforce-validated submission shape.
  Map<String, dynamic> toSalesforceJson({
    required FixedPriceSalesforceContext context,
    FixedPriceZonedRates zonedRates = defaultZonedRates,
  }) =>
      toSubmitJson(context: context, zonedRates: zonedRates);

  /// POST /api/work-orders submission body.
  Map<String, dynamic> toSubmitJson({
    required FixedPriceSalesforceContext context,
    FixedPriceZonedRates zonedRates = defaultZonedRates,
  }) {
    final breakdown = buildEstimateBreakdown(
      context,
      zonedRates: zonedRates,
    );

    return {
      'source_work_order_id': sourceWorkOrderId ?? workOrderId,
      'work_type_id': workTypeId,
      if (durationHours != null) 'duration_hours': durationHours,
      'scope_of_works': mergedScopeOfWorks,
      'drainage_patches':
          chargeDrainagePatches ? drainagePatchesFee : 0.0,
      'materials_operative': operativeMaterials.cost,
      'materials_aspect': aspectMaterials.cost,
      'customer_decision': _customerDecisionForSalesforce(),
      'estimate': FixedPriceEstimate(
        context: FixedPriceEstimateContext(
          siteId: context.siteId,
          accountId: context.accountId,
          contactId: context.contactId,
          resolvedServiceFeePct: context.resolvedServiceFeePct,
          resolvedMarkupPct: context.resolvedMarkupPct,
        ),
        rates: FixedPriceEstimateRates(
          operativeSharePct: context.operativeSharePct,
          zonedRates: zonedRates,
        ),
        breakdown: breakdown,
      ).toJson(),
    };
  }

  /// Estimate breakdown matching POST /api/work-orders sample:
  /// labour = duration_hours × zoned hourly rate for selected Rate level.
  FixedPriceEstimateBreakdown buildEstimateBreakdown(
    FixedPriceSalesforceContext context, {
    FixedPriceZonedRates zonedRates = defaultZonedRates,
  }) {
    final labour = labourCharge(
      labourRateLevel: labourRateLevel,
      durationHours: durationHours,
      zonedRates: zonedRates,
    );
    final materials = pricingSummary.materialsCharge;
    final listPrice = pricingSummary.listPriceServiceCost;
    final collectionFee = pricingSummary.collectionFee;
    final ulez = pricingSummary.ulezCharge;
    final baseSubtotal = labour + materials + listPrice + collectionFee + ulez;
    final serviceFee = baseSubtotal * (context.resolvedServiceFeePct / 100);
    final subtotal = baseSubtotal + serviceFee;
    final vat = subtotal * 0.2;
    final total = subtotal + vat;
    final deposit = total * 0.5;

    return FixedPriceEstimateBreakdown(
      labour: labour,
      materials: materials,
      listPrice: listPrice,
      collectionFee: collectionFee,
      ulez: ulez,
      serviceFee: serviceFee,
      subtotal: subtotal,
      vat: vat,
      total: total,
      deposit: deposit,
    );
  }

  /// Returns validation errors for wizard + API submission.
  List<String> validate({FixedPriceSalesforceContext? salesforceContext}) {
    final errors = <String>[];

    if ((sourceWorkOrderId ?? workOrderId).trim().isEmpty) {
      errors.add('Work order is required.');
    }
    if (tradeId.trim().isEmpty) {
      errors.add('Trade is required.');
    }
    if (categoryId.trim().isEmpty) {
      errors.add('Category is required.');
    }
    if (workTypeId.trim().isEmpty) {
      errors.add('Work type is required.');
    }
    if (mergedScopeOfWorks.trim().isEmpty) {
      errors.add('Scope of work is required.');
    } else if (scopeOfWork.trim().split('\n').length < 5) {
      errors.add('Scope of work must be at least 5 lines.');
    }
    if (listPriceServiceCode.trim().isEmpty) {
      errors.add('List price service is required.');
    }
    if (operativeMaterials.cost < 0 || aspectMaterials.cost < 0) {
      errors.add('Material costs cannot be negative.');
    }
    if (labourRateLevel.trim().isEmpty) {
      errors.add('Labour rate is required.');
    }
    if (durationHours == null || durationHours! <= 0) {
      errors.add('Duration hours must be greater than 0.');
    }
    if (customerConfirmationChoice.trim().isEmpty) {
      errors.add('Customer confirmation choice is required.');
    }

    return errors;
  }

  String _customerDecisionForSalesforce() {
    final normalized = customerConfirmationChoice.trim().toLowerCase();
    if (normalized.contains('reject')) return 'reject';
    return 'send';
  }

  @override
  List<Object?> get props => [
        workOrderId,
        sourceWorkOrderId,
        customerEmail,
        earliestRequestedDate,
        jobType,
        status,
        tradeId,
        categoryId,
        workTypeId,
        scopeOfWork,
        additionalScope2,
        additionalScope3,
        collectionFeeApplicable,
        listPriceServiceCode,
        operativeMaterials,
        chargeDrainagePatches,
        aspectMaterials,
        ulezChargeApplicable,
        labourRateLevel,
        zonalDiscountPercentage,
        otherDiscounts,
        customerConfirmationChoice,
        durationHours,
        generateDepositInvoice,
        workCommencingImmediately,
        paymentLinkSent,
        pricingSummary,
      ];
}

class FixedPriceMaterialsLine extends Equatable {
  const FixedPriceMaterialsLine({
    this.cost = 0,
    this.description = '',
  });

  final double cost;
  final String description;

  Map<String, dynamic> toJson() => {
        'cost': cost,
        'description': description,
      };

  @override
  List<Object?> get props => [cost, description];
}

class FixedPriceOtherDiscounts extends Equatable {
  const FixedPriceOtherDiscounts({
    this.dogDiscountPercentage = 0,
    this.jobDurationDiscountPercentage = 0,
  });

  final double dogDiscountPercentage;
  final double jobDurationDiscountPercentage;

  Map<String, dynamic> toJson() => {
        'dog_discount_percentage': dogDiscountPercentage,
        'job_duration_discount_percentage': jobDurationDiscountPercentage,
      };

  @override
  List<Object?> get props => [
        dogDiscountPercentage,
        jobDurationDiscountPercentage,
      ];
}

class FixedPricePricingSummary extends Equatable {
  const FixedPricePricingSummary({
    required this.listPriceServiceCost,
    required this.materialsCharge,
    required this.attendanceFee,
    required this.ulezCharge,
    required this.collectionFee,
    required this.drainagePatchesFee,
    required this.subtotal,
    required this.vatAmount,
    required this.totalInclVat,
    required this.depositRequired,
  });

  final double listPriceServiceCost;
  final double materialsCharge;
  final double attendanceFee;
  final double ulezCharge;
  final double collectionFee;
  final double drainagePatchesFee;
  final double subtotal;
  final double vatAmount;
  final double totalInclVat;
  final double depositRequired;

  Map<String, dynamic> toJson() => {
        'list_price_service_cost': listPriceServiceCost,
        'materials_charge': materialsCharge,
        'attendance_fee': attendanceFee,
        'ulez_charge': ulezCharge,
        'collection_fee': collectionFee,
        'drainage_patches_fee': drainagePatchesFee,
        'subtotal': subtotal,
        'vat_amount': vatAmount,
        'total_incl_vat': totalInclVat,
        'deposit_required': depositRequired,
      };

  @override
  List<Object?> get props => [
        listPriceServiceCost,
        materialsCharge,
        attendanceFee,
        ulezCharge,
        collectionFee,
        drainagePatchesFee,
        subtotal,
        vatAmount,
        totalInclVat,
        depositRequired,
      ];
}

/// Resolved Salesforce ids and commercial terms (usually from work order / account).
class FixedPriceSalesforceContext extends Equatable {
  const FixedPriceSalesforceContext({
    required this.siteId,
    required this.accountId,
    required this.contactId,
    this.resolvedServiceFeePct = 0.0,
    this.resolvedMarkupPct = 0.0,
    this.operativeSharePct = 40.0,
  });

  final String siteId;
  final String accountId;
  final String contactId;
  final double resolvedServiceFeePct;
  final double resolvedMarkupPct;
  final double operativeSharePct;

  @override
  List<Object?> get props => [
        siteId,
        accountId,
        contactId,
        resolvedServiceFeePct,
        resolvedMarkupPct,
        operativeSharePct,
      ];
}

class FixedPriceZonedRates extends Equatable {
  const FixedPriceZonedRates({
    required this.zone1,
    required this.zone2,
    required this.zone3,
  });

  final double zone1;
  final double zone2;
  final double zone3;

  Map<String, dynamic> toJson() => {
        '1': zone1,
        '2': zone2,
        '3': zone3,
      };

  @override
  List<Object?> get props => [zone1, zone2, zone3];
}

class FixedPriceEstimate extends Equatable {
  const FixedPriceEstimate({
    required this.context,
    required this.rates,
    required this.breakdown,
  });

  final FixedPriceEstimateContext context;
  final FixedPriceEstimateRates rates;
  final FixedPriceEstimateBreakdown breakdown;

  Map<String, dynamic> toJson() => {
        'context': context.toJson(),
        'rates': rates.toJson(),
        'breakdown': breakdown.toJson(),
      };

  @override
  List<Object?> get props => [context, rates, breakdown];
}

class FixedPriceEstimateContext extends Equatable {
  const FixedPriceEstimateContext({
    required this.siteId,
    required this.accountId,
    required this.contactId,
    required this.resolvedServiceFeePct,
    required this.resolvedMarkupPct,
  });

  final String siteId;
  final String accountId;
  final String contactId;
  final double resolvedServiceFeePct;
  final double resolvedMarkupPct;

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'account_id': accountId,
        'contact_id': contactId,
        'resolved_service_fee_pct': resolvedServiceFeePct,
        'resolved_markup_pct': resolvedMarkupPct,
      };

  @override
  List<Object?> get props => [
        siteId,
        accountId,
        contactId,
        resolvedServiceFeePct,
        resolvedMarkupPct,
      ];
}

class FixedPriceEstimateRates extends Equatable {
  const FixedPriceEstimateRates({
    required this.operativeSharePct,
    required this.zonedRates,
  });

  final double operativeSharePct;
  final FixedPriceZonedRates zonedRates;

  Map<String, dynamic> toJson() => {
        'operative_share_pct': operativeSharePct,
        'zoned_rates': zonedRates.toJson(),
      };

  @override
  List<Object?> get props => [operativeSharePct, zonedRates];
}

class FixedPriceEstimateBreakdown extends Equatable {
  const FixedPriceEstimateBreakdown({
    required this.labour,
    required this.materials,
    required this.listPrice,
    required this.collectionFee,
    required this.ulez,
    required this.serviceFee,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.deposit,
  });

  final double labour;
  final double materials;
  final double listPrice;
  final double collectionFee;
  final double ulez;
  final double serviceFee;
  final double subtotal;
  final double vat;
  final double total;
  final double deposit;

  Map<String, dynamic> toJson() => {
        'labour': labour,
        'materials': materials,
        'list_price': listPrice,
        'collection_fee': collectionFee,
        'ulez': ulez,
        'service_fee': serviceFee,
        'subtotal': subtotal,
        'vat': vat,
        'total': total,
        'deposit': deposit,
      };

  @override
  List<Object?> get props => [
        labour,
        materials,
        listPrice,
        collectionFee,
        ulez,
        serviceFee,
        subtotal,
        vat,
        total,
        deposit,
      ];
}
