import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectBranding(),

                      SizedBox(height: 18.h),

                      Text(
                        "Your Journey \nwith Aspect!",
                        style: TextStyle(
                          fontSize: 30.sp,
                          height: 1.05,
                          color: const Color(0xFF17325E),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _headerCard(
                                Icons.star_border_purple500,
                                "Career Rating",
                                "4.80",
                                true,
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: _headerCard(
                                Icons.check_circle_outline,
                                "Payment Collection",
                                "99.0%",
                                false,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        "Your milestone journey",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDarkBlue,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        "Track your career acheivements",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),
                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                  children: [
                    _milestoneTile(
                      title: "Joined the Team",
                      subtitle: "Welcome to Aspect",
                      trailing: "Onboarded",
                      description:
                      "Started your journey as a field engineer.",
                      badgeText: "Starter",
                      badgeBg: const Color(0xFFD8E6FF),
                      badgeTextColor: const Color(0xFF27549D),
                      points: "+100 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "First 100 Jobs",
                      subtitle: "Productivity Milestone",
                      trailing: "100 jobs",
                      description:
                      "Completed 100+ service appointments.",
                      badgeText: "Rising Star",
                      badgeBg: const Color(0xFFDCFCE7),
                      badgeTextColor: const Color(0xFF166534),
                      points: "+500 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "500 Jobs Strong",
                      subtitle: "Productivity Milestone",
                      trailing: "500 jobs",
                      description:
                      "168 of 500 service appointments completed.",
                      badgeText: "Workhorse",
                      badgeBg: const Color(0xFFF1F3F5),
                      badgeTextColor: const Color(0xFF9CA3AF),
                      points: "1,500 pts",
                      completed: false,
                    ),

                    _milestoneTile(
                      title: "Highly Rated",
                      subtitle: "Customer Satisfaction",
                      trailing: "4.5★",
                      description:
                      "Average review rating above 4.5 stars.",
                      badgeText: "Champion",
                      badgeBg: const Color(0xFFF4FF7F),
                      badgeTextColor: const Color(0xFF17325E),
                      points: "+600 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "CSAT Champion",
                      subtitle: "Customer Satisfaction",
                      trailing: "4.8★",
                      description:
                      "Maintained near-perfect review ratings.",
                      badgeText: "Ace",
                      badgeBg: const Color(0xFFFFEDD5),
                      badgeTextColor: const Color(0xFF7C2D12),
                      points: "+1,200 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "Multi-Site Pro",
                      subtitle: "Coverage Excellence",
                      trailing: "10 sites",
                      description: "Worked across 10+ sites.",
                      badgeText: "Coverage Pro",
                      badgeBg: const Color(0xFFEDE9FE),
                      badgeTextColor: const Color(0xFF5B21B6),
                      points: "+400 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "Certified Expert",
                      subtitle: "Technical Mastery",
                      trailing: "5 work types",
                      description:
                      "Qualified across 5+ work types.",
                      badgeText: "Expert",
                      badgeBg: const Color(0xFFEDE9FE),
                      badgeTextColor: const Color(0xFF7C3AED),
                      points: "+1,500 pts",
                      completed: true,
                    ),

                    _milestoneTile(
                      title: "5 Year Veteran",
                      subtitle: "Loyalty Milestone",
                      trailing: "5 years",
                      description: "Five years with Aspect.",
                      badgeText: "Veteran",
                      badgeBg: const Color(0xFFE0F2FE),
                      badgeTextColor: const Color(0xFF0C4A6E),
                      points: "+5,000 pts",
                      completed: true,
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(
      IconData icon,
      String title,
      String body,
      bool isRating,
      ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: const Color(0xFF27549D),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.accentLime,
              border: Border.all(
                color: const Color(0xFF27549D),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF27549D),
              size: 18.sp,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            body,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textDarkBlue,
              fontSize: 28.sp,
            ),
          ),

          SizedBox(height: 8.h),

          SizedBox(
            height: 18.h,
            child: isRating
                ? _starRating(double.tryParse(body) ?? 0.0)
                : null,
          ),
        ],
      ),
    );
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

  Widget _milestoneTile({
    required String title,
    required String subtitle,
    required String trailing,
    required String description,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required String points,
    required bool completed,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40.w,
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF27549D)
                      : AppColors.white,
                  border: completed
                      ? null
                      : Border.all(
                    color: const Color(0xFF9FC3FC),
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completed
                      ? Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 18.sp,
                  )
                      : Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF9FC3FC),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              if (!isLast)
                Container(
                  width: 2.w,
                  height: 40.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFF27549D)
                        : const Color(0xFFD1D9E3),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: completed
                    ? const Color(0xFF27549D)
                    : const Color(0xFF9FC3FC),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: completed
                                  ? const Color(0xFF17325E)
                                  : const Color(0xFF848EA3),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: completed
                                  ? const Color(0xFF27549D)
                                  : const Color(0xFF9FC3FC),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      trailing,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF848EA3),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: completed
                        ? const Color(0xFF646F86)
                        : const Color(0xFFB0BAC9),
                  ),
                ),

                SizedBox(height: 8.h),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius:
                        BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 6.w),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: completed
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F3F5),
                        borderRadius:
                        BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        points,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: completed
                              ? const Color(0xFF15803D)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}