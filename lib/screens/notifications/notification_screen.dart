import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlue,

        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────
                // BACK BUTTON
                // ─────────────────────────────

                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () {Navigator.pushReplacementNamed(context, AppRoutes.home);},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 22.sp,
                    color: AppColors.textDarkBlue,
                  ),
                ),

                SizedBox(height: 6.h),

                // ─────────────────────────────
                // TITLE
                // ─────────────────────────────

                Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkBlue,
                  ),
                ),

                SizedBox(height: 20.h),

                // ─────────────────────────────
                // TAB BAR
                // ─────────────────────────────

                TabBar(
                  isScrollable: true,

                  labelPadding: EdgeInsets.only(
                    right: 28.w,
                  ),

                  indicatorColor:
                  AppColors.textDarkBlue,

                  indicatorWeight: 3.h,

                  dividerColor: Colors.transparent,

                  splashFactory:
                  NoSplash.splashFactory,

                  overlayColor:
                  WidgetStateProperty.all(
                    Colors.transparent,
                  ),

                  labelColor:
                  AppColors.textDarkBlue,

                  unselectedLabelColor:
                  Colors.grey,

                  labelStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  unselectedLabelStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  tabs: const [
                    Tab(text: "All"),
                    Tab(text: "Unread"),
                    Tab(text: "Read"),
                  ],
                ),

                SizedBox(height: 20.h),

                // ─────────────────────────────
                // TAB VIEWS
                // ─────────────────────────────

                Expanded(
                  child: TabBarView(
                    children: [
                      _tabView("You\'re all caught up","New jobs,reviews and office updates will appear here"),
                      _tabView("No new notifications","New jobs,reviews and office updates will appear here"),
                      _tabView("Nothing to read yet","Once you\'ve opened a notification, it will appear here"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabView(String title,String body) {
    return Column(
      children: [
        Container(
          height: 52.h,
          width: 52.w,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderDefault,width: 1)
          ),
          child: Image.asset("assets/images/bell.png",height: 52.h,width: 52.w,),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkBlue,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 240.w,
          child: Text(
            body,

            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,

              color: AppColors.textPlaceholder,
            ),
          ),
        ),
      ],
    );
  }
}