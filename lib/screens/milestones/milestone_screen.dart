import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/milestones/milestone_stat_card.dart';
import 'package:chumley_navigator/widgets/milestones/milestone_timeline_tile.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneScreen extends StatelessWidget {
  const MilestoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AspectBranding(),
                    SizedBox(height: 14.h),
                    Text(
                      'Milestones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    FadeSlideIn(
                      child: Text(
                        'Your journey with Aspect',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: theme.text,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: MilestoneStatCard(
                                icon: Icons.star_outline_rounded,
                                title: 'Career Rating',
                                value: '4.80',
                                trailing: _starRating(4.8),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Expanded(
                              child: MilestoneStatCard(
                                icon: Icons.check_circle_outline_rounded,
                                title: 'Payment Collection',
                                value: '99.0%',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'YOUR MILESTONE JOURNEY',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Track your career achievements',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ..._timelineTiles(theme),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _timelineTiles(DashboardTheme theme) {
    final data = <MilestoneTimelineTile>[
      MilestoneTimelineTile(
        title: 'Joined the Team',
        subtitle: 'Welcome to Aspect',
        trailing: 'Onboarded',
        description: 'Started your journey as a field engineer.',
        badgeText: 'Starter',
        badgeBg: theme.isDark
            ? AppColors.trendUpBgDark
            : AppColors.trendUpBgLight,
        badgeTextColor:
            theme.isDark ? AppColors.kpiBarHigh : AppColors.trendUpLight,
        points: '+100 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'First 100 Jobs',
        subtitle: 'Productivity Milestone',
        trailing: '100 jobs',
        description: 'Completed 100+ service appointments.',
        badgeText: 'Rising Star',
        badgeBg: theme.isDark
            ? AppColors.trendUpBgDark
            : AppColors.trendUpBgLight,
        badgeTextColor:
            theme.isDark ? AppColors.kpiBarHigh : AppColors.trendUpLight,
        points: '+500 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: '500 Jobs Strong',
        subtitle: 'Productivity Milestone',
        trailing: '500 jobs',
        description: '168 of 500 service appointments completed.',
        badgeText: 'Workhorse',
        badgeBg: theme.surfaceDeep,
        badgeTextColor: theme.textMuted,
        points: '1,500 pts',
        completed: false,
      ),
      MilestoneTimelineTile(
        title: 'Highly Rated',
        subtitle: 'Customer Satisfaction',
        trailing: '4.5★',
        description: 'Average review rating above 4.5 stars.',
        badgeText: 'Champion',
        badgeBg: theme.isDark
            ? AppColors.trendUpBgDark
            : AppColors.trendUpBgLight,
        badgeTextColor:
            theme.isDark ? AppColors.kpiBarHigh : AppColors.trendUpLight,
        points: '+600 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'CSAT Champion',
        subtitle: 'Customer Satisfaction',
        trailing: '4.8★',
        description: 'Maintained near-perfect review ratings.',
        badgeText: 'Ace',
        badgeBg: theme.isDark
            ? AppColors.darkSurfaceDeep
            : AppColors.lightSurfaceDeep,
        badgeTextColor: theme.text,
        points: '+1,200 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'Multi-Site Pro',
        subtitle: 'Coverage Excellence',
        trailing: '10 sites',
        description: 'Worked across 10+ sites.',
        badgeText: 'Coverage Pro',
        badgeBg: theme.isDark
            ? AppColors.darkSurfaceDeep
            : AppColors.lightSurfaceDeep,
        badgeTextColor: theme.textMuted,
        points: '+400 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'Certified Expert',
        subtitle: 'Technical Mastery',
        trailing: '5 work types',
        description: 'Qualified across 5+ work types.',
        badgeText: 'Expert',
        badgeBg: theme.isDark
            ? AppColors.darkSurfaceDeep
            : AppColors.lightSurfaceDeep,
        badgeTextColor: theme.textMuted,
        points: '+1,500 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: '5 Year Veteran',
        subtitle: 'Loyalty Milestone',
        trailing: '5 years',
        description: 'Five years with Aspect.',
        badgeText: 'Veteran',
        badgeBg: theme.isDark
            ? AppColors.trendUpBgDark
            : AppColors.trendUpBgLight,
        badgeTextColor:
            theme.isDark ? AppColors.kpiBarHigh : AppColors.trendUpLight,
        points: '+5,000 pts',
        completed: true,
        isLast: true,
      ),
    ];

    return List.generate(data.length, (i) {
      return FadeSlideIn(
        delay: Duration(milliseconds: 35 * i),
        offsetY: 8,
        child: data[i],
      );
    });
  }

  Widget _starRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.floor();
        final isHalf =
            !filled && index < rating && (rating - index) >= 0.5;

        return Icon(
          filled
              ? Icons.star_rounded
              : isHalf
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFF59E0B),
          size: 14.sp,
        );
      }),
    );
  }
}
