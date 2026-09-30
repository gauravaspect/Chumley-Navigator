import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen displayed after a successful Vehicle Check Report submission.
class VcrSubmittedScreen extends StatelessWidget {
  final DashboardTheme theme;
  final String referenceId;
  final int photoCount;
  final int areaCount;
  final VoidCallback onBackHome;

  const VcrSubmittedScreen({
    super.key,
    required this.theme,
    required this.referenceId,
    required this.photoCount,
    required this.areaCount,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.base,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF4F9FF),
                    Color(0xFFEDF4FE),
                    Color(0xFFE2ECFA),
                  ],
                  stops: [0, 0.55, 1],
                ),
          color: theme.isDark ? theme.base : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBackHome,
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: theme.dashHeading,
                        size: 22.sp,
                      ),
                    ),
                    Text(
                      'Vehicle report',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashHeading,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(22.r),
                      decoration: BoxDecoration(
                        color: theme.dashPrimary,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 76.w,
                            height: 76.w,
                            decoration: const BoxDecoration(
                              color: AppColors.accentLime,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              LucideIcons.check,
                              size: 36.sp,
                              color: const Color(0xFF0B1F3A),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Van check submitted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'All $areaCount areas checked and $photoCount photos captured.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Divider(color: Colors.white.withValues(alpha: 0.2)),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your reference',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      referenceId,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: referenceId),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('Reference copied'),
                                      ),
                                    );
                                },
                                child: Icon(
                                  LucideIcons.copy,
                                  size: 18.sp,
                                  color: AppColors.accentLime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    VcrFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.dashHeading,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          const _NextStepRow(
                            index: 1,
                            text: 'The fleet team reviews your check',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepRow(
                            index: 2,
                            text:
                                'Any defect raised is booked in with the workshop',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepRow(
                            index: 3,
                            text: 'A copy lands in your notifications',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: PressableScale(
                  onTap: onBackHome,
                  child: Container(
                    width: double.infinity,
                    height: 44.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentLime,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      'Back to home',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepRow extends StatelessWidget {
  const _NextStepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: theme.isDark
                ? theme.dashSurfaceTint
                : const Color(0xFFD8E6FC),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashPrimary,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.dashHeading,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
