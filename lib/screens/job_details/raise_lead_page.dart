import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum RaiseLeadKind { ppm, pm, reactive, refer }

class RaiseLeadPage extends StatefulWidget {
  const RaiseLeadPage({
    super.key,
    required this.kind,
    required this.jobId,
    this.jobNumber = '',
  });

  final RaiseLeadKind kind;
  final String jobId;
  final String jobNumber;

  static Future<bool?> open(
    BuildContext context, {
    required RaiseLeadKind kind,
    required String jobId,
    String jobNumber = '',
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            RaiseLeadPage(kind: kind, jobId: jobId, jobNumber: jobNumber),
      ),
    );
  }

  @override
  State<RaiseLeadPage> createState() => _RaiseLeadPageState();
}

class _RaiseLeadPageState extends State<RaiseLeadPage> {
  final _message = TextEditingController();
  final _buddy = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    _buddy.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.kind) {
      case RaiseLeadKind.ppm:
        return 'PPM lead';
      case RaiseLeadKind.pm:
        return 'PM project lead';
      case RaiseLeadKind.reactive:
        return 'Hourly attendance';
      case RaiseLeadKind.refer:
        return 'Refer and earn';
    }
  }

  Future<void> _submit() async {
    final message = _message.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Describe the issue before sending.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final category = switch (widget.kind) {
        RaiseLeadKind.ppm => 'PPM_INTEREST',
        RaiseLeadKind.pm => 'PM_INTEREST',
        RaiseLeadKind.reactive => 'HOURLY_ATTENDANCE',
        RaiseLeadKind.refer => 'REFERRAL',
      };
      await PillarClient.raiseEnquiry(
        category: category,
        description: widget.kind == RaiseLeadKind.refer
            ? 'Referral for ${_buddy.text.trim()}: $message'
            : message,
        details: {
          'job_id': widget.jobId,
          'job_number': widget.jobNumber,
          if (widget.kind == RaiseLeadKind.refer) 'buddy': _buddy.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Scaffold(
      backgroundColor: theme.base,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  CommandCentreBackButton(
                    onTap: () => Navigator.of(context).maybePop(false),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  if (widget.kind == RaiseLeadKind.refer) ...[
                    Text(
                      'Buddy / referred customer',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashHeading,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _buddy,
                      style: TextStyle(color: theme.text),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(color: theme.textMuted),
                        filled: true,
                        fillColor: theme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: theme.isDark
                              ? BorderSide(color: theme.border, width: 0.5)
                              : BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: theme.isDark
                              ? BorderSide(color: theme.border, width: 0.5)
                              : BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  Text(
                    widget.kind == RaiseLeadKind.reactive
                        ? 'Issue description'
                        : 'Notes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashHeading,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _message,
                    maxLines: 6,
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      hintText: 'What should the office see?',
                      hintStyle: TextStyle(color: theme.textMuted),
                      filled: true,
                      fillColor: theme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: theme.isDark
                            ? BorderSide(color: theme.border, width: 0.5)
                            : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: theme.isDark
                            ? BorderSide(color: theme.border, width: 0.5)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF23D),
                    foregroundColor: const Color(0xFF0B1F3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    _submitting ? 'Sending…' : 'Send to office',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
