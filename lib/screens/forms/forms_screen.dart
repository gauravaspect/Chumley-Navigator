import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/screens/forms/form_details.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/ui/screen_title_block.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AspectBranding(),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  child: ScreenTitleBlock(
                    title: 'Forms',
                    subtitle: 'Select a work type to start a new form',
                    titleSize: 24.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 50),
                  child: _FormListTile(
                    icon: LucideIcons.zap,
                    title: 'EICR',
                    subtitle:
                        'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
                    onTap: () => _openForm(context, FormType.eicr),
                  ),
                ),
                SizedBox(height: 12.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: _FormListTile(
                    icon: LucideIcons.droplets,
                    title: 'Damp & Moisture Survey',
                    subtitle: 'Surface / depth readings · BS 5250:2021',
                    onTap: () => _openForm(context, FormType.dampSurvey),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
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
    return PressableScale(
      onTap: onTap,
      scale: 0.985,
      child: ElevatedSurface(
        backgroundColor: AppColors.white,
        borderColor: AppColors.borderLightBlue,
        borderRadius: 18.r,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceBlueTint,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 26.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textDarkBlue,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textBodyMuted,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.borderLightBlue,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
