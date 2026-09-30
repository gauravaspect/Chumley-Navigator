import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  const Appointment({
    this.id = '',
    this.appointmentNumber = '',
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.status = '',
    this.title = '',
    this.type = '',
    this.workType = '',
    this.sourceWorkOrderId = '',
    this.siteId = '',
    this.siteName = '',
    this.siteAddress = '',
    this.sitePostcode = '',
    this.accountId = '',
    this.contactId = '',
    this.customerName = '',
    this.customerContactName = '',
    this.customerEmail = '',
    this.allowedNextStatuses = const [],
    this.updatedAt,
    this.resolvedServiceFeePct = 0.0,
    this.resolvedMarkupPct = 0.0,
    this.operativeSharePct = 40.0,
  });

  final String id;
  final String appointmentNumber;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String status;
  final String title;
  final String type;
  final String workType;
  final String sourceWorkOrderId;
  final String siteId;
  final String siteName;
  final String siteAddress;
  final String sitePostcode;
  final String accountId;
  final String contactId;
  final String customerName;
  final String customerContactName;
  final String customerEmail;
  final List<String> allowedNextStatuses;
  final DateTime? updatedAt;
  final double resolvedServiceFeePct;
  final double resolvedMarkupPct;
  final double operativeSharePct;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final root =
        _asMap(
          json['service_appointment'] ??
              json['serviceAppointment'] ??
              json['appointment'],
        ) ??
        json;
    final workOrder = _asMap(root['work_order'] ?? root['workOrder']);
    final site = _asMap(root['site'] ?? workOrder?['site'] ?? root['Site__r']);
    final account = _asMap(
      root['account'] ?? workOrder?['account'] ?? root['Account'],
    );
    final contact = _asMap(
      root['contact'] ?? workOrder?['contact'] ?? root['Contact'],
    );
    final customer = _asMap(root['customer'] ?? workOrder?['customer']);
    final sources = [root, ?workOrder];

    final workTypeStr =
        (root['work_type'] ??
                root['workType'] ??
                root['WorkTypeId'] ??
                workOrder?['work_type'] ??
                '')
            .toString();

    final siteNameStr = (site?['name'] ?? root['site_name'] ?? '').toString();
    final siteAddressStr = (site?['address'] ?? root['site_address'] ?? '')
        .toString();
    final sitePostcodeStr = (site?['postcode'] ?? root['site_postcode'] ?? '')
        .toString();

    final customerNameStr =
        (customer?['name'] ?? account?['name'] ?? root['customer_name'] ?? '')
            .toString();
    final customerContactNameStr =
        (customer?['contact_name'] ??
                contact?['name'] ??
                root['contact_name'] ??
                '')
            .toString();

    return Appointment(
      id: (root['id'] ?? root['Id'] ?? '').toString(),
      appointmentNumber:
          (root['appointment_number'] ??
                  root['appointmentNumber'] ??
                  root['AppointmentNumber'] ??
                  '')
              .toString(),
      scheduledStart: _parseDateTime(
        root['scheduled_start'] ??
            root['scheduledStart'] ??
            root['SchedStartTime'],
      ),
      scheduledEnd: _parseDateTime(
        root['scheduled_end'] ?? root['scheduledEnd'] ?? root['SchedEndTime'],
      ),
      actualStart: _parseDateTime(
        root['actual_start'] ?? root['actualStart'] ?? root['ActualStartTime'],
      ),
      actualEnd: _parseDateTime(
        root['actual_end'] ?? root['actualEnd'] ?? root['ActualEndTime'],
      ),
      status: (root['status'] ?? root['Status'] ?? '').toString(),
      title: (root['title'] ?? root['Subject'] ?? '').toString(),
      type:
          (root['type'] ??
                  root['Type__c'] ??
                  (workTypeStr.isNotEmpty ? workTypeStr : ''))
              .toString(),
      workType: workTypeStr,
      sourceWorkOrderId: _resolveWorkOrderId(root, workOrder),
      siteId: _readIdFromSources(
        sources,
        const ['site_id', 'siteId', 'SiteId', 'Site__c', 'site'],
        nested: site,
        nestedKeys: const ['id', 'site_id', 'Site__c'],
      ),
      siteName: siteNameStr,
      siteAddress: siteAddressStr,
      sitePostcode: sitePostcodeStr,
      accountId: _readIdFromSources(
        sources,
        const ['account_id', 'accountId', 'AccountId', 'Account__c', 'account'],
        nested: account,
        nestedKeys: const ['id', 'account_id', 'AccountId'],
      ),
      contactId: _readIdFromSources(
        sources,
        const ['contact_id', 'contactId', 'ContactId', 'Contact__c', 'contact'],
        nested: contact,
        nestedKeys: const ['id', 'contact_id', 'ContactId'],
      ),
      customerName: customerNameStr,
      customerContactName: customerContactNameStr,
      customerEmail: _readCustomerEmail(root, contact, account),
      allowedNextStatuses: _readStringList(
        root['allowed_next_statuses'] ?? root['allowedNextStatuses'],
      ),
      updatedAt: _parseDateTime(
        root['updated_at'] ?? root['updatedAt'] ?? root['LastModifiedDate'],
      ),
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

  Appointment copyWith({
    String? id,
    String? appointmentNumber,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    String? status,
    String? title,
    String? type,
    String? workType,
    String? sourceWorkOrderId,
    String? siteId,
    String? siteName,
    String? siteAddress,
    String? sitePostcode,
    String? accountId,
    String? contactId,
    String? customerName,
    String? customerContactName,
    String? customerEmail,
    List<String>? allowedNextStatuses,
    DateTime? updatedAt,
    double? resolvedServiceFeePct,
    double? resolvedMarkupPct,
    double? operativeSharePct,
  }) {
    return Appointment(
      id: id ?? this.id,
      appointmentNumber: appointmentNumber ?? this.appointmentNumber,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      status: status ?? this.status,
      title: title ?? this.title,
      type: type ?? this.type,
      workType: workType ?? this.workType,
      sourceWorkOrderId: sourceWorkOrderId ?? this.sourceWorkOrderId,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      siteAddress: siteAddress ?? this.siteAddress,
      sitePostcode: sitePostcode ?? this.sitePostcode,
      accountId: accountId ?? this.accountId,
      contactId: contactId ?? this.contactId,
      customerName: customerName ?? this.customerName,
      customerContactName: customerContactName ?? this.customerContactName,
      customerEmail: customerEmail ?? this.customerEmail,
      allowedNextStatuses: allowedNextStatuses ?? this.allowedNextStatuses,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedServiceFeePct:
          resolvedServiceFeePct ?? this.resolvedServiceFeePct,
      resolvedMarkupPct: resolvedMarkupPct ?? this.resolvedMarkupPct,
      operativeSharePct: operativeSharePct ?? this.operativeSharePct,
    );
  }

  /// Prefer [incoming] fields, but keep work-order / site / account / contact
  /// context from this appointment when the incoming payload omits them
  /// (common for detail API responses that only return display site fields).
  Appointment mergePreservingWorkOrderContext(Appointment incoming) {
    String pick(String newer, String older) =>
        newer.trim().isNotEmpty ? newer.trim() : older;

    return incoming.copyWith(
      sourceWorkOrderId: pick(incoming.sourceWorkOrderId, sourceWorkOrderId),
      siteId: pick(incoming.siteId, siteId),
      siteName: pick(incoming.siteName, siteName),
      siteAddress: pick(incoming.siteAddress, siteAddress),
      sitePostcode: pick(incoming.sitePostcode, sitePostcode),
      accountId: pick(incoming.accountId, accountId),
      contactId: pick(incoming.contactId, contactId),
      customerName: pick(incoming.customerName, customerName),
      customerContactName: pick(
        incoming.customerContactName,
        customerContactName,
      ),
      customerEmail: pick(incoming.customerEmail, customerEmail),
      resolvedServiceFeePct: incoming.resolvedServiceFeePct != 0
          ? incoming.resolvedServiceFeePct
          : null,
      resolvedMarkupPct: incoming.resolvedMarkupPct != 0
          ? incoming.resolvedMarkupPct
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'appointment_number': appointmentNumber,
    'scheduled_start': scheduledStart?.toIso8601String(),
    'scheduled_end': scheduledEnd?.toIso8601String(),
    'actual_start': actualStart?.toIso8601String(),
    'actual_end': actualEnd?.toIso8601String(),
    'status': status,
    'title': title,
    'type': type,
    'work_type': workType,
    'source_work_order_id': sourceWorkOrderId,
    'site_id': siteId,
    'site': {
      'name': siteName,
      'address': siteAddress,
      'postcode': sitePostcode,
    },
    'account_id': accountId,
    'contact_id': contactId,
    'customer': {'name': customerName, 'contact_name': customerContactName},
    'customer_email': customerEmail,
    'allowed_next_statuses': allowedNextStatuses,
    'updated_at': updatedAt?.toIso8601String(),
    'resolved_service_fee_pct': resolvedServiceFeePct,
    'resolved_markup_pct': resolvedMarkupPct,
    'operative_share_pct': operativeSharePct,
  };

  @override
  List<Object?> get props => [
    id,
    appointmentNumber,
    scheduledStart,
    scheduledEnd,
    actualStart,
    actualEnd,
    status,
    title,
    type,
    workType,
    sourceWorkOrderId,
    siteId,
    siteName,
    siteAddress,
    sitePostcode,
    accountId,
    contactId,
    customerName,
    customerContactName,
    customerEmail,
    allowedNextStatuses,
    updatedAt,
    resolvedServiceFeePct,
    resolvedMarkupPct,
    operativeSharePct,
  ];
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
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

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final str = value.toString().trim();
  if (str.isEmpty || str == 'null') return null;
  return DateTime.tryParse(str);
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

  for (final source in [json, ?workOrder]) {
    addCandidate(
      _readNestedId(
        source,
        const [
          'source_work_order_id',
          'parent_work_order_id',
          'parent_record_id',
          'ParentRecordId',
          'work_order_id',
          'workOrderId',
          'work_order',
        ],
        nested: workOrder,
        nestedKeys: const ['id', 'source_work_order_id'],
      ),
    );
  }

  if (workOrder != null) {
    addCandidate((workOrder['id'] ?? '').toString());
  }

  for (final id in candidates) {
    if (_isSalesforceWorkOrderId(id)) return id;
  }

  return candidates.isNotEmpty ? candidates.first : '';
}
