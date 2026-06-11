import 'package:flutter/material.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';

class CategoryMeta {
  final String label;       // display name
  final String unit;        // unit label for threshold display
  final IconData icon;
  const CategoryMeta({required this.label, required this.unit, required this.icon});
}

const Map<MilestoneCategory, CategoryMeta> categoryMeta = {
  MilestoneCategory.timeInBusiness:     CategoryMeta(label: 'Time in the Business',           unit: 'months',           icon: Icons.calendar_today_outlined),
  MilestoneCategory.fiveStarReviews:    CategoryMeta(label: '5-Star Reviews',                  unit: 'reviews',          icon: Icons.star_outline_rounded),
  MilestoneCategory.serviceAppointments:CategoryMeta(label: 'Service Appointments',            unit: 'SAs',              icon: Icons.check_circle_outline_rounded),
  MilestoneCategory.milesDriven:        CategoryMeta(label: 'Miles Driven',                    unit: 'miles',            icon: Icons.route_outlined),
  MilestoneCategory.absenceFreeStreak:  CategoryMeta(label: 'Absence-Free Streak',             unit: 'consecutive days', icon: Icons.local_fire_department_outlined),
  MilestoneCategory.sitesCovered:       CategoryMeta(label: 'Sites Covered',                   unit: 'unique sites',     icon: Icons.location_on_outlined),
  MilestoneCategory.tqrsPassed:         CategoryMeta(label: 'TQRs Passed',                     unit: 'TQRs',             icon: Icons.verified_outlined),
  MilestoneCategory.vcrsCompleted:      CategoryMeta(label: 'VCRs Completed',                  unit: 'VCRs',             icon: Icons.directions_car_outlined),
  MilestoneCategory.acrsCompleted:      CategoryMeta(label: 'ACRs Completed',                  unit: 'ACRs',             icon: Icons.assignment_outlined),
  MilestoneCategory.estimatesWon:       CategoryMeta(label: 'Estimates Won',                   unit: 'estimates',        icon: Icons.trending_up_rounded),
  MilestoneCategory.earnings:           CategoryMeta(label: 'Earnings',                        unit: '£ cumulative',     icon: Icons.payments_outlined),
  MilestoneCategory.joining:            CategoryMeta(label: 'Joining the Team',                unit: 'one-off',          icon: Icons.emoji_events_outlined),
};

