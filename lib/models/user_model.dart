import 'package:equatable/equatable.dart';

class KpiPool extends Equatable {
  const KpiPool({
    this.score = 0,
    this.metrics = const {},
  });

  final double score;
  final Map<String, dynamic> metrics;

  factory KpiPool.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KpiPool();
    return KpiPool(
      score: _readDouble(json['score']),
      metrics: _readMap(json['metrics']),
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'metrics': metrics,
  };

  @override
  List<Object?> get props => [score, metrics];
}

class Appointment extends Equatable {
  const Appointment({
    this.id = '',
    this.appointmentNumber = '',
    this.scheduledStart,
    this.status = '',
    this.title = '',
    this.type = '',
    this.sourceWorkOrderId = '',
    this.siteId = '',
    this.accountId = '',
    this.contactId = '',
    this.customerEmail = '',
    this.resolvedServiceFeePct = 0.0,
    this.resolvedMarkupPct = 0.0,
    this.operativeSharePct = 40.0,
  });

  final String id;
  final String appointmentNumber;
  final DateTime? scheduledStart;
  final String status;
  final String title;
  final String type;
  final String sourceWorkOrderId;
  final String siteId;
  final String accountId;
  final String contactId;
  final String customerEmail;
  final double resolvedServiceFeePct;
  final double resolvedMarkupPct;
  final double operativeSharePct;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final root = _asMap(
          json['service_appointment'] ?? json['serviceAppointment'],
        ) ??
        json;
    final workOrder = _asMap(root['work_order'] ?? root['workOrder']);
    final site = _asMap(
      root['site'] ?? workOrder?['site'] ?? root['Site__r'],
    );
    final account = _asMap(
      root['account'] ?? workOrder?['account'] ?? root['Account'],
    );
    final contact = _asMap(
      root['contact'] ?? workOrder?['contact'] ?? root['Contact'],
    );
    final sources = [root, if (workOrder != null) workOrder];

    return Appointment(
      id: (root['id'] ?? '').toString(),
      appointmentNumber: (root['appointment_number'] ??
              root['appointmentNumber'] ??
              root['AppointmentNumber'] ??
              '')
          .toString(),
      scheduledStart: DateTime.tryParse(
        (root['scheduled_start'] ??
                root['scheduledStart'] ??
                root['SchedStartTime'] ??
                '')
            .toString(),
      ),
      status: (root['status'] ?? root['Status'] ?? '').toString(),
      title: (root['title'] ?? root['Subject'] ?? '').toString(),
      type: (root['type'] ?? root['Type__c'] ?? '').toString(),
      sourceWorkOrderId: _resolveWorkOrderId(root, workOrder),
      siteId: _readIdFromSources(
        sources,
        const ['site_id', 'siteId', 'SiteId', 'Site__c', 'site'],
        nested: site,
        nestedKeys: const ['id', 'site_id', 'Site__c'],
      ),
      accountId: _readIdFromSources(
        sources,
        const [
          'account_id',
          'accountId',
          'AccountId',
          'Account__c',
          'account',
        ],
        nested: account,
        nestedKeys: const ['id', 'account_id', 'AccountId'],
      ),
      contactId: _readIdFromSources(
        sources,
        const [
          'contact_id',
          'contactId',
          'ContactId',
          'Contact__c',
          'contact',
        ],
        nested: contact,
        nestedKeys: const ['id', 'contact_id', 'ContactId'],
      ),
      customerEmail: _readCustomerEmail(root, contact, account),
      resolvedServiceFeePct: _readDouble(
        root['resolved_service_fee_pct'] ??
            workOrder?['resolved_service_fee_pct'],
      ),
      resolvedMarkupPct: _readDouble(
        root['resolved_markup_pct'] ?? workOrder?['resolved_markup_pct'],
      ),
      operativeSharePct: _readDouble(
        root['operative_share_pct'] ?? workOrder?['operative_share_pct'],
        40.0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointment_number': appointmentNumber,
    'scheduled_start': scheduledStart?.toIso8601String(),
    'status': status,
    'title': title,
    'type': type,
    'source_work_order_id': sourceWorkOrderId,
    'site_id': siteId,
    'account_id': accountId,
    'contact_id': contactId,
    'customer_email': customerEmail,
    'resolved_service_fee_pct': resolvedServiceFeePct,
    'resolved_markup_pct': resolvedMarkupPct,
    'operative_share_pct': operativeSharePct,
  };

  @override
  List<Object?> get props => [
    id,
    appointmentNumber,
    scheduledStart,
    status,
    title,
    type,
    sourceWorkOrderId,
    siteId,
    accountId,
    contactId,
    customerEmail,
    resolvedServiceFeePct,
    resolvedMarkupPct,
    operativeSharePct,
  ];
}

class UserBio extends Equatable {
  const UserBio({
    this.trade = '',
    this.yearsOfService = 0,
    this.skills = const [],
    this.areasCovered = const [],
    this.description = '',
    this.rateTier = '',
    this.address = '',
    this.allocatedManager = '',
  });

