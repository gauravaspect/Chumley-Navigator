import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/colors.dart';
import '../../utils/routes.dart';

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
    _GridItem(
      icon: LucideIcons.star,
      title: 'Engineer Satisfaction',
      body: '4.4',
    ),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Skills', body: '14'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Sites Covered', body: '38'),
    _GridItem(icon: LucideIcons.lightbulb, title: 'Qualified Wts', body: '9'),
    _GridItem(
      icon: LucideIcons.lightbulb,
      title: 'Manager',
      body: 'Sarah Johnson',
    ),
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, AppRoutes.home);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textDarkBlue,
                      fontWeight: FontWeight.bold,
                      size: 14.sp,
                    ),
                  ),
                ),
                AspectBranding(),
                SizedBox(height: 20.h),
                Text(
                  "User Profile",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
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
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "GP",
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6.w,
                        top: 4.w,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              color: AppColors.chartFillBlue,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.edit,
                              color: AppColors.textDarkBlue,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Test User",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                _tradeCard("Trade", "Electrician"),
                _tradeCard("Van Number", "WX23 ELT"),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 1.1,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _gridData.length,
                  itemBuilder: (context, index) {
                    final data = _gridData[index];
                    return _gridCard(data);
                  },
                ),
                _addressTile(),
                _logoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tradeCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12.h),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        border: Border.all(width: 1, color: AppColors.textDarkBlue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkBlue,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(_GridItem data) {
    return Container(
      padding: EdgeInsets.all(21.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        border: Border.all(width: 1, color: AppColors.textDarkBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.highlightYellow,
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                  border: Border.all(color: AppColors.textDarkBlue, width: 1),
                ),
                child: Icon(
                  data.icon,
                  color: AppColors.textDarkBlue,
                  size: 20.sp,
                ),
              ),
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkBlue,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Text(
              data.body,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDarkBlue,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressTile() {
    return Container(
      padding: EdgeInsets.all(12.h),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        border: Border.all(width: 1, color: AppColors.textDarkBlue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: AppColors.highlightYellow,
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              border: Border.all(color: AppColors.textDarkBlue, width: 1),
            ),
            child: Icon(
              Icons.location_on,
              color: AppColors.textDarkBlue,
              size: 20.sp,
            ),
          ),
          Text(
            "14 Maple Close, Cheshunt, EN8 9QR",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      child: Container(
        padding: EdgeInsets.all(14.r),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: Border.all(width: 1, color: AppColors.streakOrange),
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.streakOrange, size: 20.sp),
            SizedBox(width: 6.w),
            Text(
              "Log Out",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.streakOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
