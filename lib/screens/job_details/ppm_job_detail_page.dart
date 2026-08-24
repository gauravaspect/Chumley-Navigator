import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/forms/eicr_form_page.dart';
import 'package:chumley_navigator/screens/job/job_visit_router.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/screens/job_details/widgets/pm_lead_wizard.dart';
import 'package:chumley_navigator/screens/job_details/widgets/ppm_lead_wizard.dart';
import 'package:chumley_navigator/screens/job_details/widgets/reactive_attendance_modal.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PpmJobDetailPage extends StatefulWidget {
  const PpmJobDetailPage({super.key, required this.task});

  final PpmJobTask task;

  static void open(BuildContext context, PpmJobTask task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PpmJobDetailPage(task: task),
      ),
    );
  }

  @override
  State<PpmJobDetailPage> createState() => _PpmJobDetailPageState();
}

class _PpmJobDetailPageState extends State<PpmJobDetailPage> {
  // Status lifecycle: 1 = Dispatched, 2 = In Transit, 3 = On Site / In Progress, 4 = Completed
  int _statusIndex = 1;
  bool _cp12Completed = false;
  bool _eicrCompleted = false;
  bool _worksFormCompleted = false;

  PpmJobTask get task => widget.task;

  static const List<String> _statusLabels = [
    'Scheduled',
    'Dispatched',
    'In Transit',
    'On Site (In Progress)',
    'Visit Completed',
  ];

