import 'package:equatable/equatable.dart';

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

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

int _readInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
