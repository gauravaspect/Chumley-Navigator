import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modal for raising reactive attendance / office enquiry (category REACTIVE_ATTENDANCE)
class ReactiveAttendanceModal extends StatefulWidget {
  const ReactiveAttendanceModal({
    super.key,
    required this.jobId,
    this.customerName,
    this.postcode,
  });

  final String jobId;
  final String? customerName;
  final String? postcode;

  static Future<bool?> show(
    BuildContext context, {
    required String jobId,
    String? customerName,
    String? postcode,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReactiveAttendanceModal(
        jobId: jobId,
        customerName: customerName,
        postcode: postcode,
      ),
    );
  }

  @override
  State<ReactiveAttendanceModal> createState() => _ReactiveAttendanceModalState();
}

class _ReactiveAttendanceModalState extends State<ReactiveAttendanceModal> {
  final _descriptionController = TextEditingController();
  final _accessNotesController = TextEditingController();
  String _selectedTrade = 'Plumbing / Leak Detection';
  String _selectedUrgency = 'Next Day Attendance';
  bool _isSubmitting = false;
  bool _submitted = false;

  static const List<String> _trades = [
    'Plumbing / Leak Detection',
    'Gas / Heating Breakdown',
    'Electrical Emergency',
    'Drainage / Blockage',
    'Roofing / Exterior Leak',
    'Carpentry / Locksmith',
  ];

  static const List<String> _urgencyLevels = [
    'Emergency (2–4 hours)',
    'Same Day Attendance',
    'Next Day Attendance',
    'Standard Appointment',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _accessNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final success = await PillarClient.raiseEnquiry(
      category: 'REACTIVE_ATTENDANCE',
      description: _descriptionController.text.trim(),
      details: {
        'trade': _selectedTrade,
        'urgency': _selectedUrgency,
        'access_notes': _accessNotesController.text.trim(),
      },
      jobId: widget.jobId,
      customerName: widget.customerName,
      postcode: widget.postcode,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBase : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Raise Reactive Attendance',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, size: 20.sp, color: theme.textMuted),
                  onPressed: () => Navigator.of(context).pop(_submitted),
                ),
              ],
            ),

            if (!_submitted) ...[
              SizedBox(height: 10.h),
              Text('Trade / Issue Type', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _selectedTrade,
                items: _trades.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 13.sp, color: theme.text)))).toList(),
                onChanged: (v) => setState(() => _selectedTrade = v ?? _selectedTrade),
                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
              ),
              SizedBox(height: 12.h),
              Text('Urgency Level', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                items: _urgencyLevels.map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(fontSize: 13.sp, color: theme.text)))).toList(),
                onChanged: (v) => setState(() => _selectedUrgency = v ?? _selectedUrgency),
                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
              ),
              SizedBox(height: 12.h),
              Text('Problem Description & Scope', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 6.h),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(fontSize: 13.sp, color: theme.text),
                decoration: InputDecoration(
                  hintText: 'Describe the issue discovered during visit...',
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 12.h),
              Text('Site Access & Notes', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 6.h),
              TextField(
                controller: _accessNotesController,
                maxLines: 2,
                style: TextStyle(fontSize: 13.sp, color: theme.text),
                decoration: InputDecoration(
                  hintText: 'e.g. Stopcock located under kitchen sink...',
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(height: 18.h, width: 18.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Submit Reactive Work Order', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
            ] else ...[
              SizedBox(height: 30.h),
              Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.badgeCheck, size: 48.sp, color: const Color(0xFF22C55E)),
                    SizedBox(height: 12.h),
                    Text(
                      'Reactive Attendance Dispatched',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: theme.text),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enquiry written to demo_customer_enquiries and linked to work order ${widget.jobId}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
