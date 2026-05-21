import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/profile/profile_info_row.dart';
import 'package:chumley_navigator/widgets/profile/profile_stat_grid_card.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/ui/outlined_cta_button.dart';
import 'package:chumley_navigator/widgets/ui/soft_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _GridItem {
  const _GridItem({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _gridData = [
    _GridItem(icon: LucideIcons.star, title: 'Engineer Satisfaction', body: '4.4'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Skills', body: '14'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Sites Covered', body: '38'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Qualified Wts', body: '9'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Manager', body: 'Sarah Johnson'),
    _GridItem(
      icon: LucideIcons.lightbulb,
      title: 'Years of Experience',
      body: '8 Years, 4 months',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SoftIconButton(
                    alignment: Alignment.topLeft,
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 16.sp,
                    size: 34.r,
                    onTap: () =>
                        Navigator.popAndPushNamed(context, AppRoutes.home),
                  ),
                ),
                const AspectBranding(),
                SizedBox(height: 20.h),
                FadeSlideIn(
                  child: Text(
                    'User Profile',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.35,
                      color: AppColors.textDarkBlue,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 50),
                  child: _ProfileAvatar(),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Test User',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                ProfileInfoRow(label: 'Trade', value: 'Electrician'),
                ProfileInfoRow(label: 'Van Number', value: 'WX23 ELT'),
                SizedBox(height: 4.h),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 1.08,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gridData.length,
                  itemBuilder: (context, index) {
                    final data = _gridData[index];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 40 * index),
                      offsetY: 8,
                      child: ProfileStatGridCard(
                        icon: data.icon,
                        title: data.title,
                        body: data.body,
                      ),
                    );
                  },
                ),
                _AddressTile(),
                SizedBox(height: 4.h),
                OutlinedCtaButton(
                  label: 'Log Out',
                  icon: Icons.logout_rounded,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110.w,
      height: 110.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: ElevatedSurface.softShadows(elevation: 0.9),
            ),
            alignment: Alignment.center,
            child: Text(
              'GP',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          Positioned(
            right: 4.w,
            top: 2.w,
            child: PressableScale(
              onTap: () {},
              scale: 0.9,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: ElevatedSurface.tintedFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderLightBlue.withValues(alpha: 0.5),
                  ),
                  boxShadow: ElevatedSurface.softShadows(elevation: 0.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textDarkBlue,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      scale: 0.99,
      child: ElevatedSurface(
        padding: EdgeInsets.all(14.r),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        borderRadius: 18.r,
        borderColor: AppColors.textDarkBlue.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.highlightYellow.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.textDarkBlue.withValues(alpha: 0.15),
                  width: 0.75,
                ),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.textDarkBlue,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                '14 Maple Close, Cheshunt, EN8 9QR',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: AppColors.textDarkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