  final String trade;
  final int yearsOfService;
  final List<String> skills;
  final List<String> areasCovered;
  final String description;
  final String rateTier;
  final String address;
  final String allocatedManager;

  factory UserBio.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserBio();
    return UserBio(
      trade: (json['trade'] ?? '').toString(),
      yearsOfService: _readInt(json['years_of_service']),
      skills: _readStringList(json['skills']),
      areasCovered: _readStringList(json['areas_covered']),
      description: (json['description'] ?? '').toString(),
      rateTier: (json['rate_tier'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      allocatedManager: (json['allocated_manager'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trade': trade,
    'years_of_service': yearsOfService,
    'skills': skills,
    'areas_covered': areasCovered,
    'description': description,
    'rate_tier': rateTier,
    'address': address,
    'allocated_manager': allocatedManager,
  };

  @override
  List<Object?> get props => [
    trade,
    yearsOfService,
    skills,
    areasCovered,
    description,
    rateTier,
    address,
    allocatedManager,
  ];
}

class UserDashboard extends Equatable {
  const UserDashboard({
    this.appointmentsThisMonth = const [],
  });

  final List<Appointment> appointmentsThisMonth;

  factory UserDashboard.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserDashboard();
    return UserDashboard(
      appointmentsThisMonth: _readList(
        json['appointments_this_month'] ?? json['service_appointments'],
        Appointment.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'appointments_this_month':
        appointmentsThisMonth.map((item) => item.toJson()).toList(),
  };

  @override
  List<Object?> get props => [appointmentsThisMonth];
}

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
      avgConvertedEstimateValue:
          _readDouble(json['avg_converted_estimate_value']),
      absencePercentage: _readDouble(json['absence_percentage']),
      cases: _readDouble(json['cases']),
      avgReviewRating: _readDouble(json['avg_review_rating']),
      drivingScore: _readDouble(json['driving_score']),
      unclosedJobs: _readDouble(json['unclosed_jobs']),
      paymentCollectionPercentage:
          _readDouble(json['payment_collection_percentage']),
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

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

List<T> _readList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
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

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _readNestedId(
  Map<String, dynamic> json,
  List<String> keys, {
  Map<String, dynamic>? nested,
  List<String> nestedKeys = const ['id'],
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final nestedKey in nestedKeys) {
        final id = map[nestedKey];
        if (id != null && id.toString().trim().isNotEmpty) {
          return id.toString().trim();
        }
      }
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }

  if (nested != null) {
    for (final nestedKey in nestedKeys) {
      final id = nested[nestedKey];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
    }
  }

  return '';
}

String _readIdFromSources(
  List<Map<String, dynamic>> sources,
  List<String> flatKeys, {
  Map<String, dynamic>? nested,
  List<String> nestedKeys = const ['id'],
}) {
  for (final source in sources) {
    final id = _readNestedId(
      source,
      flatKeys,
      nested: nested,
      nestedKeys: nestedKeys,
    );
    if (id.isNotEmpty) return id;
  }
  return '';
}

String _readCustomerEmail(
  Map<String, dynamic> json,
  Map<String, dynamic>? contact,
  Map<String, dynamic>? account,
) {
  final candidates = [
    json['customer_email'],
    json['customerEmail'],
    contact?['email'],
    contact?['Email'],
    account?['email'],
    account?['Email'],
    json['email'],
  ];
  for (final value in candidates) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

bool _isSalesforceWorkOrderId(String id) {
  final normalized = id.trim().toUpperCase();
  return normalized.startsWith('0WO');
}

String _resolveWorkOrderId(
  Map<String, dynamic> json,
  Map<String, dynamic>? workOrder,
) {
  final candidates = <String>[];

  void addCandidate(String value) {
    final text = value.trim();
    if (text.isNotEmpty && !candidates.contains(text)) {
      candidates.add(text);
    }
  }

  for (final source in [json, if (workOrder != null) workOrder]) {
    addCandidate(_readNestedId(source, const [
      'source_work_order_id',
      'parent_work_order_id',
      'parent_record_id',
      'ParentRecordId',
      'work_order_id',
      'workOrderId',
      'work_order',
    ], nested: workOrder, nestedKeys: const ['id', 'source_work_order_id']));
  }

  if (workOrder != null) {
    addCandidate((workOrder['id'] ?? '').toString());
  }

  for (final id in candidates) {
    if (_isSalesforceWorkOrderId(id)) return id;
  }

  return candidates.isNotEmpty ? candidates.first : '';
}
