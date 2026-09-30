import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneSummaryBar extends StatefulWidget {
  final List<MilestoneBadge> badges;
  final DashboardTheme theme;

  const MilestoneSummaryBar({
    super.key,
    required this.badges,
    required this.theme,
  });

  @override
  State<MilestoneSummaryBar> createState() => _MilestoneSummaryBarState();
}

class _MilestoneSummaryBarState extends State<MilestoneSummaryBar> {
  final List<ValueNotifier<double>> _pulses = [
    ValueNotifier(0.0),
    ValueNotifier(0.0),
    ValueNotifier(0.0),
  ];

  int _prevUnlockedCount = 0;
  int _prevActiveCategoriesCount = 0;

  @override
  void initState() {
    super.initState();
    _prevUnlockedCount = widget.badges.where((b) => b.unlocked).length;
    final Set<MilestoneCategory> activeCategories = {};
    for (final b in widget.badges) {
      if (b.unlocked) activeCategories.add(b.category);
    }
    _prevActiveCategoriesCount = activeCategories.length;
  }

  @override
  void didUpdateWidget(covariant MilestoneSummaryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    int unlockedCount = 0;
    final Set<MilestoneCategory> activeCategories = {};
    for (final b in widget.badges) {
      if (b.unlocked) {
        unlockedCount++;
        activeCategories.add(b.category);
      }
    }
    if (unlockedCount > _prevUnlockedCount) {
      _triggerPulse(0);
      _prevUnlockedCount = unlockedCount;
    }
    if (activeCategories.length > _prevActiveCategoriesCount) {
      _triggerPulse(1);
      _prevActiveCategoriesCount = activeCategories.length;
    }
  }

  void _triggerPulse(int index) {
    _pulses[index].value = 1.0;
  }

  @override
  void dispose() {
    for (final p in _pulses) {
      p.dispose();
    }
    super.dispose();
  }

  Widget _buildChip(int index, String label, String value, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _triggerPulse(index),
        child: ValueListenableBuilder<double>(
          valueListenable: _pulses[index],
          builder: (context, pulseVal, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: pulseVal),
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                if (pulseVal == 1.0) {
                  _pulses[index].value = 0.0;
                }
              },
              builder: (context, opacity, child) {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: widget.theme.text, size: 18.sp),
                          SizedBox(height: 4.h),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.text,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: widget.theme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              gradient: RadialGradient(
                                center: Alignment.topCenter,
                                radius: 1.0,
                                colors: [
                                  AppColors.kpiBarHigh.withValues(alpha: 0.4),
                                  AppColors.kpiBarHigh.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int unlockedCount = 0;
    final Set<MilestoneCategory> activeCategories = {};
    for (final badge in widget.badges) {
      if (badge.unlocked) {
        unlockedCount++;
        activeCategories.add(badge.category);
      }
    }

    return Row(
      children: [
        _buildChip(
          0,
          'Badges Earned',
          unlockedCount.toString(),
          Icons.emoji_events_outlined,
        ),
        SizedBox(width: 8.w),
        _buildChip(
          1,
          'Categories Active',
          activeCategories.length.toString(),
          Icons.category_outlined,
        ),
        SizedBox(width: 8.w),
        _buildChip(2, 'Day Streak', '14', Icons.local_fire_department_outlined),
      ],
    );
  }
}