  static const List<Color> _statusColors = [
    Color(0xFF6728C8),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF22C55E),
  ];

  static const List<String> _actionLabels = [
    'Slide to Dispatch',
    'Slide to start journey',
    'Slide to arrive on site',
    'Continue form',
    '',
  ];

  final _drafts = FormDraftStore();

  String get workOrderId =>
      task.id.isNotEmpty ? task.id : task.appointmentNumber;

  VisitJob get _visitJob => VisitJob.fromPpmTask(task);

  @override
  void initState() {
    super.initState();
    _loadSavedStatus();
  }

  Future<void> _loadSavedStatus() async {
    final saved = await PillarClient.getLocalStatus(workOrderId);
    if (saved != null && mounted) {
      setState(() {
        if (saved == PillarClient.statusInTransit) {
          _statusIndex = 2;
        } else if (saved == PillarClient.statusOnSite) {
          _statusIndex = 3;
        } else if (saved == PillarClient.statusComplete) {
          _statusIndex = 4;
          _cp12Completed = _visitJob.kind == FormKind.gas;
          _worksFormCompleted = _visitJob.kind == FormKind.bath;
        }
      });
    }
  }

  bool get isOnSite => _statusIndex >= 3;
  bool get isCompleted => _statusIndex == 4;

  String _formatHour(int hour) =>
      '${hour.toString().padLeft(2, '0')}:00';

  int get _completedCount =>
      (_cp12Completed ? 1 : 0) + (_eicrCompleted ? 1 : 0);

  void _showOnSiteRequiredSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.lock, color: Colors.white, size: 16.sp),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text(
                'Slide to Arrive On Site before opening inspection forms.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Future<void> _syncStatusFromStore() async {
    final saved = await PillarClient.getLocalStatus(workOrderId);
    if (!mounted || saved == null) return;
    setState(() {
      if (saved == PillarClient.statusInTransit) {
        _statusIndex = 2;
      } else if (saved == PillarClient.statusOnSite) {
        _statusIndex = 3;
      } else if (saved == PillarClient.statusComplete) {
        _statusIndex = 4;
        switch (_visitJob.kind) {
          case FormKind.gas:
            _cp12Completed = true;
          case FormKind.bath:
            _worksFormCompleted = true;
          case FormKind.leak:
            break;
        }
      }
    });
  }

  Future<void> _openVisitWizard({required int initialStep}) async {
    await JobVisitRouter.pushVisitWizard(
      context,
      _visitJob,
      initialStep: initialStep,
      onSubmitted: () {
        if (mounted) {
          setState(() {
            _statusIndex = 4;
            switch (_visitJob.kind) {
              case FormKind.gas:
                _cp12Completed = true;
              case FormKind.bath:
                _worksFormCompleted = true;
              case FormKind.leak:
                break;
            }
          });
        }
      },
    );
    await _syncStatusFromStore();
  }

  Future<void> _openPrimaryVisitForm() async {
    if (!isOnSite) {
      _showOnSiteRequiredSnackbar();
      return;
    }
    final step = await _drafts.loadFurthestStep(workOrderId);
    await _openVisitWizard(initialStep: step);
  }

  Future<void> _openEicrForm() async {
    if (!isOnSite) {
      _showOnSiteRequiredSnackbar();
      return;
    }
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EicrFormPage(
          appointmentNumber: task.appointmentNumber,
          engineerName: task.allocatedEngineerName.isNotEmpty
              ? task.allocatedEngineerName
              : task.engineerEmail,
          postcode: task.postcode,
          subject: task.subject,
        ),
      ),
    );
    if (completed == true && mounted) {
      setState(() => _eicrCompleted = true);
    }
  }

  Future<void> _advanceStatus() async {
    if (_statusIndex == 1) {
      await PillarClient.setStatus(
        jobId: workOrderId,
        newStatus: PillarClient.statusInTransit,
        engineerEmail: task.engineerEmail,
      );
      if (mounted) setState(() => _statusIndex = 2);
      return;
    }

    if (_statusIndex == 2) {
      await _openVisitWizard(initialStep: 0);
      if (mounted && _statusIndex < 3) {
        setState(() => _statusIndex = 3);
      }
      return;
    }

    if (_statusIndex == 3) {
      final step = await _drafts.loadFurthestStep(workOrderId);
      await _openVisitWizard(initialStep: step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final hours = '${_formatHour(task.startHour)} – ${_formatHour(task.endHour)}';

    return Scaffold(
      backgroundColor:
          theme.isDark ? AppColors.darkBase : AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectBranding(
                  progress: 1.0,
                  expandedHeight: 54.h,
                  collapsedHeight: 54.h,
                  theme: theme,
                  hasBackButton: true,
                  title: Text(
                    'PPM JOB',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: theme.dashTitle,
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 16.w,
                  child: CommandCentreBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: _statusColors[_statusIndex].withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _statusColors[_statusIndex].withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? LucideIcons.badgeCheck : LucideIcons.clock,
                            size: 18.sp,
                            color: _statusColors[_statusIndex],
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Status: ${_statusLabels[_statusIndex]}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _statusColors[_statusIndex],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? AppColors.darkSurface
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.ppmAccent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.ppmAccent,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'PPM',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  task.appointmentNumber.isNotEmpty
                                      ? task.appointmentNumber
                                      : 'PPM Task',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.dashMuted,
                                  ),
                                ),
                              ),
                              Text(
                                '${task.endHour - task.startHour}h duration',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ppmAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            task.subject.isNotEmpty
                                ? task.subject
                                : 'Planned Preventive Maintenance',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.dashTitle,
                            ),
                          ),
                          if (task.workTypeName.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Text(
                              task.workTypeName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.dashSubtitle,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Required inspection forms
                    _sectionLabel(theme, 'REQUIRED INSPECTION FORMS'),
                    SizedBox(height: 8.h),
                    Opacity(
                      opacity: isOnSite ? 1.0 : 0.55,
                      child: Column(
                        children: [
                          if (_visitJob.kind == FormKind.gas) ...[
                            _formCard(
                              theme: theme,
                              title: 'Landlord Gas Safety (CP12)',
                              subtitle: _cp12Completed
                                  ? 'Completed & signed off'
                                  : '12 steps — Risk assessment through Sign off',
                              completed: _cp12Completed,
                              onTap: _openPrimaryVisitForm,
                            ),
                            SizedBox(height: 10.h),
                            _formCard(
                              theme: theme,
                              title: 'Electrical Inspection (EICR)',
                              subtitle: _eicrCompleted
                                  ? 'Completed & signed off'
                                  : 'Tap to complete EICR inspection form',
                              completed: _eicrCompleted,
                              onTap: _openEicrForm,
                            ),
                          ] else if (_visitJob.kind == FormKind.bath) ...[
                            _formCard(
                              theme: theme,
                              title: 'Bathroom / Works Visit',
                              subtitle: _worksFormCompleted
                                  ? 'Completed & signed off'
                                  : '5 steps — Risk assessment through Review',
                              completed: _worksFormCompleted,
                              onTap: _openPrimaryVisitForm,
                            ),
                          ] else ...[
                            _formCard(
                              theme: theme,
                              title: 'Leak Detection',
                              subtitle: _cp12Completed
                                  ? 'Completed & signed off'
                                  : '5 steps — Safety through Sign off',
                              completed: _cp12Completed,
                              onTap: _openPrimaryVisitForm,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Follow-on Lead Raising Hub
                    _sectionLabel(theme, 'RAISE OPPORTUNITIES & LEADS'),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: theme.border),
                      ),
                      child: Column(
                        children: [
                          _buildLeadButton(
                            theme: theme,
                            title: 'Raise PPM Contract Lead',
                            subtitle: 'Recurring maintenance for boiler/AC/cylinders',
                            icon: LucideIcons.calendarClock,
                            onTap: () => PpmLeadWizard.show(context, jobId: task.appointmentNumber, postcode: task.postcode),
                          ),
                          Divider(color: theme.border, height: 16.h),
                          _buildLeadButton(
                            theme: theme,
                            title: 'Raise Project Management (PM) Lead',
                            subtitle: 'Major bathroom/kitchen/boiler refurbishment',
                            icon: LucideIcons.layers,
                            onTap: () => PmLeadWizard.show(context, jobId: task.appointmentNumber, postcode: task.postcode),
                          ),
                          Divider(color: theme.border, height: 16.h),
                          _buildLeadButton(
                            theme: theme,
                            title: 'Raise Reactive Attendance',
                            subtitle: 'Dispatched urgent issue to office',
                            icon: LucideIcons.wrench,
                            onTap: () => ReactiveAttendanceModal.show(context, jobId: task.appointmentNumber, postcode: task.postcode),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    _sectionLabel(theme, 'APPOINTMENT DETAILS'),
                    SizedBox(height: 8.h),
                    _detailsCard(theme, [
                      _DetailRow(
                        icon: LucideIcons.calendar,
                        label: 'Date',
                        value: 'Today',
                      ),
                      _DetailRow(
                        icon: LucideIcons.clock,
                        label: 'Time window',
                        value: hours,
                      ),
                      _DetailRow(
                        icon: LucideIcons.mapPin,
                        label: 'Postcode',
                        value: task.postcode,
                      ),
                      _DetailRow(
                        icon: LucideIcons.user,
                        label: 'Engineer',
                        value: task.allocatedEngineerName.isNotEmpty
                            ? task.allocatedEngineerName
                            : task.engineerEmail,
                      ),
                      _DetailRow(
                        icon: LucideIcons.circleCheck,
                        label: 'Progress',
                        value: '$_completedCount / 2 forms completed',
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: isCompleted
            ? Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.badgeCheck, color: const Color(0xFF22C55E), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'PPM Visit Completed & Synced to Spine',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              )
            : CallStyleActionSlider(
                text: _actionLabels[_statusIndex],
                backgroundColor: _statusColors[_statusIndex],
                icon: _statusIndex == 1
                    ? LucideIcons.navigation
                    : _statusIndex == 2
                        ? LucideIcons.wrench
                        : LucideIcons.badgeCheck,
                isEnabled: _statusIndex < 3 || (_statusIndex == 3 && (_cp12Completed || _eicrCompleted)),
                onConfirm: _advanceStatus,
              ),
      ),
    );
  }

  Widget _buildLeadButton({
    required DashboardTheme theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: theme.text)),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 11.sp, color: theme.textMuted)),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16.sp, color: theme.textMuted),
        ],
      ),
    );
  }

  Widget _formCard({
    required DashboardTheme theme,
    required String title,
    required String subtitle,
    required bool completed,
    required VoidCallback onTap,
  }) {
    final accent = AppColors.ppmAccent;
    return Material(
      color: theme.isDark ? AppColors.darkSurface : AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: completed
                  ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                  : theme.dashBorderLight,
              width: completed ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: completed ? const Color(0xFF22C55E) : accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  completed ? LucideIcons.circleCheck : LucideIcons.fileText,
                  size: 18.sp,
                  color: AppColors.white,
                ),
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
                        color: theme.dashTitle,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: completed ? const Color(0xFF22C55E) : theme.dashMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18.sp,
                color: theme.dashMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(DashboardTheme theme, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: theme.dashMuted,
      ),
    );
  }

  Widget _detailsCard(DashboardTheme theme, List<_DetailRow> rows) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dashBorderLight),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: theme.dashBorderLight),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  Icon(rows[i].icon, size: 16.sp, color: AppColors.ppmAccent),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 88.w,
                    child: Text(
                      rows[i].label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.dashMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].value.isNotEmpty ? rows[i].value : '—',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.dashTitle,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
