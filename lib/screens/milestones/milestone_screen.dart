import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/milestones/milestone_stat_card.dart';
import 'package:chumley_navigator/widgets/milestones/milestone_timeline_tile.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MilestoneScreen extends StatelessWidget {
  const MilestoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AspectBranding(),
                SizedBox(height: 20.h),
                FadeSlideIn(
                  child: Text(
                    'Your Journey \nwith Aspect!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      height: 1.08,
                      color: AppColors.textDarkBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: MilestoneStatCard(
                            icon: Icons.star_border_purple500,
                            title: 'Career Rating',
                            value: '4.80',
                            trailing: _starRating(4.8),
                          ),
                        ),
                        SizedBox(width: 12.w),
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
                SizedBox(height: 22.h),
                Text(
                  'Your milestone journey',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Track your career acheivements',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18.h),
                ..._timelineTiles(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _timelineTiles() {
    final data = <MilestoneTimelineTile>[
      MilestoneTimelineTile(
        title: 'Joined the Team',
        subtitle: 'Welcome to Aspect',
        trailing: 'Onboarded',
        description: 'Started your journey as a field engineer.',
        badgeText: 'Starter',
        badgeBg: AppColors.chartFillBlue,
        badgeTextColor: AppColors.primaryBlue,
        points: '+100 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'First 100 Jobs',
        subtitle: 'Productivity Milestone',
        trailing: '100 jobs',
        description: 'Completed 100+ service appointments.',
        badgeText: 'Rising Star',
        badgeBg: AppColors.successBackground,
        badgeTextColor: AppColors.successText,
        points: '+500 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: '500 Jobs Strong',
        subtitle: 'Productivity Milestone',
        trailing: '500 jobs',
        description: '168 of 500 service appointments completed.',
        badgeText: 'Workhorse',
        badgeBg: AppColors.dividerLight,
        badgeTextColor: AppColors.textInactive,
        points: '1,500 pts',
        completed: false,
      ),
      MilestoneTimelineTile(
        title: 'Highly Rated',
        subtitle: 'Customer Satisfaction',
        trailing: '4.5★',
        description: 'Average review rating above 4.5 stars.',
        badgeText: 'Champion',
        badgeBg: AppColors.accentLime,
        badgeTextColor: AppColors.textDarkBlue,
        points: '+600 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'CSAT Champion',
        subtitle: 'Customer Satisfaction',
        trailing: '4.8★',
        description: 'Maintained near-perfect review ratings.',
        badgeText: 'Ace',
        badgeBg: const Color(0xFFFFEDD5),
        badgeTextColor: const Color(0xFF7C2D12),
        points: '+1,200 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'Multi-Site Pro',
        subtitle: 'Coverage Excellence',
        trailing: '10 sites',
        description: 'Worked across 10+ sites.',
        badgeText: 'Coverage Pro',
        badgeBg: const Color(0xFFEDE9FE),
        badgeTextColor: const Color(0xFF5B21B6),
        points: '+400 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: 'Certified Expert',
        subtitle: 'Technical Mastery',
        trailing: '5 work types',
        description: 'Qualified across 5+ work types.',
        badgeText: 'Expert',
        badgeBg: const Color(0xFFEDE9FE),
        badgeTextColor: const Color(0xFF7C3AED),
        points: '+1,500 pts',
        completed: true,
      ),
      MilestoneTimelineTile(
        title: '5 Year Veteran',
        subtitle: 'Loyalty Milestone',
        trailing: '5 years',
        description: 'Five years with Aspect.',
        badgeText: 'Veteran',
        badgeBg: const Color(0xFFE0F2FE),
        badgeTextColor: const Color(0xFF0C4A6E),
        points: '+5,000 pts',
        completed: true,
        isLast: true,
      ),
    ];

    return List.generate(data.length, (i) {
      return FadeSlideIn(
        delay: Duration(milliseconds: 40 * i),
        offsetY: 10,
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
          size: 16.sp,
        );
      }),
    );
  }
}
