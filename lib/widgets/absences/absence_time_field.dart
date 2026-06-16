import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.dashPrimary,
              borderRadius: BorderRadius.circular(12.r),
              border: hasError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.dashCardBg,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: theme.dashSurfaceTint,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.dashTitle,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
