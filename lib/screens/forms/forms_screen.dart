import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/screens/forms/form_details.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  void _openForm(BuildContext context, FormType type) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InspectionReportPage(formType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AspectBranding(),
                  SizedBox(height: 14.h),
                  Text(
                    'Forms',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Select a work type to start a new form',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  FadeSlideIn(
                    child: _FormListTile(
                      icon: LucideIcons.zap,
                      title: 'EICR',
                      subtitle:
                          'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
                      onTap: () => _openForm(context, FormType.eicr),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 50),
                    child: _FormListTile(
                      icon: LucideIcons.droplets,
                      title: 'Damp & Moisture Survey',
                      subtitle: 'Surface / depth readings · BS 5250:2021',
                      onTap: () => _openForm(context, FormType.dampSurvey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormListTile extends StatelessWidget {
  const _FormListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              child: Icon(
                icon,
                color: theme.isDark
                    ? AppColors.kpiBarHigh
                    : AppColors.brandRed,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.textMuted,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
