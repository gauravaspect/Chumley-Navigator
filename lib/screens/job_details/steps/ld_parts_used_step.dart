import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdPartsUsedStep extends StatelessWidget {
  const LdPartsUsedStep({
    super.key,
    required this.partsUsed,
    required this.parts,
    required this.onPartsUsedChanged,
    required this.onAddPart,
    required this.onPartCategoryChanged,
  });

  final String? partsUsed;
  final List<LdPartEntry> parts;
  final ValueChanged<String> onPartsUsedChanged;
  final VoidCallback onAddPart;
  final void Function(int index, String? category) onPartCategoryChanged;

  Widget _partFormCard({
    required BuildContext context,
    required int index,
    required LdPartEntry part,
  }) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PART ${index + 1}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              letterSpacing: 0.3,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 14.h),
          LdLabeled(
            'Category',
            LdDropdown(
              value: part.category.text.isEmpty ? null : part.category.text,
              items: const ['Consumable', 'Fitting', 'Pipe', 'Other'],
              onChanged: (v) => onPartCategoryChanged(index, v),
            ),
          ),
          SizedBox(height: 12.h),
          LdLabeled(
            'Description',
            LdTextField(
              controller: part.description,
              hint: 'Part description…',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: LdLabeled(
                  'Part ref',
                  LdTextField(controller: part.ref, hint: 'Reference…'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: LdLabeled(
                  'Qty',
                  LdTextField(controller: part.qty, hint: 'Qty'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final accent = theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.wrench,
          title: 'Parts used',
          subtitle: 'Only if anything was consumed on site.',
          children: [
            LdChipGroup(
              label: 'Have any parts been used during your visit?',
              options: const ['No', 'Yes'],
              value: partsUsed,
              onChanged: onPartsUsedChanged,
            ),
          ],
        ),
        if (partsUsed == 'Yes') ...[
          for (var i = 0; i < parts.length; i++) ...[
            SizedBox(height: 16.h),
            _partFormCard(context: context, index: i, part: parts[i]),
          ],
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: theme.border, width: 0.5),
            ),
            child: InkWell(
              onTap: onAddPart,
              borderRadius: BorderRadius.circular(12.r),
              child: VcrDashedBorder(
                color: theme.isDark ? theme.border : const Color(0xFFC9DCF7),
                borderRadius: 12.r,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.surfaceDeep,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.plus, size: 16.sp, color: accent),
                      SizedBox(width: 8.w),
                      Text(
                        'Add part',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
