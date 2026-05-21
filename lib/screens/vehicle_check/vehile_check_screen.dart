import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/primary_cta_button.dart';
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
    'Each photograph must strictly adhere to the provided reference examples. Images that are captured from incorrect angles or do not comply with the specified guidelines may be flagged as invalid by the system.',
    'Kindly verify that all photographs are clear, properly aligned, and meet the outlined requirements prior to submission.',
    'Please make sure you have selected the current vehicle from the drop down menu before continuing.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectBranding(),
              SizedBox(height: 16.h),
              const FadeSlideIn(child: VcrPageHeader()),
              SizedBox(height: 16.h),
              const FadeSlideIn(
                delay: Duration(milliseconds: 50),
                child: VcrWarningBanner(message: _noVehiclesMessage),
              ),
              SizedBox(height: 16.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: VcrFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1 Instructions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Read Before Starting The Vehicle Check',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkBlue,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      for (var i = 0; i < _instructions.length; i++) ...[
                        Text(
                          _instructions[i],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            color: AppColors.textBodyMuted,
                          ),
                        ),
                        if (i < _instructions.length - 1) SizedBox(height: 12.h),
                      ],
                      SizedBox(height: 20.h),
                      PrimaryCtaButton(
                        label: 'Continue to vehicle details',
                        borderRadius: 8.r,
                        height: 44.h,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.vehicleForm),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
