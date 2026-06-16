enum BadgeTier { bronze, silver, gold, platinum, diamond, oneOff }

enum MilestoneCategory {
  timeInBusiness,
  fiveStarReviews,
  serviceAppointments,
  milesDriven,
  absenceFreeStreak,
  sitesCovered,
  tqrsPassed,
  vcrsCompleted,
  acrsCompleted,
  estimatesWon,
  earnings,
  joining,
}

class MilestoneBadge {
  final MilestoneCategory category;
  final BadgeTier tier;
  final String badgeName;
  final int threshold;       // numeric value to reach this tier
  final String unit;         // display unit string, e.g. "months", "reviews", "SAs"
  final bool _unlocked;       // true = engineer has reached/passed threshold
  final int? _currentValue;   // engineer's current value for this metric (nullable)

  const MilestoneBadge({
    required this.category,
    required this.tier,
    required this.badgeName,
    required this.threshold,
    required this.unit,
    required bool unlocked,
    int? currentValue,
  }) : _unlocked = unlocked,
       _currentValue = currentValue;

  static final Map<String, bool> _unlockedOverrides = {};
  static final Map<String, int?> _currentValueOverrides = {};
  static final Map<String, double> _progressOverrides = {};

  String get id => '${category.name}-${tier.name}';

  bool get unlocked => _unlockedOverrides[id] ?? _unlocked;
  set unlocked(bool value) => _unlockedOverrides[id] = value;

  int? get currentValue => _currentValueOverrides[id] ?? _currentValue;
  set currentValue(int? value) => _currentValueOverrides[id] = value;

  double get progress {
    if (_progressOverrides.containsKey(id)) return _progressOverrides[id]!;
    if (unlocked) return 1.0;
    if (currentValue == null || threshold == 0) return 0.0;
    return (currentValue! / threshold).clamp(0.0, 1.0);
  }
  set progress(double value) => _progressOverrides[id] = value;
}
