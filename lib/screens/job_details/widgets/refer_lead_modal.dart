import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modal for Refer and Earn lead submission (category REFERRAL)
class ReferLeadModal extends StatefulWidget {
  const ReferLeadModal({
    super.key,
    required this.jobId,
  });

  final String jobId;

  static Future<bool?> show(
    BuildContext context, {
    required String jobId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReferLeadModal(jobId: jobId),
    );
  }

  @override
  State<ReferLeadModal> createState() => _ReferLeadModalState();
}

class _ReferLeadModalState extends State<ReferLeadModal> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedService = 'Boiler Install / Replacement';
  bool _isSubmitting = false;
  bool _submitted = false;

  static const List<String> _services = [
    'Boiler Install / Replacement',
    'Bathroom Refurbishment',
    'Full House Rewiring',
    'Commercial Gas PPM',
    'Drainage Relining',
    'General Plumbing & Heating',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _postcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final success = await PillarClient.raiseEnquiry(
      category: 'REFERRAL',
      description: 'Customer Referral: $_selectedService for ${_nameController.text.trim()}',
      details: {
        'referred_service': _selectedService,
        'referral_notes': _notesController.text.trim(),
      },
      jobId: widget.jobId,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim(),
      postcode: _postcodeController.text.trim(),
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
                  'Refer & Earn Lead',
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
              Text('Referred Customer Name *', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 4.h),
              TextField(controller: _nameController, style: TextStyle(fontSize: 13.sp, color: theme.text), decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
              SizedBox(height: 10.h),
              Text('Contact Phone Number *', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 4.h),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, style: TextStyle(fontSize: 13.sp, color: theme.text), decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
              SizedBox(height: 10.h),
              Text('Postcode / Location', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 4.h),
              TextField(controller: _postcodeController, style: TextStyle(fontSize: 13.sp, color: theme.text), decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
              SizedBox(height: 10.h),
              Text('Service Required', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13.sp, color: theme.text)))).toList(),
                onChanged: (v) => setState(() => _selectedService = v ?? _selectedService),
                decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
              ),
              SizedBox(height: 10.h),
              Text('Referral Notes', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
              SizedBox(height: 4.h),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: TextStyle(fontSize: 13.sp, color: theme.text),
                decoration: InputDecoration(
                  hintText: 'e.g. Neighbor of current customer, wants quote next week...',
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
                    : Text('Submit Referral Lead', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
            ] else ...[
              SizedBox(height: 30.h),
              Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.badgeCheck, size: 48.sp, color: const Color(0xFF22C55E)),
                    SizedBox(height: 12.h),
                    Text(
                      'Referral Lead Logged',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: theme.text),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Saved to demo_customer_enquiries (REFERRAL). Your engineer referral reward will be credited once booked.',
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
