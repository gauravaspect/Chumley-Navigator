import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AbsenceTimeField extends StatelessWidget {
  const AbsenceTimeField({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
    this.enabled = true,
    this.hasError = false,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final bool enabled;
  final bool hasError;

  String get _display {
    if (time == null) return '--:--';
    final hour = time!.hour.toString().padLeft(2, '0');
    final minute = time!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final fill =
        theme.isDark ? theme.dashSurfaceTint : const Color(0xFFE9EDF5);
    final hairline =
        theme.isDark ? theme.dashBorderLight : const Color(0xFFE2E7F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: theme.dashSubtitle,
          ),
        ),
        SizedBox(height: 7.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12.r),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: enabled ? 1 : 0.5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasError ? Colors.red : hairline,
                    width: hasError ? 1.25 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _display,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.dashHeading,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.clock,
                      size: 17.sp,
                      color: const Color(0xFF8A99B0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
