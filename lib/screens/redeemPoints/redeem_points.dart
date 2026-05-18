import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../components/redeem_points/redeem_cards.dart';
import '../../components/redeem_points/redeem_points_bottom_model.dart';
import '../../utils/routes.dart';

class RedeemPointsScreen extends StatelessWidget {
  const RedeemPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlue,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Rewards Journey",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlueDark,
              ),
            ),
            Text(
              "Earn points, unlock rewards",
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          _customIconButton(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.90,
                child: const RedeemPointsBottomModal(),
              ),
            );
          }, LucideIcons.clipboard_list),
          _customIconButton(() {
            Navigator.popAndPushNamed(context, AppRoutes.home);
          }, Icons.close),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 18.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _availablePoints(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 20.sp,
                          color: AppColors.highlightYellow,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Redeem Points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: AppColors.highlightYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                RewardsJourneyList(),
                _claimedRewards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customIconButton(Function() onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10.r),
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(width: 0.25, color: AppColors.textSecondary),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _availablePoints() {
    return Container(
      width: double.infinity,
      height: 200.h,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 20.h,
        bottom: 24.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18.r)),
        color: AppColors.primaryBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "AVAILABLE POINTS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white.withValues(alpha: 0.65),
              fontSize: 14.sp,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "0",
                  style: TextStyle(
                    fontSize: 76.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                WidgetSpan(child: SizedBox(width: 4.w)),
                TextSpan(
                  text: 'pts',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentLime,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.accentLime.withOpacity(0.15),
              border: Border.all(
                color: AppColors.accentLime.withOpacity(0.4),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 11.sp,
                  color: AppColors.accentLime,
                ),
                SizedBox(width: 4.w),
                Text(
                  '+220 this week',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentLime,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimedRewards() {
    final data = [
      {
        "image": "assets/brands/tesco.png",
        "reward": "Tesco",
        "amount": "£10",
        "pts": "1,000",
        "redeem_date": "12 Apr 2026",
        "background_color": "0xFF005EB8",
      },
      {
        "image": "assets/brands/costa.png",
        "reward": "Costa Coffee",
        "amount": "£5",
        "pts": "500",
        "redeem_date": "02 Mar 2026",
        "background_color": "0xFF6E1F2A",
      },
      {
        "image": "assets/brands/amazon.png",
        "reward": "Amazon.co.uk",
        "amount": "£15",
        "pts": "1,500",
        "redeem_date": "18 Feb 2026",
        "background_color": "0xFF232F3E",
      },
      {
        "image": "assets/brands/sainsburys.png",
        "reward": "Sainsbury\'s",
        "amount": "£20",
        "pts": "2,000",
        "redeem_date": "05 Jan 2026",
        "background_color": "0xFFF06C00",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Claimed Rewards",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textDarkBlue,
          ),
        ),

        SizedBox(height: 10.h),

        // ── Card container ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderDefault, width: 0.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              thickness: 0.5,
              color: AppColors.borderDefault,
            ),
            itemBuilder: (_, index) {
              final item = data[index];
              final bgColor = Color(int.parse(item["background_color"]!));

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Row(
                  children: [
                    // ── Brand card ─────────────────────────────────
                    _brandCard(
                      imagePath: item["image"]!,
                      amount: item["amount"]!,
                      backgroundColor: bgColor,
                    ),

                    SizedBox(width: 12.w),

                    // ── Title + date ───────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item["reward"]} ${item["amount"]}',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkBlue,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Redeemed · ${item["redeem_date"]}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.normal,
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // ── Points ─────────────────────────────────────
                    Text(
                      '−${item["pts"]} pts',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBodyMuted,
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

  Widget _brandCard({
    required String imagePath,
    required String amount,
    required Color backgroundColor,
  }) {
    return Container(
      width: 88.w,
      height: 56.h,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDarkBlue.withOpacity(0.18),
            offset: Offset(0, 2.h),
            blurRadius: 6.r,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            offset: Offset(0, 1.h),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ── Gradient shimmer overlay ──────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.10),
                  ],
                  stops: const [0.0, 0.45, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // ── Logo + amount ─────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand logo — white-filtered via colorBlendMode
              Image.asset(
                imagePath,
                height: 16.h,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
