import 'package:chumley_navigator/core/responsive/responsive_overlays.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReferralModalSheet extends StatefulWidget {
  final VisitJob job;
  final VoidCallback onSuccess;

  const ReferralModalSheet({
    super.key,
    required this.job,
    required this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required VisitJob job,
    required VoidCallback onSuccess,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ReferralModalSheet(
        job: job,
        onSuccess: () {
          Navigator.of(sheetContext).pop();
          onSuccess();
        },
      ),
    );
  }

  @override
  State<ReferralModalSheet> createState() => _ReferralModalSheetState();
}

class _ReferralModalSheetState extends State<ReferralModalSheet> {
  final _tradeController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tradeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await PillarClient.raiseEnquiry(
      category: 'REFERRAL',
      description:
          'Referral for ${_tradeController.text.trim()}: ${_noteController.text.trim()}',
      details: {'job_id': widget.job.id, 'job_number': widget.job.jobNumber},
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
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
                    color: theme.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(LucideIcons.x, size: 20, color: theme.textMuted),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Refer work outside your trade and earn points / rewards.',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _tradeController,
            style: TextStyle(fontSize: 13.sp, color: theme.text),
            decoration: InputDecoration(
              labelText: 'Trade required',
              labelStyle: TextStyle(color: theme.textMuted),
              hintText: 'e.g. Roofing, Carpentry, Electrical',
              hintStyle: TextStyle(fontSize: 12.sp, color: theme.textMuted),
              filled: true,
              fillColor: theme.surfaceDeep,
              border: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: TextStyle(fontSize: 13.sp, color: theme.text),
            decoration: InputDecoration(
              labelText: 'Customer scope / notes',
              labelStyle: TextStyle(color: theme.textMuted),
              hintText: 'Customer needs guttering replaced...',
              hintStyle: TextStyle(fontSize: 12.sp, color: theme.textMuted),
              filled: true,
              fillColor: theme.surfaceDeep,
              border: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: NavigatorTokens.fieldRadius,
                borderSide: BorderSide(color: theme.border),
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
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Referral',
                      style: NavigatorTokens.buttonLabelStyle(14.sp),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
