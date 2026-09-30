import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 4-Step PM Project Lead Wizard matching Figma s-1916-2811 … s-1917-3198
class PmLeadWizard extends StatefulWidget {
  const PmLeadWizard({
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
      builder: (_) => PmLeadWizard(
        jobId: jobId,
        customerName: customerName,
        postcode: postcode,
      ),
    );
  }

  @override
  State<PmLeadWizard> createState() => _PmLeadWizardState();
}

class _PmLeadWizardState extends State<PmLeadWizard> {
  int _currentStep =
      0; // 0: Project Type, 1: Scope & Measurements, 2: Budget/Customer, 3: Sent
  bool _isSubmitting = false;

  String _selectedProjectType = 'Bathroom Refurbishment';
  final _scopeController = TextEditingController();
  final _measurementsController = TextEditingController();
  String _selectedBudget = '£5,000 – £10,000';
  String _selectedTimeline = 'Within 1 Month';
  late final TextEditingController _customerNameController;
  late final TextEditingController _postcodeController;
  final _phoneController = TextEditingController();

  static const List<String> _projectTypes = [
    'Bathroom Refurbishment',
    'Kitchen Renovation',
    'Boiler & Full Heating Install',
    'Full Property Rewiring',
    'Commercial Works / Fit-out',
    'Roofing / Structural Repair',
  ];

  static const List<String> _budgetOptions = [
    'Under £5,000',
    '£5,000 – £10,000',
    '£10,000 – £25,000',
    '£25,000+',
  ];

  static const List<String> _timelineOptions = [
    'Immediate / Urgent',
    'Within 1 Month',
    '1 – 3 Months',
    'Flexible / Planning stage',
  ];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.customerName ?? '',
    );
    _postcodeController = TextEditingController(text: widget.postcode ?? '');
  }

  @override
  void dispose() {
    _scopeController.dispose();
    _measurementsController.dispose();
    _customerNameController.dispose();
    _postcodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitLead() async {
    setState(() => _isSubmitting = true);
    final details = {
      'project_type': _selectedProjectType,
      'scope_description': _scopeController.text.trim(),
      'measurements': _measurementsController.text.trim(),
      'budget_bracket': _selectedBudget,
      'timeline': _selectedTimeline,
    };

    final success = await PillarClient.raiseEnquiry(
      category: 'PM_INTEREST',
      description:
          'Project Management Lead: $_selectedProjectType ($_selectedBudget, $_selectedTimeline)',
      details: details,
      jobId: widget.jobId,
      customerName: _customerNameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      postcode: _postcodeController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          _currentStep = 3;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBase : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      child: Column(
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
                'Raise PM Lead',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, size: 20.sp, color: theme.textMuted),
                onPressed: () => Navigator.of(context).pop(_currentStep == 3),
              ),
            ],
          ),

          if (_currentStep < 3) ...[
            SizedBox(height: 6.h),
            Row(
              children: List.generate(3, (idx) {
                final active = idx <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryBlue
                          : theme.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),
          ],

          Expanded(
            child: SingleChildScrollView(child: _buildStepContent(theme)),
          ),

          if (_currentStep < 3)
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: theme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep--),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: theme.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _submitLead();
                            }
                          },
                    child: _isSubmitting
                        ? SizedBox(
                            height: 18.h,
                            width: 18.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentStep == 2 ? 'Submit PM Lead' : 'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(DashboardTheme theme) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Project Type',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'What major project does the client want estimated?',
              style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
            ),
            SizedBox(height: 12.h),
            ..._projectTypes.map((item) {
              final selected = _selectedProjectType == item;
              return GestureDetector(
                onTap: () => setState(() => _selectedProjectType = item),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue.withValues(alpha: 0.08)
                        : theme.surface,
                    border: Border.all(
                      color: selected ? AppColors.primaryBlue : theme.border,
                      width: selected ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? LucideIcons.circleDot : LucideIcons.circle,
                        size: 18.sp,
                        color: selected
                            ? AppColors.primaryBlue
                            : theme.textMuted,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: theme.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scope & Site Measurements',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Project Scope & Client Requirements',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _scopeController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                hintText:
                    'e.g. Complete rip-out of existing suite, new walk-in shower...',
                hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Measurements / Dimensions',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _measurementsController,
              maxLines: 2,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                hintText: 'e.g. 2.4m x 1.8m, ceiling height 2.5m...',
                hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget, Timeline & Contact',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Estimated Budget Bracket',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 6.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedBudget,
              items: _budgetOptions
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(
                        b,
                        style: TextStyle(fontSize: 13.sp, color: theme.text),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedBudget = v ?? _selectedBudget),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Timeline',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 6.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedTimeline,
              items: _timelineOptions
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: TextStyle(fontSize: 13.sp, color: theme.text),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedTimeline = v ?? _selectedTimeline),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Customer Name',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 4.h),
            TextField(
              controller: _customerNameController,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 4.h),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        );

      case 3:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.badgeCheck,
                  size: 40.sp,
                  color: const Color(0xFF22C55E),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'PM Project Lead Submitted',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.text,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Recorded in Firestore spine (demo_customer_enquiries) with category PM_INTEREST and origin NAV_APP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