const List<MilestoneBadge> allMilestoneBadges = [
  // ── Time in the Business ──────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.timeInBusiness,      tier: BadgeTier.bronze,   badgeName: 'Rookie',            threshold: 1,      unit: 'months',           unlocked: true,  currentValue: 14),
  MilestoneBadge(category: MilestoneCategory.timeInBusiness,      tier: BadgeTier.silver,   badgeName: 'Established',       threshold: 6,      unit: 'months',           unlocked: true,  currentValue: 14),
  MilestoneBadge(category: MilestoneCategory.timeInBusiness,      tier: BadgeTier.gold,     badgeName: 'Veteran',           threshold: 12,     unit: 'months',           unlocked: true,  currentValue: 14),
  MilestoneBadge(category: MilestoneCategory.timeInBusiness,      tier: BadgeTier.platinum, badgeName: 'Stalwart',          threshold: 36,     unit: 'months',           unlocked: false, currentValue: 14),
  MilestoneBadge(category: MilestoneCategory.timeInBusiness,      tier: BadgeTier.diamond,  badgeName: 'Legend',            threshold: 60,     unit: 'months',           unlocked: false, currentValue: 14),
  // ── 5-Star Reviews ───────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.fiveStarReviews,     tier: BadgeTier.bronze,   badgeName: 'Crowd Pleaser',     threshold: 5,      unit: 'reviews',          unlocked: true,  currentValue: 38),
  MilestoneBadge(category: MilestoneCategory.fiveStarReviews,     tier: BadgeTier.silver,   badgeName: 'Fan Favourite',     threshold: 25,     unit: 'reviews',          unlocked: true,  currentValue: 38),
  MilestoneBadge(category: MilestoneCategory.fiveStarReviews,     tier: BadgeTier.gold,     badgeName: 'Customer Champion', threshold: 50,     unit: 'reviews',          unlocked: false, currentValue: 38),
  MilestoneBadge(category: MilestoneCategory.fiveStarReviews,     tier: BadgeTier.platinum, badgeName: 'Five-Star Force',   threshold: 100,    unit: 'reviews',          unlocked: false, currentValue: 38),
  MilestoneBadge(category: MilestoneCategory.fiveStarReviews,     tier: BadgeTier.diamond,  badgeName: 'Review Royalty',    threshold: 250,    unit: 'reviews',          unlocked: false, currentValue: 38),
  // ── Service Appointments ─────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.serviceAppointments, tier: BadgeTier.bronze,   badgeName: 'On the Board',      threshold: 20,     unit: 'SAs',              unlocked: true,  currentValue: 168),
  MilestoneBadge(category: MilestoneCategory.serviceAppointments, tier: BadgeTier.silver,   badgeName: 'Grafter',           threshold: 100,    unit: 'SAs',              unlocked: true,  currentValue: 168),
  MilestoneBadge(category: MilestoneCategory.serviceAppointments, tier: BadgeTier.gold,     badgeName: 'Workhorse',         threshold: 200,    unit: 'SAs',              unlocked: false, currentValue: 168),
  MilestoneBadge(category: MilestoneCategory.serviceAppointments, tier: BadgeTier.platinum, badgeName: 'Powerhouse',        threshold: 500,    unit: 'SAs',              unlocked: false, currentValue: 168),
  MilestoneBadge(category: MilestoneCategory.serviceAppointments, tier: BadgeTier.diamond,  badgeName: 'Unstoppable',       threshold: 1000,   unit: 'SAs',              unlocked: false, currentValue: 168),
  // ── Miles Driven ─────────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.milesDriven,         tier: BadgeTier.bronze,   badgeName: 'Road Starter',      threshold: 5000,   unit: 'miles',            unlocked: true,  currentValue: 22000),
  MilestoneBadge(category: MilestoneCategory.milesDriven,         tier: BadgeTier.silver,   badgeName: 'Road Warrior',      threshold: 15000,  unit: 'miles',            unlocked: true,  currentValue: 22000),
  MilestoneBadge(category: MilestoneCategory.milesDriven,         tier: BadgeTier.gold,     badgeName: 'Mile Muncher',      threshold: 30000,  unit: 'miles',            unlocked: false, currentValue: 22000),
  MilestoneBadge(category: MilestoneCategory.milesDriven,         tier: BadgeTier.platinum, badgeName: 'Long Hauler',       threshold: 60000,  unit: 'miles',            unlocked: false, currentValue: 22000),
  MilestoneBadge(category: MilestoneCategory.milesDriven,         tier: BadgeTier.diamond,  badgeName: 'Road King',         threshold: 100000, unit: 'miles',            unlocked: false, currentValue: 22000),
  // ── Absence-Free Streak ──────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.absenceFreeStreak,   tier: BadgeTier.bronze,   badgeName: 'Reliable',          threshold: 30,     unit: 'consecutive days', unlocked: true,  currentValue: 120),
  MilestoneBadge(category: MilestoneCategory.absenceFreeStreak,   tier: BadgeTier.silver,   badgeName: 'Ever-Present',      threshold: 90,     unit: 'consecutive days', unlocked: true,  currentValue: 120),
  MilestoneBadge(category: MilestoneCategory.absenceFreeStreak,   tier: BadgeTier.gold,     badgeName: 'Iron Will',         threshold: 180,    unit: 'consecutive days', unlocked: false, currentValue: 120),
  MilestoneBadge(category: MilestoneCategory.absenceFreeStreak,   tier: BadgeTier.platinum, badgeName: 'Cast Iron',         threshold: 365,    unit: 'consecutive days', unlocked: false, currentValue: 120),
  MilestoneBadge(category: MilestoneCategory.absenceFreeStreak,   tier: BadgeTier.diamond,  badgeName: 'Unbreakable',       threshold: 730,    unit: 'consecutive days', unlocked: false, currentValue: 120),
  // ── Sites Covered ────────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.sitesCovered,        tier: BadgeTier.bronze,   badgeName: 'Explorer',          threshold: 20,     unit: 'unique sites',     unlocked: true,  currentValue: 45),
  MilestoneBadge(category: MilestoneCategory.sitesCovered,        tier: BadgeTier.silver,   badgeName: 'Pathfinder',        threshold: 100,    unit: 'unique sites',     unlocked: false, currentValue: 45),
  MilestoneBadge(category: MilestoneCategory.sitesCovered,        tier: BadgeTier.gold,     badgeName: 'Map Maker',         threshold: 200,    unit: 'unique sites',     unlocked: false, currentValue: 45),
  MilestoneBadge(category: MilestoneCategory.sitesCovered,        tier: BadgeTier.platinum, badgeName: 'Territory Master',  threshold: 500,    unit: 'unique sites',     unlocked: false, currentValue: 45),
  MilestoneBadge(category: MilestoneCategory.sitesCovered,        tier: BadgeTier.diamond,  badgeName: 'Everywhere Man',    threshold: 1000,   unit: 'unique sites',     unlocked: false, currentValue: 45),
  // ── TQRs Passed ──────────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.tqrsPassed,          tier: BadgeTier.bronze,   badgeName: 'Quality Conscious', threshold: 5,      unit: 'TQRs',             unlocked: true,  currentValue: 12),
  MilestoneBadge(category: MilestoneCategory.tqrsPassed,          tier: BadgeTier.silver,   badgeName: 'Sharp Eye',         threshold: 15,     unit: 'TQRs',             unlocked: false, currentValue: 12),
  MilestoneBadge(category: MilestoneCategory.tqrsPassed,          tier: BadgeTier.gold,     badgeName: 'Quality Pro',       threshold: 30,     unit: 'TQRs',             unlocked: false, currentValue: 12),
  MilestoneBadge(category: MilestoneCategory.tqrsPassed,          tier: BadgeTier.platinum, badgeName: 'Standard Bearer',   threshold: 60,     unit: 'TQRs',             unlocked: false, currentValue: 12),
  MilestoneBadge(category: MilestoneCategory.tqrsPassed,          tier: BadgeTier.diamond,  badgeName: 'Quality Master',    threshold: 100,    unit: 'TQRs',             unlocked: false, currentValue: 12),
  // ── VCRs Completed ───────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.vcrsCompleted,       tier: BadgeTier.bronze,   badgeName: 'Checker',           threshold: 25,     unit: 'VCRs',             unlocked: true,  currentValue: 180),
  MilestoneBadge(category: MilestoneCategory.vcrsCompleted,       tier: BadgeTier.silver,   badgeName: 'Diligent',          threshold: 100,    unit: 'VCRs',             unlocked: true,  currentValue: 180),
  MilestoneBadge(category: MilestoneCategory.vcrsCompleted,       tier: BadgeTier.gold,     badgeName: 'Thorough',          threshold: 250,    unit: 'VCRs',             unlocked: false, currentValue: 180),
  MilestoneBadge(category: MilestoneCategory.vcrsCompleted,       tier: BadgeTier.platinum, badgeName: 'Meticulous',        threshold: 500,    unit: 'VCRs',             unlocked: false, currentValue: 180),
  MilestoneBadge(category: MilestoneCategory.vcrsCompleted,       tier: BadgeTier.diamond,  badgeName: 'VCR Master',        threshold: 1000,   unit: 'VCRs',             unlocked: false, currentValue: 180),
  // ── ACRs Completed ───────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.acrsCompleted,       tier: BadgeTier.bronze,   badgeName: 'Reporter',          threshold: 25,     unit: 'ACRs',             unlocked: true,  currentValue: 75),
  MilestoneBadge(category: MilestoneCategory.acrsCompleted,       tier: BadgeTier.silver,   badgeName: 'Documenter',        threshold: 100,    unit: 'ACRs',             unlocked: false, currentValue: 75),
  MilestoneBadge(category: MilestoneCategory.acrsCompleted,       tier: BadgeTier.gold,     badgeName: 'Records Keeper',    threshold: 250,    unit: 'ACRs',             unlocked: false, currentValue: 75),
  MilestoneBadge(category: MilestoneCategory.acrsCompleted,       tier: BadgeTier.platinum, badgeName: 'Detail Driven',     threshold: 500,    unit: 'ACRs',             unlocked: false, currentValue: 75),
  MilestoneBadge(category: MilestoneCategory.acrsCompleted,       tier: BadgeTier.diamond,  badgeName: 'ACR Master',        threshold: 1000,   unit: 'ACRs',             unlocked: false, currentValue: 75),
  // ── Estimates Won ────────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.estimatesWon,        tier: BadgeTier.bronze,   badgeName: 'Closer',            threshold: 10,     unit: 'estimates',        unlocked: true,  currentValue: 6),
  MilestoneBadge(category: MilestoneCategory.estimatesWon,        tier: BadgeTier.silver,   badgeName: 'Deal Maker',        threshold: 30,     unit: 'estimates',        unlocked: false, currentValue: 6),
  MilestoneBadge(category: MilestoneCategory.estimatesWon,        tier: BadgeTier.gold,     badgeName: 'Rainmaker',         threshold: 60,     unit: 'estimates',        unlocked: false, currentValue: 6),
  MilestoneBadge(category: MilestoneCategory.estimatesWon,        tier: BadgeTier.platinum, badgeName: 'Top Closer',        threshold: 120,    unit: 'estimates',        unlocked: false, currentValue: 6),
  MilestoneBadge(category: MilestoneCategory.estimatesWon,        tier: BadgeTier.diamond,  badgeName: 'Sales Machine',     threshold: 200,    unit: 'estimates',        unlocked: false, currentValue: 6),
  // ── Earnings ─────────────────────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.earnings,            tier: BadgeTier.bronze,   badgeName: 'Earner',            threshold: 5000,   unit: '£',                unlocked: true,  currentValue: 32000),
  MilestoneBadge(category: MilestoneCategory.earnings,            tier: BadgeTier.silver,   badgeName: 'High Earner',       threshold: 25000,  unit: '£',                unlocked: true,  currentValue: 32000),
  MilestoneBadge(category: MilestoneCategory.earnings,            tier: BadgeTier.gold,     badgeName: 'Top Earner',        threshold: 50000,  unit: '£',                unlocked: false, currentValue: 32000),
  MilestoneBadge(category: MilestoneCategory.earnings,            tier: BadgeTier.platinum, badgeName: 'Big Hitter',        threshold: 100000, unit: '£',                unlocked: false, currentValue: 32000),
  MilestoneBadge(category: MilestoneCategory.earnings,            tier: BadgeTier.diamond,  badgeName: 'Money Maker',       threshold: 250000, unit: '£',                unlocked: false, currentValue: 32000),
  // ── Joining the Team (one-off) ────────────────────────────────────
  MilestoneBadge(category: MilestoneCategory.joining,             tier: BadgeTier.oneOff,   badgeName: 'Welcome Aboard',    threshold: 1,      unit: 'one-off',          unlocked: true,  currentValue: 1),
];
