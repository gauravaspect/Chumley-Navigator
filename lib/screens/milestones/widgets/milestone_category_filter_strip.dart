import 'package:chumley_navigator/data/milestone_definitions.dart';
import 'package:chumley_navigator/models/milestone_badge.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneCategoryFilterStrip extends StatelessWidget {
  final ValueNotifier<MilestoneCategory?> selected;
  final DashboardTheme theme;

  const MilestoneCategoryFilterStrip({
    super.key,
    required this.selected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ValueListenableBuilder<MilestoneCategory?>(
        valueListenable: selected,
        builder: (context, selectedCat, _) {
          return Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: selectedCat == null,
                onTap: () => selected.value = null,
                theme: theme,
              ),
              ...MilestoneCategory.values.map((cat) {
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: _FilterChip(
                    label: categoryMeta[cat]!.label,
                    isSelected: selectedCat == cat,
                    onTap: () => selected.value = cat,
                    theme: theme,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final DashboardTheme theme;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (theme.isDark ? AppColors.kpiBarHigh : theme.accent)
        : theme.surface;
    final textColor = isSelected ? Colors.white : theme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(17.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
