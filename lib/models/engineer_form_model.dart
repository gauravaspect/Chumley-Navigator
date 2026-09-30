import 'package:equatable/equatable.dart';

/// Summary of a form associated with a service appointment.
class EngineerFormSummary extends Equatable {
  const EngineerFormSummary({
    required this.id,
    required this.workTypeId,
    required this.title,
    this.status = 'not_started',
    this.isDraft = false,
    this.isSubmitted = false,
    this.step = 0,
    this.updatedAt,
    this.raw = const {},
  });

  final String id;
  final String workTypeId;
  final String title;
  final String status;
  final bool isDraft;
  final bool isSubmitted;
  final int step;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory EngineerFormSummary.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['form_id'] ?? json['work_type_id'] ?? '')
        .toString();
    final workTypeId =
        (json['work_type_id'] ?? json['workTypeId'] ?? json['type'] ?? id)
            .toString();
    final title =
        (json['title'] ??
                json['name'] ??
                json['form_name'] ??
                json['work_type'] ??
                workTypeId)
            .toString();
    final status = (json['status'] ?? 'not_started').toString();

    DateTime? updatedAt;
    final updatedRaw = json['updated_at'] ?? json['updatedAt'];
    if (updatedRaw != null) {
      updatedAt = DateTime.tryParse(updatedRaw.toString());
    }

    return EngineerFormSummary(
      id: id,
      workTypeId: workTypeId,
      title: title,
      status: status,
      isDraft: status.toLowerCase() == 'draft' || json['is_draft'] == true,
      isSubmitted:
          status.toLowerCase() == 'submitted' ||
          status.toLowerCase() == 'complete' ||
          json['is_submitted'] == true,
      step: (json['step'] is num) ? (json['step'] as num).toInt() : 0,
      updatedAt: updatedAt,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'work_type_id': workTypeId,
    'title': title,
    'status': status,
    'is_draft': isDraft,
    'is_submitted': isSubmitted,
    'step': step,
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    ...raw,
  };

  @override
  List<Object?> get props => [
    id,
    workTypeId,
    title,
    status,
    isDraft,
    isSubmitted,
    step,
    updatedAt,
  ];
}

/// Detailed form schema and responses for drafting/submitting.
class EngineerFormDetail extends Equatable {
  const EngineerFormDetail({
    required this.id,
    required this.workTypeId,
    required this.title,
    this.status = 'draft',
    this.schema = const {},
    this.answers = const {},
    this.photoSlots = const {},
    this.step = 0,
    this.updatedAt,
    this.raw = const {},
  });

  final String id;
  final String workTypeId;
  final String title;
  final String status;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> answers;
  final Map<String, String> photoSlots;
  final int step;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory EngineerFormDetail.fromJson(Map<String, dynamic> json) {
    final root = (json['form'] is Map)
        ? Map<String, dynamic>.from(json['form'])
        : (json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'])
        : json;

    final id = (root['id'] ?? root['form_id'] ?? root['work_type_id'] ?? '')
        .toString();
    final workTypeId =
        (root['work_type_id'] ?? root['workTypeId'] ?? root['type'] ?? id)
            .toString();
    final title =
        (root['title'] ??
                root['name'] ??
                root['form_name'] ??
                root['work_type'] ??
                workTypeId)
            .toString();
    final status = (root['status'] ?? 'draft').toString();

    // Parse answers / responses
    Map<String, dynamic> answers = {};
    final rawAnswers =
        root['answers'] ??
        root['responses'] ??
        root['draft_responses'] ??
        root['data'];
    if (rawAnswers is Map) {
      answers = Map<String, dynamic>.from(rawAnswers);
    }

    // Parse photo slots
    Map<String, String> photoSlots = {};
    final rawPhotos =
        root['photo_slots'] ?? root['photos'] ?? root['photoSlots'];
    if (rawPhotos is Map) {
      photoSlots = rawPhotos.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }

    // Parse schema
    Map<String, dynamic> schema = {};
    final rawSchema = root['schema'] ?? root['fields'] ?? root['sections'];
    if (rawSchema is Map) {
      schema = Map<String, dynamic>.from(rawSchema);
    } else if (rawSchema is List) {
      schema = {'fields': rawSchema};
    }

    DateTime? updatedAt;
    final updatedRaw = root['updated_at'] ?? root['updatedAt'];
    if (updatedRaw != null) {
      updatedAt = DateTime.tryParse(updatedRaw.toString());
    }

    return EngineerFormDetail(
      id: id,
      workTypeId: workTypeId,
      title: title,
      status: status,
      schema: schema,
      answers: answers,
      photoSlots: photoSlots,
      step: (root['step'] is num) ? (root['step'] as num).toInt() : 0,
      updatedAt: updatedAt,
      raw: json,
    );
  }

  Map<String, dynamic> toDraftPayload() => {
    'work_type_id': workTypeId,
    'step': step,
    'answers': answers,
    'photo_slots': photoSlots,
    'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
  };

  Map<String, dynamic> toSubmitPayload() => {
    'work_type_id': workTypeId,
    'answers': answers,
    'photo_slots': photoSlots,
    'submitted_at': DateTime.now().toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    workTypeId,
    title,
    status,
    schema,
    answers,
    photoSlots,
    step,
    updatedAt,
  ];
}
