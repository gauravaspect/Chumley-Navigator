import 'package:equatable/equatable.dart';

/// Engineer record returned from the mobile auth exchange (not the KPI profile).
class AuthUser extends Equatable {
  const AuthUser({
    this.id = '',
    this.email = '',
    this.name = '',
    this.role = '',
    this.azureOid = '',
    this.engineerId = '',
    this.tradeGroups = const [],
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String azureOid;
  final String engineerId;
  final List<String> tradeGroups;

  /// Salesforce Id for work-order create APIs (`user_id`).
  /// Auth exchange `id` is an email slug; [engineerId] is ServiceResource.Id.
  String get workOrderUserId => engineerId.trim();

  /// Salesforce Ids are 15 chars, or 18 with checksum suffix.
  static bool isSalesforceId(String value) {
    final trimmed = value.trim();
    return RegExp(r'^[a-zA-Z0-9]{15}([a-zA-Z0-9]{3})?$').hasMatch(trimmed);
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      azureOid: (json['azureOid'] ?? json['azure_oid'] ?? '').toString(),
      engineerId: (json['engineerId'] ?? json['engineer_id'] ?? '').toString(),
      tradeGroups: _readStringList(json['tradeGroups'] ?? json['trade_groups']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'azureOid': azureOid,
    'engineerId': engineerId,
    'tradeGroups': tradeGroups,
  };

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    azureOid,
    engineerId,
    tradeGroups,
  ];
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}
