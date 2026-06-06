import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: theme.base,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommandCentreBackButton(
                      semanticsLabel: 'Back to home',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    TabBar(
                      isScrollable: true,
                      labelPadding: EdgeInsets.only(right: 24.w),
                      indicatorColor: theme.accent,
                      indicatorWeight: 2,
                      dividerColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      labelColor: theme.text,
                      unselectedLabelColor: theme.textMuted,
                      labelStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Unread'),
                        Tab(text: 'Read'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _EmptyTab(
                            theme: theme,
                            title: "You're all caught up",
                            body:
                                'New jobs, reviews and office updates will appear here',
                          ),
                          _EmptyTab(
                            theme: theme,
                            title: 'No new notifications',
                            body:
                                'New jobs, reviews and office updates will appear here',
                          ),
                          _EmptyTab(
                            theme: theme,
                            title: 'Nothing to read yet',
                            body:
                                "Once you've opened a notification, it will appear here",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.theme,
    required this.title,
    required this.body,
  });

  final DashboardTheme theme;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                shape: BoxShape.circle,
                border: Border.all(color: theme.border, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.notifications_outlined,
                size: 24.sp,
                color: theme.textMuted,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.text,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: theme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
