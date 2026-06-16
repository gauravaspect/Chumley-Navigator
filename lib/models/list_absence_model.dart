import 'package:equatable/equatable.dart';

/// API envelope: `{ success, data: [...] }`
class ListMyAbsenceResponse extends Equatable {
  const ListMyAbsenceResponse({
    this.success = false,
    this.absences = const [],
  });

  final bool success;
  final List<AbsenceItem> absences;

  factory ListMyAbsenceResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    final absences = rawData is List
        ? rawData
        .whereType<Map>()
        .map(
          (item) => AbsenceItem.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList(growable: false)
        : <AbsenceItem>[];

    return ListMyAbsenceResponse(
      success: json['success'] == true,
      absences: absences,
    );
  }

  @override
  List<Object?> get props => [success, absences];
}

/// Offline cache model.
class AbsenceCache extends Equatable {
  const AbsenceCache({
    this.absences = const [],
  });

  final List<AbsenceItem> absences;

  factory AbsenceCache.fromResponse(
      ListMyAbsenceResponse response,
      ) {
    return AbsenceCache(
      absences: response.absences,
    );
  }

  ListMyAbsenceResponse toResponse() {
    return ListMyAbsenceResponse(
      success: true,
      absences: absences,
    );
  }

  factory AbsenceCache.fromJson(Map<String, dynamic> json) {
    final rawAbsences = json['absences'];

    final absences = rawAbsences is List
        ? rawAbsences
        .whereType<Map>()
        .map(
          (item) => AbsenceItem.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList(growable: false)
        : <AbsenceItem>[];

    return AbsenceCache(
      absences: absences,
    );
  }

  Map<String, dynamic> toJson() => {
    'absences': absences.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [absences];
}

class AbsenceItem extends Equatable {
  const AbsenceItem({
    this.id = '',
    this.absenceNumber = '',
    this.type = '',
    this.start = '',
    this.end = '',
    this.status = '',
    this.approved = false,
    this.description = '',
    this.sentForApprovalAt = '',
  });

  final String id;
  final String absenceNumber;
  final String type;
  final String start;
  final String end;
  final String status;
  final bool approved;
  final String description;
  final String sentForApprovalAt;

  factory AbsenceItem.fromJson(Map<String, dynamic> json) {
    return AbsenceItem(
      id: (json['id'] ?? '').toString(),
      absenceNumber: (json['absenceNumber'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      approved: json['approved'] == true,
      description: (json['description'] ?? '').toString(),
      sentForApprovalAt: (json['sentForApprovalAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'absenceNumber': absenceNumber,
    'type': type,
    'start': start,
    'end': end,
    'status': status,
    'approved': approved,
    'description': description,
    'sentForApprovalAt':
    sentForApprovalAt.isEmpty ? null : sentForApprovalAt,
  };

  @override
  List<Object?> get props => [
    id,
    absenceNumber,
    type,
    start,
    end,
    status,
    approved,
    description,
    sentForApprovalAt,
  ];
}