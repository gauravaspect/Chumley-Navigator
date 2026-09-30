import 'package:equatable/equatable.dart';

class MilestonesResponse extends Equatable {
  const MilestonesResponse({
    this.engineerId = '',
    this.engineerName = '',
    this.tradeGroup = '',
    this.currentPoints = 0,
    this.currentMilestone,
    this.nextMilestone,
    this.nextMilestoneProgress = 0.0,
    this.pointsToNextMilestone = 0,
    this.milestones = const [],
  });

  final String engineerId;
  final String engineerName;
  final String tradeGroup;
  final int currentPoints;
  final MilestoneItem? currentMilestone;
  final MilestoneItem? nextMilestone;
  final double nextMilestoneProgress;
  final int pointsToNextMilestone;
  final List<MilestoneItem> milestones;

  factory MilestonesResponse.fromJson(Map<String, dynamic> json) {
    final rawMilestones = json['milestones'];
    final milestonesList = rawMilestones is List
        ? rawMilestones
              .whereType<Map>()
              .map(
                (item) =>
                    MilestoneItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <MilestoneItem>[];

    return MilestonesResponse(
      engineerId: (json['engineerId'] ?? '').toString(),
      engineerName: (json['engineerName'] ?? '').toString(),
      tradeGroup: (json['tradeGroup'] ?? '').toString(),
      currentPoints: _readInt(json['currentPoints']),
      currentMilestone: json['currentMilestone'] != null
          ? MilestoneItem.fromJson(
              Map<String, dynamic>.from(json['currentMilestone']),
            )
          : null,
      nextMilestone: json['nextMilestone'] != null
          ? MilestoneItem.fromJson(
              Map<String, dynamic>.from(json['nextMilestone']),
            )
          : null,
      nextMilestoneProgress: _readDouble(json['nextMilestoneProgress']),
      pointsToNextMilestone: _readInt(json['pointsToNextMilestone']),
      milestones: milestonesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'engineerId': engineerId,
    'engineerName': engineerName,
    'tradeGroup': tradeGroup,
    'currentPoints': currentPoints,
    'currentMilestone': currentMilestone?.toJson(),
    'nextMilestone': nextMilestone?.toJson(),
    'nextMilestoneProgress': nextMilestoneProgress,
    'pointsToNextMilestone': pointsToNextMilestone,
    'milestones': milestones.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    engineerId,
    engineerName,
    tradeGroup,
    currentPoints,
    currentMilestone,
    nextMilestone,
    nextMilestoneProgress,
    pointsToNextMilestone,
    milestones,
  ];
}

class MilestoneItem extends Equatable {
  const MilestoneItem({
    this.order = 0,
    required this.title,
    required this.pointsRequired,
    this.description,
    this.reward,
    this.isUnlocked = false,
  });

  final int order;
  final String title;
  final int pointsRequired;
  final String? description;
  final String? reward;
  final bool isUnlocked;

  factory MilestoneItem.fromJson(Map<String, dynamic> json) {
    return MilestoneItem(
      order: _readInt(json['order']),
      title: (json['title'] ?? '').toString(),
      pointsRequired: _readInt(json['pointsRequired']),
      description: json['description']?.toString(),
      reward: json['reward']?.toString(),
      isUnlocked: json['isUnlocked'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'order': order,
    'title': title,
    'pointsRequired': pointsRequired,
    'description': description,
    'reward': reward,
    'isUnlocked': isUnlocked,
  };

  @override
  List<Object?> get props => [
    order,
    title,
    pointsRequired,
    description,
    reward,
    isUnlocked,
  ];
}

int _readInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(dynamic value, [double fallback = 0.0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
