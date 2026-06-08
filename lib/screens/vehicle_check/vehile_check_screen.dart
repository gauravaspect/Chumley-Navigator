import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_page_header.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_warning_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehileCheckScreen extends StatelessWidget {
  const VehileCheckScreen({super.key});

  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  static const _instructions = [
    'Please ensure that all 21 required photographs are uploaded in full. Failure to provide any of the required images will prevent progression to the next stage.',
    'Each photograph must strictly adhere to the provided reference examples. Images that are captured from incorrect angles and do not comply with the specified guidelines may be flagged as invalid by the system.',
    'Kindly verify that all photographs are clear, properly aligned, and meet the outlined requirements prior to submission.',
    'Please make sure you have selected the current vehicle from the drop down menu before continuing.',
  ];

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
                    'Vehicle check',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const FadeSlideIn(child: VcrPageHeader()),
                  SizedBox(height: 12.h),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 50),
                    child: VcrWarningBanner(message: _noVehiclesMessage),
                  ),
                  SizedBox(height: 12.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: VcrFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 1 INSTRUCTIONS',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: theme.textMuted,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Read before starting the vehicle check',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.text,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          for (var i = 0; i < _instructions.length; i++) ...[
                            Text(
                              _instructions[i],
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: theme.textMuted,
                              ),
                            ),
                            if (i < _instructions.length - 1)
                              SizedBox(height: 10.h),
                          ],
                          SizedBox(height: 14.h),
                          _ContinueButton(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.vehicleForm,
                            ),
                          ),
                        ],
                      ),
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Continue to vehicle details',
      button: true,
      child: PressableScale(
        onTap: onTap,
        scale: 0.98,
        child: Container(
          width: double.infinity,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Continue to vehicle details',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
