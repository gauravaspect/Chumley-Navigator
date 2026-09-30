import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitStepPills extends StatelessWidget {
  const VisitStepPills({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    this.onStepTapped,
  });

  final int stepIndex;
  final int stepCount;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Row(
      children: List.generate(stepCount, (i) {
        final active = i == stepIndex;
        final done = i < stepIndex;
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onStepTapped != null ? () => onStepTapped!(i) : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4.h,
                decoration: BoxDecoration(
                  color: active || done
                      ? (theme.isDark ? AppColors.accentBlue : NavigatorTokens.brandNavy)
                      : (theme.isDark ? theme.border : NavigatorTokens.brandNavyTint),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class VisitFormCaption extends StatelessWidget {
  const VisitFormCaption({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: theme.textMuted,
          height: 1.35,
        ),
      ),
    );
  }
}

class VisitFieldLabel extends StatelessWidget {
  const VisitFieldLabel({
    super.key,
    required this.label,
    this.requiredField = false,
  });

  final String label;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        requiredField ? '$label *' : label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: theme.text,
        ),
      ),
    );
  }
}

class VisitFormCard extends StatelessWidget {
  const VisitFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: NavigatorTokens.cardRadius,
        border: Border.all(color: theme.border, width: 0.5),
        boxShadow: theme.isDark ? null : NavigatorTokens.cardShadows,
      ),
      child: child,
    );
  }
}

class VisitChoiceChips extends StatelessWidget {
  const VisitChoiceChips({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisitFieldLabel(label: label),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: options.map((option) {
              final selected = value == option;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? () => onSelected(option) : null,
                  borderRadius: NavigatorTokens.fieldRadius,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? (theme.isDark ? AppColors.accentBlue : NavigatorTokens.brandNavy)
                          : theme.surfaceDeep,
                      borderRadius: NavigatorTokens.fieldRadius,
                      border: Border.all(
                        color: selected
                            ? (theme.isDark ? AppColors.accentBlue : NavigatorTokens.brandNavy)
                            : theme.border,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : theme.text,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class VisitTextField extends StatelessWidget {
  const VisitTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisitFieldLabel(label: label),
          TextFormField(
            key: ValueKey('$label-$value'),
            initialValue: value,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.textMuted,
              ),
              filled: true,
              fillColor: theme.surfaceDeep,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(
                  color: theme.isDark ? AppColors.accentBlue : NavigatorTokens.brandNavy,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class VisitInfoBanner extends StatelessWidget {
  const VisitInfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.surfaceDeep : NavigatorTokens.infoBg,
        borderRadius: NavigatorTokens.fieldRadius,
        border: Border.all(
          color: theme.isDark ? theme.border : NavigatorTokens.brandNavyTint,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          height: 1.4,
          color: theme.isDark ? theme.text : NavigatorTokens.brandNavy,
        ),
      ),
    );
  }
}
