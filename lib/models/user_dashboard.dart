import 'package:chumley_navigator/models/appointment.dart';
import 'package:equatable/equatable.dart';

class UserDashboard extends Equatable {
  const UserDashboard({this.appointmentsThisMonth = const []});

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
    'appointments_this_month': appointmentsThisMonth
        .map((item) => item.toJson())
        .toList(),
  };

  @override
  List<Object?> get props => [appointmentsThisMonth];
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
