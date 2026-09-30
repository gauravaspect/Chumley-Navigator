import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/pillar/on_site_forms_session.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobActionsPanel extends StatelessWidget {
  final DashboardTheme theme;
  final Color statusColor;
  final IconData statusIcon;
  final String currentStatus;
  final bool isCompleted;
  final bool loadingDetail;
  final bool statusUpdating;
  final String? primaryNextStatus;
  final List<String> skipAheadStatuses;
  final bool areRequiredFormsCompleted;
  final VoidCallback onPrimaryAction;
  final VoidCallback onResumeForms;
  final ValueChanged<String> onSkipAheadAction;

  const JobActionsPanel({
    super.key,
    required this.theme,
    required this.statusColor,
    required this.statusIcon,
    required this.currentStatus,
    required this.isCompleted,
    required this.loadingDetail,
    required this.statusUpdating,
    required this.primaryNextStatus,
    required this.skipAheadStatuses,
    required this.areRequiredFormsCompleted,
    required this.onPrimaryAction,
    required this.onResumeForms,
    required this.onSkipAheadAction,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          border: Border(top: BorderSide(color: theme.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: Offset(0, -4.h),
              blurRadius: 16.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: theme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (loadingDetail)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: statusColor,
                  ),
                ),
              )
            else if (!isCompleted && primaryNextStatus != null)
              CallStyleActionSlider(
                text: OnSiteFormsSession.actionLabel(
                  isOnSite: SaStatus.isOnSite(currentStatus),
                  formsCompleted: areRequiredFormsCompleted,
                  primaryNextStatus: primaryNextStatus!,
                  statusActionLabel: SaStatus.actionLabel,
                ),
                backgroundColor: statusColor,
                icon: statusIcon,
                isEnabled: !statusUpdating,
                onConfirm: onPrimaryAction,
              )
            else if (!isCompleted &&
                SaStatus.isOnSite(currentStatus) &&
                !areRequiredFormsCompleted)
              CallStyleActionSlider(
                text: OnSiteFormsSession.continueFillingForms,
                backgroundColor: statusColor,
                icon: LucideIcons.clipboardList,
                isEnabled: !statusUpdating,
                onConfirm: onResumeForms,
              )
            else if (isCompleted)
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 16.sp,
                      color: const Color(0xFF22C55E),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Visit Complete',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            if (skipAheadStatuses.isNotEmpty &&
                !isCompleted &&
                !loadingDetail) ...[
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: skipAheadStatuses
                    .map((status) {
                      final isClosure = SaStatus.isJobClosure(status);
                      final blocked = isClosure && !areRequiredFormsCompleted;
                      return OutlinedButton(
                        onPressed: statusUpdating
                            ? null
                            : () {
                                if (blocked) {
                                  onResumeForms();
                                  return;
                                }
                                onSkipAheadAction(status);
                              },
                        child: Text(
                          blocked ? OnSiteFormsSession.continueToForms : status,
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
