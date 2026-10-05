import 'package:chumley_navigator/components/dashboard/kpi_overview.dart';
import 'package:chumley_navigator/components/dashboard/points_card.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/core/responsive/responsive_breakpoints.dart';
import 'package:chumley_navigator/core/responsive/responsive_content.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/screens/profile/profile_screen.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/utils/user_display.dart';
import 'package:chumley_navigator/shimmers/dashboard_shimmer.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../components/dashboard/earnings_card.dart';
import '../../components/dashboard/todays_schedule_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  static const _sectionGap = 14.0;

  late final DashboardCubit _cubit;
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    _cubit = AppDependencies.createDashboardCubit()..load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) {
        AppDependencies.routeObserver.unsubscribe(this);
      }
      _route = route;
      AppDependencies.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppDependencies.routeObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    _cubit.refreshAppointments();
  }

  UserModel? _userFromState(DashboardState state) => state.userOrNull;

  /// Shimmer only when there is no cached profile to show yet.
  bool _shouldShowShimmer(DashboardState state, UserModel? user) {
    if (state is DashboardInitial) return true;
    if (state is DashboardLoading) return user == null;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ListenableBuilder(
        listenable: ThemeScope.of(context),
        builder: (context, _) {
          final theme = DashboardTheme.of(context);

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primaryBlue,
                secondary: AppColors.accentBlue,
              ),
              iconTheme: IconThemeData(color: theme.dashPrimary),
            ),
            child: BlocConsumer<DashboardCubit, DashboardState>(
              listener: (context, state) {
                if (state is DashboardError && state.cachedUser == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final user = _userFromState(state);
                final showShimmer = _shouldShowShimmer(state, user);

                return Scaffold(
                  backgroundColor: theme.base,
                  appBar: _buildAppBar(context, theme, user),
                  body: SafeArea(
                    child: RefreshIndicator(
                      color: theme.dashPrimary,
                      onRefresh: _cubit.refresh,
                      child: showShimmer
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [DashboardShimmer(theme: theme)],
                            )
                          : _buildBody(context, theme, state),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DashboardTheme theme,
    UserModel? user,
  ) {
    final toolbarHeight = 118.h;

    return PreferredSize(
      preferredSize: Size.fromHeight(toolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: toolbarHeight,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dashHeaderBorder, width: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Good Morning !',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.dashTitle,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22.sp,
                          height: 1.2,
                          color: theme.dashTitle,
                        ),
                        children: [
                          TextSpan(
                            text: user != null ? userFirstName(user) : 'there',
                            style: TextStyle(color: theme.dashPrimaryCalendar),
                          ),
                          const TextSpan(text: '👋🏻'),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.dashPrimary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.shieldCheck,
                            size: 16.sp,
                            color: AppColors.accentLime,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Tier 10 (Platinum)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.notifications,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: theme.headerBellBg,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            color: theme.dashPrimary,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => ProfileScreen.open(context, _cubit),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: theme.dashPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.dashCardBg, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user != null ? userInitials(user) : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardTheme theme,
    DashboardState state,
  ) {
    final resolvedUser = _userFromState(state);
    final user = resolvedUser ?? const UserModel();

    final sections = [
      PointsCard(user: user),
      // EarningCard(user: user),
      TodaysScheduleCard(
        appointments: state.appointmentsOrEmpty,
        ppmTasks: state.ppmTasksOrEmpty,
        isLoading: state.isAppointmentsLoading,
      ),
      KpiOverview(user: user),
      EarningCard(user: user),
    ];

    return ResponsiveContent(
      maxWidth: ResponsiveBreakpoints.pageContentMax,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              if (state is DashboardError) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.errorText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _cubit.refresh,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.dashPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              for (var i = 0; i < sections.length; i++) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 60 * i),
                  offsetY: 10,
                  duration: const Duration(milliseconds: 480),
                  child: sections[i],
                ),
                if (i < sections.length - 1) SizedBox(height: _sectionGap.h),
              ],
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
