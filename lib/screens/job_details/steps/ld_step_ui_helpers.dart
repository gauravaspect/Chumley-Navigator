import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Prototype palette constants for LD on-site form
const Color ldBgTop = Color(0xFFF4F9FF);
const Color ldBgMid = Color(0xFFEDF4FE);
const Color ldBgBottom = Color(0xFFE2ECFA);
const Color ldTextPrimary = Color(0xFF0B1F3A);
const Color ldTextSecondary = Color(0xFF5A6B85);
const Color ldTextCaption = Color(0xFF0B1F3A);
const Color ldFieldFill = Color(0xFFE9EDF5);
const Color ldFieldBorder = Color(0xFFE2E7F0);
const Color ldDotInactive = Color(0xFFD8E6FC);
const Color ldBadgeFill = Color(0xFFD8E6FC);
const Color ldYellowCta = Color(0xFFFFF23D);
const Color ldGreenCheck = Color(0xFF15803D);
const Color ldBackCircle = Color(0xFFE9EDF5);

class LdPartEntry {
  LdPartEntry({
    String category = '',
    String description = '',
    String ref = '',
    String qty = '',
  }) : category = TextEditingController(text: category),
       description = TextEditingController(text: description),
       ref = TextEditingController(text: ref),
       qty = TextEditingController(text: qty);

  final TextEditingController category;
  final TextEditingController description;
  final TextEditingController ref;
  final TextEditingController qty;

  void dispose() {
    category.dispose();
    description.dispose();
    ref.dispose();
    qty.dispose();
  }
}

class LdSectionCard extends StatelessWidget {
  const LdSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.isRequired = false,
  });

  final String title;
  final List<Widget> children;
  final String? subtitle;
  final IconData? icon;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: theme.surfaceDeep,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 23 / 17,
                              color: theme.text,
                            ),
                          ),
                        ),
                        if (isRequired) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.fromLTRB(10.w, 5.h, 12.w, 5.h),
                            decoration: BoxDecoration(
                              color: theme.isDark
                                  ? const Color(0xFF3D2A14)
                                  : const Color(0xFFFEF6E7),
                              borderRadius: BorderRadius.circular(500.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.isDark
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Required',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: theme.isDark
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          height: 15 / 11,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }
}

class LdLabeled extends StatelessWidget {
  const LdLabeled(this.label, this.child, {super.key, this.icon});

  final String label;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 12.sp,
                  color: theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 16 / 12,
                  color: theme.textMuted,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }
}

class LdHint extends StatelessWidget {
  const LdHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 17 / 12,
        color: theme.textMuted,
      ),
    );
  }
}

class LdInfoBanner extends StatelessWidget {
  const LdInfoBanner(this.text, this.bgColor, {super.key});

  final String text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.surfaceDeep : bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: theme.isDark ? Border.all(color: theme.border, width: 0.5) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.isDark ? AppColors.accentBlue : ldTextPrimary,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 19 / 13,
                color: theme.isDark ? theme.text : ldTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LdDeclarationTile extends StatelessWidget {
  const LdDeclarationTile({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.text,
  });

  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              margin: EdgeInsets.only(top: 1.h),
              decoration: BoxDecoration(
                color: checked ? ldGreenCheck : theme.surfaceDeep,
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(
                  color: checked ? ldGreenCheck : theme.border,
                ),
              ),
              child: checked
                  ? Icon(LucideIcons.check, size: 13.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  height: 19 / 13,
                  color: theme.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LdChipGroup extends StatelessWidget {
  const LdChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 16 / 12,
                  color: theme.textMuted,
                ),
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.textMuted,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        ...options.asMap().entries.map((entry) {
          final i = entry.key;
          final opt = entry.value;
          final selected = opt == value;
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8.h),
            child: Material(
              color: selected ? AppColors.primaryBlue : theme.surfaceDeep,
              borderRadius: BorderRadius.circular(500.r),
              child: InkWell(
                onTap: () => onChanged(opt),
                borderRadius: BorderRadius.circular(500.r),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 40.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500.r),
                    border: selected
                        ? null
                        : Border.all(color: theme.border, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selected) ...[
                        Icon(
                          LucideIcons.check,
                          size: 15.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Flexible(
                        child: Text(
                          opt,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w500
                                : FontWeight.w400,
                            height: 19 / 13,
                            color: selected ? Colors.white : theme.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class LdDropdown extends StatelessWidget {
  const LdDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  Future<void> _openDropdownSheet(BuildContext context) async {
    final theme = DashboardTheme.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.border,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 16.h),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: theme.border),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == value;
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(item),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        title: Text(
                          item,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 21 / 14,
                            color: isSelected
                                ? (theme.isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primaryBlue)
                                : theme.dashTitle,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.check,
                                size: 18.sp,
                                color: theme.isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final display = (value != null && items.contains(value)) ? value : null;

    return Material(
      color: theme.surfaceDeep,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => _openDropdownSheet(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 13.h, 10.w, 13.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  display ?? 'Select…',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 21 / 14,
                    color: display == null ? theme.textMuted : theme.text,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.textMuted,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LdTextField extends StatelessWidget {
  const LdTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onToggleDictation,
    this.isListening = false,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final VoidCallback? onToggleDictation;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isMulti = maxLines > 1;
    final field = TextField(
      controller: controller,
      maxLines: isMulti ? null : 1,
      minLines: isMulti ? 3 : 1,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        color: theme.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: theme.textMuted),
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.fromLTRB(
          14.w,
          isMulti ? 12.h : 13.h,
          isMulti ? 48.w : 14.w,
          isMulti ? 12.h : 13.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
        ),
      ),
    );

    if (!isMulti) return field;

    return SizedBox(
      height: 96.h,
      child: Stack(
        children: [
          Positioned.fill(child: field),
          if (onToggleDictation != null)
            Positioned(
              right: 6.w,
              bottom: 25.h,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleDictation,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: isListening
                          ? AppColors.primaryBlue.withValues(alpha: 0.12)
                          : theme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isListening
                            ? AppColors.primaryBlue
                            : theme.border,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isListening ? LucideIcons.micOff : LucideIcons.mic,
                      size: 18.sp,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
