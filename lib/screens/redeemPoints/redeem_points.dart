import 'package:chumley_navigator/components/redeem_points/redeem_cards.dart';
import 'package:chumley_navigator/components/redeem_points/redeem_points_bottom_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RedeemPointsScreen extends StatelessWidget {
  const RedeemPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your rewards journey',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.text,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Earn points, unlock rewards',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderIconButton(
                        theme: theme,
                        icon: LucideIcons.clipboard_list,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.90,
                              child: const RedeemPointsBottomModal(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 6.w),
                      _HeaderIconButton(
                        theme: theme,
                        icon: Icons.close,
                        onTap: () =>
                            Navigator.popAndPushNamed(context, AppRoutes.home),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AvailablePointsCard(theme: theme),
                        SizedBox(height: 10.h),
                        _RedeemCta(theme: theme),
                        const RewardsJourneyList(),
                        _ClaimedRewards(theme: theme),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.theme,
    required this.icon,
    required this.onTap,
  });

  final DashboardTheme theme;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: theme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16.sp, color: theme.textMuted),
      ),
    );
  }
}

class _AvailablePointsCard extends StatelessWidget {
  const _AvailablePointsCard({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.h, bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryBlueDark,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE POINTS',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              fontSize: 10.sp,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                child: Text(
                  'pts',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.kpiBarHigh,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueDark,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.textDarkBlue, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 11.sp,
                  color: AppColors.kpiBarHigh,
                ),
                SizedBox(width: 4.w),
                Text(
                  '+220 this week',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.kpiBarHigh,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemCta extends StatelessWidget {
  const _RedeemCta({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      scale: 0.98,
      child: Container(
        width: double.infinity,
        height: 40.h,
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 16.sp, color: AppColors.white),
            SizedBox(width: 6.w),
            Text(
              'Redeem points',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedRewards extends StatelessWidget {
  const _ClaimedRewards({required this.theme});

  final DashboardTheme theme;

  static final _data = [
    (
      image: 'assets/brands/tesco.png',
      reward: 'Tesco',
      amount: '£10',
      pts: '1,000',
      redeemDate: '12 Apr 2026',
      backgroundColor: AppColors.giftCardNhsBg,
    ),
    (
      image: 'assets/brands/costa.png',
      reward: 'Costa Coffee',
      amount: '£5',
      pts: '500',
      redeemDate: '02 Mar 2026',
      backgroundColor: AppColors.giftCardTargetBg,
    ),
    (
      image: 'assets/brands/amazon.png',
      reward: 'Amazon.co.uk',
      amount: '£15',
      pts: '1,500',
      redeemDate: '18 Feb 2026',
      backgroundColor: AppColors.giftCardAmazonBg,
    ),
    (
      image: 'assets/brands/sainsburys.png',
      reward: "Sainsbury's",
      amount: '£20',
      pts: '2,000',
      redeemDate: '05 Jan 2026',
      backgroundColor: AppColors.giftCardSainsburysBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          'CLAIMED REWARDS',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
            letterSpacing: 0.4,
            color: theme.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              thickness: 0.5,
              color: theme.border,
            ),
            itemBuilder: (_, index) {
              final item = _data[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    _BrandCard(
                      imagePath: item.image,
                      amount: item.amount,
                      backgroundColor: item.backgroundColor,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.reward} ${item.amount}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.text,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Redeemed · ${item.redeemDate}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '−${item.pts} pts',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.imagePath,
    required this.amount,
    required this.backgroundColor,
  });

  final String imagePath;
  final String amount;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 48.h,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            imagePath,
            height: 14.h,
            fit: BoxFit.contain,
            color: AppColors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
