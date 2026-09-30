import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 4-Step PPM Lead Wizard matching Figma s-1907-2670 … s-1908-3056
class PpmLeadWizard extends StatefulWidget {
  const PpmLeadWizard({
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
      builder: (_) => PpmLeadWizard(
        jobId: jobId,
        customerName: customerName,
        postcode: postcode,
      ),
    );
  }

  @override
  State<PpmLeadWizard> createState() => _PpmLeadWizardState();
}

class _PpmLeadWizardState extends State<PpmLeadWizard> {
  int _currentStep =
      0; // 0: Equipment, 1: Frequency & Scope, 2: Customer, 3: Sent
  bool _isSubmitting = false;

  final Set<String> _selectedEquipment = {'Gas Boiler'};
  String _selectedFrequency = 'Annual (CP12 + Service)';
  final _notesController = TextEditingController();
  late final TextEditingController _customerNameController;
  late final TextEditingController _postcodeController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  static const List<String> _equipmentOptions = [
    'Gas Boiler',
    'Heat Pump',
    'Air Conditioning',
    'Unvented Cylinder',
    'Electrical Distribution Board (EICR)',
    'Commercial Catering Gas',
    'Ventilation / Extraction',
  ];

  static const List<String> _frequencyOptions = [
    'Annual (CP12 + Service)',
    'Bi-Annual (6 Months)',
    'Quarterly Check (3 Months)',
    'One-off Comprehensive Assessment',
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
    _notesController.dispose();
    _customerNameController.dispose();
    _postcodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitLead() async {
    setState(() => _isSubmitting = true);
    final details = {
      'equipment': _selectedEquipment.toList(),
      'frequency': _selectedFrequency,
      'notes': _notesController.text.trim(),
    };

    final success = await PillarClient.raiseEnquiry(
      category: 'PPM_INTEREST',
      description:
          'PPM Service Lead: ${_selectedEquipment.join(", ")} ($_selectedFrequency)',
      details: details,
      jobId: widget.jobId,
      customerName: _customerNameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim(),
      postcode: _postcodeController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          _currentStep = 3; // Sent screen
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
          // Drag Handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raise PPM Lead',
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

          // Progress indicator (if not sent)
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

          // Step Body
          Expanded(
            child: SingleChildScrollView(child: _buildStepContent(theme)),
          ),

          // Bottom CTAs
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
                            _currentStep == 2 ? 'Submit Lead' : 'Continue',
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
              'Select Covered Equipment',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'What assets at this property require recurring maintenance?',
              style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
            ),
            SizedBox(height: 12.h),
            ..._equipmentOptions.map((item) {
              final selected = _selectedEquipment.contains(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedEquipment.remove(item);
                    } else {
                      _selectedEquipment.add(item);
                    }
                  });
                },
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
                        selected ? LucideIcons.squareCheck : LucideIcons.square,
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
              'Frequency & Contract Scope',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 12.h),
            ..._frequencyOptions.map((opt) {
              final selected = _selectedFrequency == opt;
              return GestureDetector(
                onTap: () => setState(() => _selectedFrequency = opt),
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
                          opt,
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
            SizedBox(height: 14.h),
            Text(
              'Site Assessment & Access Notes',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                hintText:
                    'e.g. Access via side alley, boiler located in loft...',
                hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: theme.border),
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
              'Customer Contact & Confirmation',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            SizedBox(height: 12.h),
            _buildTextField(theme, 'Customer Name', _customerNameController),
            SizedBox(height: 10.h),
            _buildTextField(
              theme,
              'Phone Number',
              _phoneController,
              keyboard: TextInputType.phone,
            ),
            SizedBox(height: 10.h),
            _buildTextField(
              theme,
              'Email Address',
              _emailController,
              keyboard: TextInputType.emailAddress,
            ),
            SizedBox(height: 10.h),
            _buildTextField(theme, 'Postcode', _postcodeController),
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
                'PPM Lead Raised Successfully',
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
                  'The lead has been recorded in the Firestore spine (demo_customer_enquiries) and forwarded to the PPM intake queue.',
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

  Widget _buildTextField(
    DashboardTheme theme,
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: TextStyle(fontSize: 13.sp, color: theme.text),
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: theme.border),
            ),
          ),
        ),
      ],
    );
  }
}
