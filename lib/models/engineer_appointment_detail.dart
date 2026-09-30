import 'package:chumley_navigator/models/user_model.dart';
import 'package:equatable/equatable.dart';

class EngineerAppointmentDetail extends Equatable {
  const EngineerAppointmentDetail({
    required this.status,
    this.allowedNextStatuses = const [],
    this.appointment,
    this.changed,
  });

  final String status;
  final List<String> allowedNextStatuses;
  final Appointment? appointment;
  final bool? changed;

  factory EngineerAppointmentDetail.fromJson(Map<String, dynamic> json) {
    final root = _asMap(json['data']) ?? json;
    final appointmentJson =
        _asMap(
          root['appointment'] ??
              root['service_appointment'] ??
              root['serviceAppointment'],
        ) ??
        (root.containsKey('id') || root.containsKey('appointment_number')
            ? root
            : null);

    final statusStr = (appointmentJson?['status'] ?? root['status'] ?? '')
        .toString();
    final allowedStatuses = _readStringList(
      appointmentJson?['allowed_next_statuses'] ??
          appointmentJson?['allowedNextStatuses'] ??
          root['allowed_next_statuses'] ??
          root['allowedNextStatuses'],
    );

    return EngineerAppointmentDetail(
      status: statusStr,
      allowedNextStatuses: allowedStatuses,
      appointment: appointmentJson != null
          ? Appointment.fromJson(appointmentJson)
          : null,
      changed: root['changed'] is bool ? root['changed'] as bool : null,
    );
  }

  EngineerAppointmentDetail copyWith({
    String? status,
    List<String>? allowedNextStatuses,
    Appointment? appointment,
    bool? changed,
  }) {
    return EngineerAppointmentDetail(
      status: status ?? this.status,
      allowedNextStatuses: allowedNextStatuses ?? this.allowedNextStatuses,
      appointment: appointment ?? this.appointment,
      changed: changed ?? this.changed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allowedNextStatuses,
    appointment,
    changed,
  ];
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<String> _readStringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => e?.toString().trim() ?? '')
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}
