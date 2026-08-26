import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum PostSubmitPhase {
  jobCompleted,
  followOn,
  jobClosed,
  visitComplete,
}

/// Post-submit flow after form "Submit report":
/// Job completed → Follow-on → Job closed → Visit complete.
class PostSubmitFlow extends StatelessWidget {
  const PostSubmitFlow({
    super.key,
    required this.phase,
    required this.jobNumber,
    required this.customerName,
    required this.jobType,
    required this.workTypeLabel,
    required this.description,
    required this.onPhaseChanged,
    required this.onBackToHome,
    this.onRaiseEstimate,
    this.onRaiseReactive,
    this.onReferAndEarn,
  });

  final PostSubmitPhase phase;
  final String jobNumber;
  final String customerName;
  final String jobType;
  final String workTypeLabel;
  final String description;
  final ValueChanged<PostSubmitPhase> onPhaseChanged;
  final VoidCallback onBackToHome;
  final VoidCallback? onRaiseEstimate;
  final VoidCallback? onRaiseReactive;
  final VoidCallback? onReferAndEarn;

  static const _bgTop = Color(0xFFF4F9FF);
  static const _bgMid = Color(0xFFEDF4FE);
  static const _bgBottom = Color(0xFFE2ECFA);
  static const _textPrimary = Color(0xFF0B1F3A);
  static const _textSecondary = Color(0xFF5A6B85);
  static const _textCaption = Color(0xFF8A99B0);
  static const _fieldBorder = Color(0xFFE2E7F0);
  static const _badgeFill = Color(0xFFD8E6FC);
  static const _yellowCta = Color(0xFFFFF23D);
  static const _successGreen = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgMid, _bgBottom],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: switch (phase) {
        PostSubmitPhase.jobCompleted => _JobCompletedScreen(
            jobNumber: jobNumber,
            jobType: jobType,
            workTypeLabel: workTypeLabel,
            customerName: customerName,
            description: description,
            onCloseJob: () => onPhaseChanged(PostSubmitPhase.followOn),
          ),
        PostSubmitPhase.followOn => _FollowOnScreen(
            jobNumber: jobNumber,
            customerName: customerName,
            workTypeLabel: workTypeLabel,
            onNoEnquiry: () => onPhaseChanged(PostSubmitPhase.jobClosed),
            onRaiseEstimate: onRaiseEstimate,
            onRaiseReactive: onRaiseReactive,
            onReferAndEarn: onReferAndEarn,
          ),
        PostSubmitPhase.jobClosed => _JobClosedScreen(
            jobNumber: jobNumber,
            jobType: jobType,
            workTypeLabel: workTypeLabel,
            customerName: customerName,
            description: description,
            onVisitComplete: () => onPhaseChanged(PostSubmitPhase.visitComplete),
          ),
        PostSubmitPhase.visitComplete => _VisitCompleteScreen(
            jobNumber: jobNumber,
            onBackToHome: onBackToHome,
          ),
      },
    );
  }
}

// ── 1. Job completed ───────────────────────────────────────────

class _JobCompletedScreen extends StatelessWidget {
  const _JobCompletedScreen({
    required this.jobNumber,
    required this.jobType,
    required this.workTypeLabel,
    required this.customerName,
    required this.description,
    required this.onCloseJob,
  });

