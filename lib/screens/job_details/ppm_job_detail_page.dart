import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/screens/forms/cp12_form_page.dart';
import 'package:chumley_navigator/screens/forms/eicr_form_page.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
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
  bool _cp12Completed = false;
  bool _eicrCompleted = false;

  PpmJobTask get task => widget.task;

  String _formatHour(int hour) =>
      '${hour.toString().padLeft(2, '0')}:00';

  int get _completedCount =>
      (_cp12Completed ? 1 : 0) + (_eicrCompleted ? 1 : 0);

  Future<void> _openCp12Form() async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => Cp12FormPage(
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
      setState(() => _cp12Completed = true);
    }
  }

  Future<void> _openEicrForm() async {
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
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  task.status.isNotEmpty
                                      ? task.status
                                      : 'Scheduled',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ppmAccent,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            task.subject.isNotEmpty
                                ? task.subject
                                : 'PPM Job',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: theme.dashHeading,
                            ),
                          ),
                          if (task.appointmentNumber.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              task.appointmentNumber,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.dashMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _sectionLabel(theme, 'JOB DETAILS'),
                    SizedBox(height: 8.h),
                    _detailsCard(theme, [
                      _DetailRow(
                        icon: LucideIcons.wrench,
                        label: 'Trade',
                        value: task.tradeGroup,
                      ),
                      _DetailRow(
                        icon: LucideIcons.briefcase,
                        label: 'Work type',
                        value: task.workTypeName,
                      ),
                      _DetailRow(
                        icon: LucideIcons.tags,
                        label: 'Job type',
                        value: task.jobType,
                      ),
                      _DetailRow(
                        icon: LucideIcons.mapPin,
                        label: 'Postcode',
                        value: task.postcode,
                      ),
                      _DetailRow(
                        icon: LucideIcons.clock,
                        label: 'Hours',
                        value: hours,
                      ),
                      _DetailRow(
                        icon: LucideIcons.user,
                        label: 'Engineer',
                        value: task.allocatedEngineerName.isNotEmpty
                            ? task.allocatedEngineerName
                            : task.engineerEmail,
                      ),
                      if (task.engineerEmail.isNotEmpty)
                        _DetailRow(
                          icon: LucideIcons.mail,
                          label: 'Email',
                          value: task.engineerEmail,
                        ),
                    ]),
                    SizedBox(height: 20.h),
                    _sectionLabel(theme, 'FORMS'),
                    SizedBox(height: 8.h),
                    _buildFormsCard(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsCard(DashboardTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.ppmAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.clipboardList,
                size: 16.sp,
                color: AppColors.ppmAccent,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pre-Completion Forms',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashTitle,
                ),
              ),
              const Spacer(),
              Text(
                '$_completedCount/2',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ppmAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _formRow(
            theme: theme,
            completed: _cp12Completed,
            accent: AppColors.ppmAccent,
            softBg: AppColors.ppmAccentSoft.withValues(alpha: 0.5),
            title: 'CP12 Form',
            subtitle: 'Landlord Gas Safety Record (CP12)',
            onTap: _openCp12Form,
          ),
          SizedBox(height: 10.h),
          _formRow(
            theme: theme,
            completed: _eicrCompleted,
            accent: AppColors.primaryBlue,
            softBg: AppColors.surfaceBlueTint,
            title: 'EICR Form',
            subtitle: 'Electrical Installation Condition Report (EICR)',
            onTap: _openEicrForm,
          ),
        ],
      ),
    );
  }

  Widget _formRow({
    required DashboardTheme theme,
    required bool completed,
    required Color accent,
    required Color softBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.isDark ? AppColors.darkBase : softBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed ? accent : accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  completed ? LucideIcons.circleCheck : LucideIcons.fileText,
                  size: 18.sp,
                  color: completed ? AppColors.white : accent,
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
                        color: theme.dashMuted,
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
