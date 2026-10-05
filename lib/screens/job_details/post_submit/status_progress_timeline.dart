import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared status timeline: Dispatched → Received → In Transit → On site → Job Closure → Visit Complete.
class StatusProgressTimeline extends StatelessWidget {
  const StatusProgressTimeline({super.key, this.completed = false});

  final bool completed;

  static const _labels = SaStatus.progressLabels;
  static const _textSecondary = Color(0xFF5A6B85);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final progressIdx = completed ? _labels.length - 1 : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final colWidth = totalWidth / _labels.length;
        final lineStart = colWidth / 2;
        final lineLength = totalWidth - colWidth;
        final activeFraction = progressIdx / (_labels.length - 1);
        final activeLength = lineLength * activeFraction;

        return Column(
          children: [
            SizedBox(
              height: 20.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: lineStart,
                    width: lineLength,
                    top: 9.h,
                    height: 2.h,
                    child: Container(
                      color: AppColors.primaryBlue.withValues(
                        alpha: theme.isDark ? 0.35 : 0.2,
                      ),
                    ),
                  ),
                  Positioned(
                    left: lineStart,
                    width: activeLength,
                    top: 9.h,
                    height: 2.h,
                    child: Container(color: AppColors.primaryBlue),
                  ),
                  Row(
                    children: List.generate(_labels.length, (i) {
                      final isDone = completed || i < progressIdx;
                      final isCurrent = !completed && i == progressIdx;
                      final size = isDone
                          ? 16.w
                          : isCurrent
                          ? 12.w
                          : 8.w;
                      return Expanded(
                        child: Center(
                          child: Container(
                            width: size,
                            height: size,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (isDone || isCurrent)
                                  ? AppColors.primaryBlue
                                  : AppColors.primaryBlue.withValues(
                                      alpha: theme.isDark ? 0.35 : 0.25,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: isDone
                                ? Icon(
                                    LucideIcons.check,
                                    size: 10.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: List.generate(_labels.length, (i) {
                final isDone = completed || i <= progressIdx;
                return Expanded(
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.sp,
                      height: 1.15,
                      fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                      color: isDone
                          ? (theme.isDark ? theme.text : _textSecondary)
                          : theme.textMuted,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