  final String jobNumber;
  final String jobType;
  final String workTypeLabel;
  final String customerName;
  final String description;
  final VoidCallback onCloseJob;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: PostSubmitFlow._successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: PostSubmitFlow._successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    jobNumber,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: PostSubmitFlow._textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Job Completed',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: PostSubmitFlow._textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _neutralChip(jobType),
                  _neutralChip(workTypeLabel),
                ],
              ),
              SizedBox(height: 18.h),
              _completedProgress(),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: PostSubmitFlow._successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job completed',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: PostSubmitFlow._textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'All forms submitted. This job is now closed.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: PostSubmitFlow._textCaption,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Job details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: PostSubmitFlow._textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _detailRow('Appointment ID', jobNumber),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    _detailRow('Type', jobType),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    _detailRow('Customer', customerName),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: PostSubmitFlow._textCaption,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: PostSubmitFlow._textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: CallStyleActionSlider(
            text: 'Slide to close job',
            backgroundColor: AppColors.primaryBlue,
            icon: LucideIcons.chevronRight,
            isEnabled: true,
            onConfirm: onCloseJob,
          ),
        ),
      ],
    );
  }

  Widget _neutralChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: PostSubmitFlow._badgeFill,
        borderRadius: BorderRadius.circular(500.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: PostSubmitFlow._textSecondary,
        ),
      ),
    );
  }

  Widget _completedProgress() {
    const labels = ['Sched.', 'Dispatch', 'Transit', 'On Site', 'Done'];
    return Column(
      children: [
        Row(
          children: List.generate(labels.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 2.h,
                  color: AppColors.primaryBlue,
                ),
              );
            }
            return Container(
              width: 16.w,
              height: 16.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.check, size: 10.sp, color: Colors.white),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Row(
          children: labels
              .map(
                (l) => Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: PostSubmitFlow._textSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: PostSubmitFlow._textCaption,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: PostSubmitFlow._textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 2. Follow-on ───────────────────────────────────────────────

class _FollowOnScreen extends StatelessWidget {
  const _FollowOnScreen({
    required this.jobNumber,
    required this.customerName,
    required this.workTypeLabel,
    required this.onNoEnquiry,
    this.onRaiseEstimate,
    this.onRaiseReactive,
    this.onReferAndEarn,
  });

  final String jobNumber;
  final String customerName;
  final String workTypeLabel;
  final VoidCallback onNoEnquiry;
  final VoidCallback? onRaiseEstimate;
  final VoidCallback? onRaiseReactive;
  final VoidCallback? onReferAndEarn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Anything else for this site?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: PostSubmitFlow._textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Raise a follow-on enquiry while you're still on site, or confirm none is required.",
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: PostSubmitFlow._textCaption,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: PostSubmitFlow._badgeFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 19.sp,
                      color: PostSubmitFlow._textPrimary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: PostSubmitFlow._textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$jobNumber · $workTypeLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: PostSubmitFlow._textCaption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Raise jobs',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: PostSubmitFlow._textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _raiseTile(
                      icon: LucideIcons.plus,
                      title: 'Create a fixed price quote',
                      subtitle:
                          'Create a new Fixed Price work order for this site',
                      onTap: onRaiseEstimate,
                    ),
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: PostSubmitFlow._fieldBorder,
                    ),
                    _raiseTile(
                      icon: LucideIcons.zap,
                      title: 'Raise an hourly attendance',
                      subtitle: 'Raise an urgent reactive task or callback',
                      onTap: onRaiseReactive,
                    ),
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: PostSubmitFlow._fieldBorder,
                    ),
                    _raiseTile(
                      icon: LucideIcons.gift,
                      title: 'Refer and earn',
                      subtitle:
                          'Refer work outside your trade and earn a reward',
                      onTap: onReferAndEarn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNoEnquiry,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: PostSubmitFlow._fieldBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.check,
                      size: 18.sp,
                      color: PostSubmitFlow._textPrimary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'No enquiry required',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _raiseTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: PostSubmitFlow._badgeFill,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 19.sp, color: AppColors.primaryBlue),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: PostSubmitFlow._textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: PostSubmitFlow._textCaption,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 17.sp,
              color: PostSubmitFlow._textCaption,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 3. Job closed ──────────────────────────────────────────────

class _JobClosedScreen extends StatelessWidget {
  const _JobClosedScreen({
    required this.jobNumber,
    required this.jobType,
    required this.workTypeLabel,
    required this.customerName,
    required this.description,
    required this.onVisitComplete,
  });

  final String jobNumber;
  final String jobType;
  final String workTypeLabel;
  final String customerName;
  final String description;
  final VoidCallback onVisitComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: PostSubmitFlow._successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Closed',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: PostSubmitFlow._successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    jobNumber,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: PostSubmitFlow._textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Job closed',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: PostSubmitFlow._textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: PostSubmitFlow._badgeFill,
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Text(
                      jobType,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: PostSubmitFlow._textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: PostSubmitFlow._badgeFill,
                      borderRadius: BorderRadius.circular(500.r),
                    ),
                    child: Text(
                      workTypeLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: PostSubmitFlow._textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _completedProgress(),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: PostSubmitFlow._successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job closed',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: PostSubmitFlow._textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'All forms submitted and follow-on work handled. Nothing further outstanding on this visit.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: PostSubmitFlow._textCaption,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Job details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: PostSubmitFlow._textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _detailRow('Appointment ID', jobNumber),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    _detailRow('Type', jobType),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    _detailRow('Customer', customerName),
                    Divider(height: 20.h, color: PostSubmitFlow._fieldBorder),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: PostSubmitFlow._textCaption,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: PostSubmitFlow._textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: CallStyleActionSlider(
            text: 'Slide to visit complete',
            backgroundColor: AppColors.primaryBlue,
            icon: LucideIcons.chevronRight,
            isEnabled: true,
            onConfirm: onVisitComplete,
          ),
        ),
      ],
    );
  }

  Widget _completedProgress() {
    const labels = ['Sched.', 'Dispatch', 'Transit', 'On Site', 'Done'];
    return Column(
      children: [
        Row(
          children: List.generate(labels.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 2.h,
                  color: AppColors.primaryBlue,
                ),
              );
            }
            return Container(
              width: 16.w,
              height: 16.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.check, size: 10.sp, color: Colors.white),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Row(
          children: labels
              .map(
                (l) => Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: PostSubmitFlow._textSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: PostSubmitFlow._textCaption,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: PostSubmitFlow._textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 4. Visit complete ──────────────────────────────────────────

class _VisitCompleteScreen extends StatelessWidget {
  const _VisitCompleteScreen({
    required this.jobNumber,
    required this.onBackToHome,
  });

  final String jobNumber;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 22.h),
                decoration: BoxDecoration(
                  color: PostSubmitFlow._textPrimary,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 36.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Visit complete',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$jobNumber is closed. All forms are submitted and the visit is signed off.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                jobNumber,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: jobNumber));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Appointment copied',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            LucideIcons.copy,
                            size: 18.sp,
                            color: PostSubmitFlow._yellowCta,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'What happens next',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: PostSubmitFlow._textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              _nextStep(1, 'Your report goes to the office for review'),
              SizedBox(height: 12.h),
              _nextStep(2, 'The customer receives their visit summary'),
              SizedBox(height: 12.h),
              _nextStep(3, 'Points for this visit land in your Points Hub'),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: Material(
            color: PostSubmitFlow._yellowCta,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: onBackToHome,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                child: Text(
                  'Back to home',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: PostSubmitFlow._textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextStep(int n, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PostSubmitFlow._badgeFill,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                color: PostSubmitFlow._textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

