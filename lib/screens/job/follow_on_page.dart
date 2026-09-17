import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/work_order_page.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum FollowOnPhase { raise, jobClosed, visitComplete }

class FollowOnPage extends StatelessWidget {
  const FollowOnPage({
    super.key,
    required this.job,
    this.phase = FollowOnPhase.raise,
  });

  final VisitJob job;
  final FollowOnPhase phase;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      FollowOnPhase.raise => _RaiseFollowOnView(job: job),
      FollowOnPhase.jobClosed => _JobClosedView(job: job),
      FollowOnPhase.visitComplete => _VisitCompleteView(job: job),
    };
  }
}

// ─────────────────────────────────────────────────────────────
// 1. WO - Raise follow-on (s-2104-3322)
// ─────────────────────────────────────────────────────────────
class _RaiseFollowOnView extends StatelessWidget {
  const _RaiseFollowOnView({required this.job});

  final VisitJob job;

  void _goToJobClosed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowOnPage(job: job, phase: FollowOnPhase.jobClosed),
      ),
    );
  }

  void _showHourlyAttendanceSheet(BuildContext context) {
    final noteController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: NavigatorTokens.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Raise Hourly Attendance',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.brandNavy,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Specify urgent callback or reactive attendance details for ${job.jobNumber}.',
              style: TextStyle(
                fontSize: 12.sp,
                color: NavigatorTokens.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13.sp,
                color: NavigatorTokens.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. Return required with 22mm copper pipe & fittings...',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: NavigatorTokens.textTertiary,
                ),
                filled: true,
                fillColor: NavigatorTokens.brandNavySoft,
                border: OutlineInputBorder(
                  borderRadius: NavigatorTokens.fieldRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NavigatorTokens.brandNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: NavigatorTokens.buttonRadius,
                  ),
                ),
                onPressed: () async {
                  await PillarClient.raiseEnquiry(
                    category: 'HOURLY_ATTENDANCE',
                    description: noteController.text.trim().isEmpty
                        ? 'Hourly attendance callback for ${job.jobNumber}'
                        : noteController.text.trim(),
                    details: {'job_id': job.id, 'job_number': job.jobNumber},
                  );
                  if (context.mounted) {
                    Navigator.of(sheetContext).pop();
                    _goToJobClosed(context);
                  }
                },
                child: Text(
                  'Submit Attendance Request',
                  style: NavigatorTokens.buttonLabelStyle(14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralSheet(BuildContext context) {
    final tradeController = TextEditingController();
    final noteController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: NavigatorTokens.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Refer and Earn',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.brandNavy,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Refer work outside your trade and earn points / rewards.',
              style: TextStyle(
                fontSize: 12.sp,
                color: NavigatorTokens.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: tradeController,
              style: TextStyle(
                fontSize: 13.sp,
                color: NavigatorTokens.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Trade required',
                hintText: 'e.g. Roofing, Carpentry, Electrical',
                filled: true,
                fillColor: NavigatorTokens.brandNavySoft,
                border: OutlineInputBorder(
                  borderRadius: NavigatorTokens.fieldRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: noteController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13.sp,
                color: NavigatorTokens.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Customer scope / notes',
                hintText: 'Customer needs guttering replaced...',
                filled: true,
                fillColor: NavigatorTokens.brandNavySoft,
                border: OutlineInputBorder(
                  borderRadius: NavigatorTokens.fieldRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NavigatorTokens.brandNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: NavigatorTokens.buttonRadius,
                  ),
                ),
                onPressed: () async {
                  await PillarClient.raiseEnquiry(
                    category: 'REFERRAL',
                    description:
                        'Referral for ${tradeController.text.trim()}: ${noteController.text.trim()}',
                    details: {'job_id': job.id, 'job_number': job.jobNumber},
                  );
                  if (context.mounted) {
                    Navigator.of(sheetContext).pop();
                    _goToJobClosed(context);
                  }
                },
                child: Text(
                  'Submit Referral',
                  style: NavigatorTokens.buttonLabelStyle(14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NavigatorTokens.surfaceChrome,
      appBar: AppBar(
        backgroundColor: NavigatorTokens.surfaceChrome,
        foregroundColor: NavigatorTokens.brandNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Follow-on work',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NavigatorTokens.pageGradient),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          children: [
            Text(
              'Anything else for this site?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: NavigatorTokens.brandNavy,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Raise a follow-on enquiry while you\'re still on site, or confirm none is required.',
              style: TextStyle(
                fontSize: 13.sp,
                color: NavigatorTokens.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 18.h),

            // Job Context Card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: NavigatorTokens.brandNavySoft,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      color: NavigatorTokens.brandNavy,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.customerName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: NavigatorTokens.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${job.jobNumber} · ${job.trade ?? job.description}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: NavigatorTokens.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            Text(
              'RAISE FOLLOW-ON WORK',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: NavigatorTokens.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),

            // Options Container
            Container(
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
              ),
              child: Column(
                children: [
                  _OptionTile(
                    icon: LucideIcons.fileText,
                    title: 'Create a fixed price quote',
                    subtitle:
                        'Create a new Fixed Price work order for this site',
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        AppRoutes.fixedPriceScreen,
                        arguments: FixedPriceJobContext.fromVisitJob(job),
                      );
                      if (context.mounted) {
                        _goToJobClosed(context);
                      }
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: NavigatorTokens.borderHairline,
                  ),
                  _OptionTile(
                    icon: LucideIcons.zap,
                    title: 'Raise an hourly attendance',
                    subtitle: 'Raise an urgent reactive task or callback',
                    onTap: () => _showHourlyAttendanceSheet(context),
                  ),
                  const Divider(
                    height: 1,
                    color: NavigatorTokens.borderHairline,
                  ),
                  _OptionTile(
                    icon: LucideIcons.gift,
                    title: 'Refer and earn',
                    subtitle: 'Refer work outside your trade and earn a reward',
                    onTap: () => _showReferralSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
          decoration: const BoxDecoration(
            color: NavigatorTokens.surfaceCard,
            border: Border(
              top: BorderSide(color: NavigatorTokens.borderHairline),
            ),
          ),
          child: Material(
            color: NavigatorTokens.brandNavySoft,
            borderRadius: NavigatorTokens.buttonRadius,
            child: InkWell(
              onTap: () => _goToJobClosed(context),
              borderRadius: NavigatorTokens.buttonRadius,
              child: Container(
                height: 44.h,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.check,
                      color: NavigatorTokens.brandNavy,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'No enquiry required',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: NavigatorTokens.brandNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: NavigatorTokens.brandNavySoft,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: NavigatorTokens.brandNavy, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: NavigatorTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: NavigatorTokens.textTertiary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 2. WO - Job closed (s-2272-3831)
// ─────────────────────────────────────────────────────────────
class _JobClosedView extends StatelessWidget {
  const _JobClosedView({required this.job});

  final VisitJob job;

  void _goToVisitComplete(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            FollowOnPage(job: job, phase: FollowOnPhase.visitComplete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NavigatorTokens.surfaceChrome,
      appBar: AppBar(
        backgroundColor: NavigatorTokens.surfaceChrome,
        foregroundColor: NavigatorTokens.brandNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Work Order',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NavigatorTokens.pageGradient),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          children: [
            // Chips row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: NavigatorTokens.successBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Closed',
                        style: TextStyle(
                          color: NavigatorTokens.successFg,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  job.jobNumber,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: NavigatorTokens.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Job closed',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: NavigatorTokens.brandNavy,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _chip(WorkOrderPage.jobTypeChip(job)),
                if (job.trade?.isNotEmpty == true) ...[
                  SizedBox(width: 6.w),
                  _chip(job.trade!),
                ],
              ],
            ),
            SizedBox(height: 18.h),

            // 5-step ladder (all 5 complete)
            _closedLadder(),
            SizedBox(height: 20.h),

            // Job closed banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
                border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 18.sp,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: NavigatorTokens.brandNavy,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'All forms submitted and follow-on work handled. Nothing further outstanding on this visit.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: NavigatorTokens.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Job Details Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.brandNavy,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _detailRow('Appointment ID', job.jobNumber),
                  const Divider(
                    height: 18,
                    color: NavigatorTokens.borderHairline,
                  ),
                  _detailRow('Type', WorkOrderPage.jobTypeChip(job)),
                  const Divider(
                    height: 18,
                    color: NavigatorTokens.borderHairline,
                  ),
                  _detailRow('Customer', job.customerName),
                  _detailRow(
                    'Description',
                    (job.description?.isNotEmpty == true)
                        ? job.description!
                        : job.siteAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: CallStyleActionSlider(
            text: 'Slide to visit complete',
            backgroundColor: NavigatorTokens.brandNavy,
            icon: LucideIcons.chevronRight,
            isEnabled: true,
            onConfirm: () => _goToVisitComplete(context),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: NavigatorTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: NavigatorTokens.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _closedLadder() {
    const labels = ['Sched.', 'Dispatch', 'Transit', 'On Site', 'Done'];
    return Row(
      children: List.generate(5, (i) {
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: NavigatorTokens.brandNavy,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: NavigatorTokens.brandNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: NavigatorTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: NavigatorTokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 3. WO - Visit complete (s-2280-3863)
// ─────────────────────────────────────────────────────────────
class _VisitCompleteView extends StatelessWidget {
  const _VisitCompleteView({required this.job});

  final VisitJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NavigatorTokens.surfaceChrome,
      appBar: AppBar(
        backgroundColor: NavigatorTokens.surfaceChrome,
        foregroundColor: NavigatorTokens.brandNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Work Order',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NavigatorTokens.pageGradient),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          children: [
            // Hero Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: const BoxDecoration(
                      color: NavigatorTokens.brandNavySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.check,
                      color: NavigatorTokens.brandNavy,
                      size: 36.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Visit complete',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: NavigatorTokens.brandNavy,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${job.jobNumber} is closed. All forms are submitted and the visit is signed off.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: NavigatorTokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  const Divider(color: NavigatorTokens.borderHairline),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: NavigatorTokens.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.jobNumber,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: NavigatorTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.copy,
                          size: 18.sp,
                          color: NavigatorTokens.brandNavy,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: job.jobNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Appointment ID copied to clipboard',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // What happens next section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceCard,
                borderRadius: NavigatorTokens.cardRadius,
                boxShadow: NavigatorTokens.cardShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.brandNavy,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _stepRow(1, 'Your report goes to the office for review'),
                  SizedBox(height: 14.h),
                  _stepRow(2, 'The customer receives their visit summary'),
                  SizedBox(height: 14.h),
                  _stepRow(3, 'Points for this visit land in your Points Hub'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NavigatorTokens.brandNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: NavigatorTokens.buttonRadius,
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Back to home',
                style: NavigatorTokens.buttonLabelStyle(15.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepRow(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: const BoxDecoration(
            color: NavigatorTokens.brandNavySoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: NavigatorTokens.brandNavy,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: NavigatorTokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
