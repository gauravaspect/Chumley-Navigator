import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WorkOrderPage extends StatelessWidget {
  const WorkOrderPage({
    super.key,
    required this.job,
    required this.kind,
    required this.phase,
    this.onStartJourney,
    this.onArriveOnSite,
    this.onContinueForm,
    this.onOpenFollowOn,
    this.statusWriteError,
  });

  final VisitJob job;
  final FormKind kind;
  final ResumePhase phase;
  final VoidCallback? onStartJourney;
  final VoidCallback? onArriveOnSite;
  final VoidCallback? onContinueForm;
  final VoidCallback? onOpenFollowOn;
  final String? statusWriteError;

  static String jobTypeChip(VisitJob job) {
    switch (job.coercedJobType) {
      case 'FP':
        return 'Fixed price';
      case 'PM':
        return 'PM project visit';
      default:
        return 'Reactive';
    }
  }

  static String statusChip(ResumePhase phase, String status) {
    if (phase == ResumePhase.form || status.toUpperCase() == 'ON_SITE') {
      return 'On site';
    }
    switch (phase) {
      case ResumePhase.transit:
        return 'In transit';
      case ResumePhase.complete:
        return 'Complete';
      case ResumePhase.dispatched:
        return 'Dispatched';
      case ResumePhase.form:
        return 'On site';
    }
  }

  IconData get _kindIcon {
    switch (kind) {
      case FormKind.gas:
        return LucideIcons.thermometer;
      case FormKind.bath:
        return LucideIcons.hardHat;
      case FormKind.leak:
        return LucideIcons.droplet;
    }
  }

  int get _ladderIndex {
    switch (phase) {
      case ResumePhase.dispatched:
        return 1;
      case ResumePhase.transit:
        return 2;
      case ResumePhase.form:
        return 3;
      case ResumePhase.complete:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = statusChip(phase, job.status);
    final complete = phase == ResumePhase.complete;
    return Scaffold(
      backgroundColor: NavigatorTokens.surfaceChrome,
      appBar: AppBar(
        backgroundColor: NavigatorTokens.surfaceChrome,
        foregroundColor: NavigatorTokens.brandNavy,
        elevation: 0,
        title: Text(
          job.jobNumber,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NavigatorTokens.pageGradient),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
          children: [
          Row(
            children: [
              Icon(_kindIcon, color: NavigatorTokens.brandNavy, size: 20.sp),
              SizedBox(width: 8.w),
              _chip(chip, NavigatorTokens.infoBg, NavigatorTokens.infoFg),
              SizedBox(width: 8.w),
              _chip(
                jobTypeChip(job),
                NavigatorTokens.surfaceMuted,
                NavigatorTokens.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            job.trade?.isNotEmpty == true ? job.trade! : (job.description ?? ''),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: NavigatorTokens.brandNavy,
            ),
          ),
          if (job.siteAddress.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              job.siteAddress,
              style: TextStyle(fontSize: 13.sp, color: NavigatorTokens.textSecondary),
            ),
          ],
          if (job.scheduledStart != null) ...[
            SizedBox(height: 4.h),
            Text(
              _window(job.scheduledStart!),
              style: TextStyle(fontSize: 13.sp, color: NavigatorTokens.textSecondary),
            ),
          ],
          SizedBox(height: 20.h),
          _ladder(_ladderIndex),
          if (complete) ...[
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: NavigatorTokens.successBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Job completed - all forms submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NavigatorTokens.successFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
          if (statusWriteError != null) ...[
            SizedBox(height: 12.h),
            Text(
              statusWriteError!,
              style: TextStyle(color: NavigatorTokens.errorFg, fontSize: 12.sp),
            ),
          ],
          ],
        ),
      ),
      bottomNavigationBar: _footer(complete),
    );
  }

  Widget _footer(bool complete) {
    final String label;
    final VoidCallback? action;
    if (complete || phase == ResumePhase.complete) {
      label = 'Slide to close job';
      action = onOpenFollowOn;
    } else if (phase == ResumePhase.form) {
      label = 'Continue form';
      action = onContinueForm;
    } else if (phase == ResumePhase.transit) {
      label = 'Slide to arrive on site';
      action = onArriveOnSite;
    } else {
      label = 'Slide to start journey';
      action = onStartJourney;
    }
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: CallStyleActionSlider(
          text: label,
          backgroundColor: NavigatorTokens.brandNavy,
          icon: LucideIcons.chevronRight,
          isEnabled: action != null,
          onConfirm: action ?? () {},
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _ladder(int active) {
    const labels = ['Scheduled', 'Dispatched', 'In transit', 'On site', 'Complete'];
    return Row(
      children: List.generate(5, (i) {
        final done = i < active;
        final current = i == active;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: current || done
                      ? NavigatorTokens.brandNavy
                      : NavigatorTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: current ? NavigatorTokens.brandNavy : NavigatorTokens.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _window(DateTime start) {
    final end = start.add(const Duration(hours: 2));
    String hh(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${hh(start)} – ${hh(end)}';
  }
}
