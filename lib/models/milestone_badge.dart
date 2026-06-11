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
  final num threshold;       // numeric value to reach this tier
  final String unit;         // display unit string, e.g. "months", "reviews", "SAs"
  final bool unlocked;       // true = engineer has reached/passed threshold
  final num? currentValue;   // engineer's current value for this metric (nullable)

  const MilestoneBadge({
    required this.category,
    required this.tier,
    required this.badgeName,
    required this.threshold,
    required this.unit,
    required this.unlocked,
    this.currentValue,
  });

  /// Progress 0.0–1.0 towards unlocking this badge.
  /// Returns 1.0 if already unlocked.
  double get progress {
    if (unlocked) return 1.0;
    if (currentValue == null || threshold == 0) return 0.0;
    return (currentValue! / threshold).clamp(0.0, 1.0).toDouble();
  }
}
