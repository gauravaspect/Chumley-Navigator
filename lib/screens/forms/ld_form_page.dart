import 'dart:io';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/screens/forms/widgets/hse_risk_section.dart';
import 'package:chumley_navigator/screens/job_details/service/photo_pipeline_service.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 5-Step Unified Leak Detection Form Flow matching JOB_FLOW.md Section 5:
/// Step 1: Safety (Risk Assessment, PPE, Hazards)
/// Step 2: Context (Arrival details, Meter notes + Front of property & Water meter photos inline)
/// Step 3: Inspection (Visual inspection, Test methods + Overview & Close-up photos inline)
/// Step 4: Findings (Leak conclusions & recommendations + Proposed access route photo inline)
/// Step 5: Sign Off (Summary review, Declaration & Submit report)
class LdFormPage extends StatefulWidget {
  const LdFormPage({
    super.key,
    this.workOrderId = '',
    this.workOrderLabel = '',
    this.initialStep = 1,
  });

  final String workOrderId;
  final String workOrderLabel;
  final int initialStep;

  @override
  State<LdFormPage> createState() => _LdFormPageState();
}

class _LdFormPageState extends State<LdFormPage> {
  static const int _totalSteps = 5;
  int _currentStep = 1; // 1 to 5

  final _hse = HseRiskFormController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSaving = false;
  bool _isSubmitting = false;

  // ---------------------------------------------------------------------------
  // Form Field Controllers & State
  // ---------------------------------------------------------------------------

  // Step 2: Context
  final _arrivalNotesController = TextEditingController();
  final _meterReadingController = TextEditingController();
  String? _selectedOccupancyStatus = 'Occupied';
  static const _occupancyOptions = ['Occupied', 'Vacant', 'Tenanted', 'Under Renovation'];

  // Step 3: Inspection
  String? _selectedTestMethod = 'Acoustic / Listening Stick';
  static const _testMethodOptions = [
    'Acoustic / Listening Stick',
    'Thermal Imaging Camera',
    'Tracer Gas & Sensor',
    'Moisture Meter Probing',
    'Pressure Testing',
    'Visual Inspection Only',
  ];
  String? _selectedEquipmentUsed = 'Standard Acoustic Rod';
  final _inspectionFindingsController = TextEditingController();
  bool _waterSupplyShutOffTested = true;
  bool _pressureDropObserved = true;

  // Step 4: Findings & Recommendations
  String? _selectedLeakSource = 'Internal Hot/Cold Pipework';
  static const _leakSourceOptions = [
    'Internal Hot/Cold Pipework',
    'Central Heating Circuit',
    'Waste / Drainage Pipe',
    'Rainwater / Roof Ingress',
    'Groundwater / Rising Damp',
    'Sanitary Ware Seal Failure',
    'No Active Leak Detected',
  ];
  final _leakLocationNotesController = TextEditingController();
  final _recommendedActionsController = TextEditingController();
  bool _immediateRepairPossible = false;
  bool _furtherTraceAndAccessRequired = false;

  // Step 5: Sign Off & Declaration
  final _operativeDeclarationController = TextEditingController(text: 'I confirm all leak detection findings and measurements are accurate.');
  final _customerDeclarationController = TextEditingController();
  bool _operativeDeclarationAccepted = true;

  // Inline Photo Slots (Slot Name -> Local Compressed File Path)
  final Map<String, String> _photoSlots = {
    'Front of Property': '',
    'Water Meter Reading': '',
    'Affected Area Overview': '',
    'Affected Area Close-up': '',
    'Proposed Access Route': '',
  };

  // Photo Skips (Slot Name -> Reason)
  final Map<String, String> _photoSkips = {};

  final _scrollController = ScrollController();

  String get _workOrderDisplay {
    if (widget.workOrderLabel.trim().isNotEmpty) return widget.workOrderLabel.trim();
    if (widget.workOrderId.trim().isNotEmpty) return widget.workOrderId.trim();
    return '—';
  }

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(1, _totalSteps);
    _loadSavedDraft();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _arrivalNotesController.dispose();
    _meterReadingController.dispose();
    _inspectionFindingsController.dispose();
    _leakLocationNotesController.dispose();
    _recommendedActionsController.dispose();
    _operativeDeclarationController.dispose();
    _customerDeclarationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Draft Persistence & Resume Progress
  // ---------------------------------------------------------------------------

  Future<void> _loadSavedDraft() async {
    if (widget.workOrderId.isEmpty) return;
    try {
      final savedProgress = await PillarClient.getJobProgress(widget.workOrderId);
      final draft = await PillarClient.getFormAnswers(widget.workOrderId);

      if (mounted) {
        setState(() {
          if (widget.initialStep == 1 && savedProgress > 1 && savedProgress <= _totalSteps) {
            _currentStep = savedProgress;
          }

          if (draft.isNotEmpty) {
            // HSE
            if (draft['hse'] is Map) {
              final hseMap = draft['hse'] as Map;
              _hse.riskAssessment = hseMap['risk_assessment']?.toString();
              _hse.workAtHeight = hseMap['work_at_height']?.toString();
              _hse.safeIsolation = hseMap['safe_isolation']?.toString();
              _hse.clientBriefed = hseMap['client_briefed']?.toString();
              _hse.vulnerable = hseMap['vulnerable']?.toString();
              _hse.riskNoteController.text = hseMap['risk_notes']?.toString() ?? '';
            }

            // Context
            _arrivalNotesController.text = draft['arrival_notes'] ?? '';
            _meterReadingController.text = draft['meter_reading'] ?? '';
            _selectedOccupancyStatus = draft['occupancy_status'] ?? _selectedOccupancyStatus;

            // Inspection
            _selectedTestMethod = draft['test_method'] ?? _selectedTestMethod;
            _selectedEquipmentUsed = draft['equipment_used'] ?? _selectedEquipmentUsed;
            _inspectionFindingsController.text = draft['inspection_findings'] ?? '';
            _waterSupplyShutOffTested = draft['water_shutoff_tested'] ?? _waterSupplyShutOffTested;
            _pressureDropObserved = draft['pressure_drop_observed'] ?? _pressureDropObserved;

            // Findings
            _selectedLeakSource = draft['leak_source'] ?? _selectedLeakSource;
            _leakLocationNotesController.text = draft['leak_location_notes'] ?? '';
            _recommendedActionsController.text = draft['recommended_actions'] ?? '';
            _immediateRepairPossible = draft['immediate_repair_possible'] ?? _immediateRepairPossible;
            _furtherTraceAndAccessRequired = draft['further_trace_access_required'] ?? _furtherTraceAndAccessRequired;

            // Photos
            if (draft['photos'] is Map) {
              (draft['photos'] as Map).forEach((k, v) {
                if (_photoSlots.containsKey(k.toString())) {
                  _photoSlots[k.toString()] = (v ?? '').toString();
                }
              });
            }
          }
        });
      }
    } catch (e) {
      Log('Error loading LD draft: $e', name: 'LdFormPage');
    }
  }

  Map<String, dynamic> _collectFormData() {
    return {
      'hse': {
        'risk_assessment': _hse.riskAssessment,
        'work_at_height': _hse.workAtHeight,
        'safe_isolation': _hse.safeIsolation,
        'client_briefed': _hse.clientBriefed,
        'vulnerable': _hse.vulnerable,
        'risk_notes': _hse.riskNoteController.text.trim(),
      },
      'arrival_notes': _arrivalNotesController.text.trim(),
      'meter_reading': _meterReadingController.text.trim(),
      'occupancy_status': _selectedOccupancyStatus,
      'test_method': _selectedTestMethod,
      'equipment_used': _selectedEquipmentUsed,
      'inspection_findings': _inspectionFindingsController.text.trim(),
      'water_shutoff_tested': _waterSupplyShutOffTested,
      'pressure_drop_observed': _pressureDropObserved,
      'leak_source': _selectedLeakSource,
      'leak_location_notes': _leakLocationNotesController.text.trim(),
      'recommended_actions': _recommendedActionsController.text.trim(),
      'immediate_repair_possible': _immediateRepairPossible,
      'further_trace_access_required': _furtherTraceAndAccessRequired,
      'operative_declaration': _operativeDeclarationController.text.trim(),
      'customer_declaration': _customerDeclarationController.text.trim(),
      'photos': _photoSlots,
      'photo_skips': _photoSkips,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _saveDraftLocally() async {
    if (widget.workOrderId.isEmpty) return;
    setState(() => _isSaving = true);
    final data = _collectFormData();
    await PillarClient.saveFormAnswers(widget.workOrderId, data);
    await PillarClient.saveJobProgress(widget.workOrderId, _currentStep);
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Photo Handling with Downscaling Pipeline
  // ---------------------------------------------------------------------------

  Future<void> _pickPhotoForSlot(String slotName, ImageSource source) async {
    try {
      final xfile = await _imagePicker.pickImage(source: source);
      if (xfile != null) {
        // Downscale with PhotoPipelineService (~55KB, max 900px JPEG)
        final compressedPath = await PhotoPipelineService.processPhoto(xfile.path);
        if (mounted && compressedPath != null) {
          setState(() {
            _photoSlots[slotName] = compressedPath;
            _photoSkips.remove(slotName);
          });
          await _saveDraftLocally();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not attach photo: $e')),
        );
      }
    }
  }

  void _skipPhoto(String slotName) {
    showDialog(
      context: context,
      builder: (ctx) {
        final reasonCtrl = TextEditingController(text: 'Not accessible / Not applicable');
        return AlertDialog(
          title: Text('Skip Photo: $slotName'),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: 'Reason for skip'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _photoSkips[slotName] = reasonCtrl.text.trim();
                  _photoSlots[slotName] = '';
                });
                Navigator.pop(ctx);
                _saveDraftLocally();
              },
              child: const Text('Confirm Skip'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation & Submission
  // ---------------------------------------------------------------------------

  void _nextStep() async {
    await _saveDraftLocally();
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _previousStep() async {
    await _saveDraftLocally();
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    await _saveDraftLocally();

    final answers = _collectFormData();
    final compiledAnswers = <String, dynamic>{...answers};

    _photoSkips.forEach((slot, reason) {
      compiledAnswers['skip:$slot'] = reason;
    });

    final success = await PillarClient.submitSignOff(
      jobId: widget.workOrderId,
      reportSuffix: 'ld',
      reportType: 'LD',
      answers: compiledAnswers,
      photoSlots: _photoSlots,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leak Detection Report submitted successfully.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed. Please try again.')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI Builder
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);
        final isDark = theme.isDark;

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(theme, isDark),
                _buildStepperBar(theme, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: _buildCurrentStepContent(theme, isDark),
                  ),
                ),
                _buildBottomNav(theme, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(DashboardTheme theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        border: Border(bottom: BorderSide(color: theme.dashHeaderBorder, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CommandCentreBackButton(
                onTap: _previousStep,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leak Detection Flow',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.dashTitle,
                    ),
                  ),
                  Text(
                    'WO: $_workOrderDisplay',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (_isSaving)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              TextButton.icon(
                onPressed: _saveDraftLocally,
                icon: Icon(LucideIcons.save, size: 14.sp, color: AppColors.primaryBlue),
                label: Text(
                  'Save Draft',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBar(DashboardTheme theme, bool isDark) {
    final stepTitles = ['Safety', 'Context', 'Inspection', 'Findings', 'Sign Off'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of $_totalSteps: ${stepTitles[_currentStep - 1]}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.dashTitle,
                ),
              ),
              Text(
                '${((_currentStep / _totalSteps) * 100).round()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(_totalSteps, (index) {
              final stepNum = index + 1;
              final isDone = stepNum < _currentStep;
              final isCurrent = stepNum == _currentStep;

              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.successGreen
                        : isCurrent
                            ? AppColors.primaryBlue
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent(DashboardTheme theme, bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Safety(theme, isDark);
      case 2:
        return _buildStep2Context(theme, isDark);
      case 3:
        return _buildStep3Inspection(theme, isDark);
      case 4:
        return _buildStep4Findings(theme, isDark);
      case 5:
        return _buildStep5SignOff(theme, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 1: SAFETY (Risk Assessment & HSE)
  // ---------------------------------------------------------------------------
  Widget _buildStep1Safety(DashboardTheme theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Step 1: Point-of-Work Risk Assessment',
          subtitle: 'Verify site safety, PPE compliance, and potential hazards before starting.',
          icon: LucideIcons.shieldAlert,
          theme: theme,
        ),
        SizedBox(height: 12.h),
        HseRiskSection(
          controller: _hse,
          theme: theme,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: CONTEXT (Arrival & Meter + Inline Photos)
  // ---------------------------------------------------------------------------
  Widget _buildStep2Context(DashboardTheme theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Step 2: Context & Arrival Details',
          subtitle: 'Record property status, water meter readings, and capture initial site context.',
          icon: LucideIcons.house,
          theme: theme,
        ),
        SizedBox(height: 12.h),
        _buildCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'Property Occupancy Status',
                value: _selectedOccupancyStatus,
                items: _occupancyOptions,
                theme: theme,
                onChanged: (v) => setState(() => _selectedOccupancyStatus = v),
              ),
              SizedBox(height: 14.h),
              _buildTextField(
                controller: _meterReadingController,
                label: 'Water Meter Reading (m³ / Units)',
                hint: 'e.g. 04821.5',
                keyboardType: TextInputType.text,
                theme: theme,
              ),
              SizedBox(height: 14.h),
              _buildTextField(
                controller: _arrivalNotesController,
                label: 'Arrival & Site Access Notes',
                hint: 'Note any access constraints or occupant observations...',
                maxLines: 3,
                theme: theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildInlinePhotoSection(
          theme: theme,
          slotName: 'Front of Property',
          description: 'Capture a wide clear view of property exterior / entrance.',
        ),
        SizedBox(height: 12.h),
        _buildInlinePhotoSection(
          theme: theme,
          slotName: 'Water Meter Reading',
          description: 'Clear close-up showing dials/meter display.',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: INSPECTION (Visual & Test Methods + Inline Photos)
  // ---------------------------------------------------------------------------
  Widget _buildStep3Inspection(DashboardTheme theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Step 3: Visual Inspection & Test Methods',
          subtitle: 'Select test procedures used and record physical observation data.',
          icon: LucideIcons.scanLine,
          theme: theme,
        ),
        SizedBox(height: 12.h),
        _buildCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'Primary Test Method Applied',
                value: _selectedTestMethod,
                items: _testMethodOptions,
                theme: theme,
                onChanged: (v) => setState(() => _selectedTestMethod = v),
              ),
              SizedBox(height: 14.h),
              _buildSwitchRow(
                label: 'Internal stopcock shut-off tested',
                value: _waterSupplyShutOffTested,
                theme: theme,
                onChanged: (v) => setState(() => _waterSupplyShutOffTested = v),
              ),
              SizedBox(height: 10.h),
              _buildSwitchRow(
                label: 'Active pressure drop observed during test',
                value: _pressureDropObserved,
                theme: theme,
                onChanged: (v) => setState(() => _pressureDropObserved = v),
              ),
              SizedBox(height: 14.h),
              _buildTextField(
                controller: _inspectionFindingsController,
                label: 'Visual & Acoustic Findings',
                hint: 'Document damp patterns, acoustic spikes, thermal deltas...',
                maxLines: 4,
                theme: theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildInlinePhotoSection(
          theme: theme,
          slotName: 'Affected Area Overview',
          description: 'Wide view showing full extent of damp / staining / damage.',
        ),
        SizedBox(height: 12.h),
        _buildInlinePhotoSection(
          theme: theme,
          slotName: 'Affected Area Close-up',
          description: 'High detail close-up of suspected leak breakout point.',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: FINDINGS & RECOMMENDATIONS (+ Inline Access Photo)
  // ---------------------------------------------------------------------------
  Widget _buildStep4Findings(DashboardTheme theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Step 4: Leak Conclusion & Recommendations',
          subtitle: 'Define identified leak origin and specify recommended remedial works.',
          icon: LucideIcons.clipboardCheck,
          theme: theme,
        ),
        SizedBox(height: 12.h),
        _buildCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'Identified Leak Source Category',
                value: _selectedLeakSource,
                items: _leakSourceOptions,
                theme: theme,
                onChanged: (v) => setState(() => _selectedLeakSource = v),
              ),
              SizedBox(height: 14.h),
              _buildTextField(
                controller: _leakLocationNotesController,
                label: 'Precise Leak Location & Structural Context',
                hint: 'e.g. Under first-floor ensuite tiled floor adjacent to shower riser...',
                maxLines: 3,
                theme: theme,
              ),
              SizedBox(height: 14.h),
              _buildSwitchRow(
                label: 'Immediate repair feasible during visit',
                value: _immediateRepairPossible,
                theme: theme,
                onChanged: (v) => setState(() => _immediateRepairPossible = v),
              ),
              SizedBox(height: 10.h),
              _buildSwitchRow(
                label: 'Further Trace & Access required',
                value: _furtherTraceAndAccessRequired,
                theme: theme,
                onChanged: (v) => setState(() => _furtherTraceAndAccessRequired = v),
              ),
              SizedBox(height: 14.h),
              _buildTextField(
                controller: _recommendedActionsController,
                label: 'Scope of Recommended Next Steps',
                hint: 'List trace & access cuts, pipe replacements, drying setup...',
                maxLines: 3,
                theme: theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildInlinePhotoSection(
          theme: theme,
          slotName: 'Proposed Access Route',
          description: 'Photo evidencing proposed opening / floor cut / ceiling access point.',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 5: SIGN OFF & DECLARATION
  // ---------------------------------------------------------------------------
  Widget _buildStep5SignOff(DashboardTheme theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Step 5: Sign Off & Submission',
          subtitle: 'Review summary of evidence and submit final report.',
          icon: LucideIcons.badgeCheck,
          theme: theme,
        ),
        SizedBox(height: 12.h),
        // Evidence Summary Card
        _buildCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Evidence Summary',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 8.h),
              _buildSummaryRow('Leak Source:', _selectedLeakSource ?? '—', theme),
              _buildSummaryRow('Test Method:', _selectedTestMethod ?? '—', theme),
              _buildSummaryRow('Pressure Drop:', _pressureDropObserved ? 'Observed' : 'None', theme),
              _buildSummaryRow(
                'Photos Attached:',
                '${_photoSlots.values.where((p) => p.isNotEmpty).length} of ${_photoSlots.length}',
                theme,
              ),
              if (_photoSkips.isNotEmpty)
                _buildSummaryRow('Photos Skipped:', '${_photoSkips.length}', theme),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        // Declaration Card
        _buildCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineer Declaration',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'I confirm that the leak detection investigation has been conducted in accordance with company safety procedures and the findings recorded represent the true site conditions.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.textMuted,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              _buildSwitchRow(
                label: 'I certify these findings as accurate',
                value: _operativeDeclarationAccepted,
                theme: theme,
                onChanged: (v) => setState(() => _operativeDeclarationAccepted = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Inline Photo Widget with Previews & Skips
  // ---------------------------------------------------------------------------
  Widget _buildInlinePhotoSection({
    required DashboardTheme theme,
    required String slotName,
    required String description,
  }) {
    final photoPath = _photoSlots[slotName] ?? '';
    final skipReason = _photoSkips[slotName];
    final hasPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasPhoto
              ? AppColors.successGreen.withValues(alpha: 0.5)
              : (theme.isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: hasPhoto ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hasPhoto ? LucideIcons.circleCheck : LucideIcons.camera,
                    size: 16.sp,
                    color: hasPhoto ? AppColors.successGreen : AppColors.primaryBlue,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    slotName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.dashTitle,
                    ),
                  ),
                ],
              ),
              if (skipReason != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.streakOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Skipped',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.streakOrange, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
          ),
          SizedBox(height: 10.h),
          if (hasPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  Image.file(
                    File(photoPath),
                    height: 130.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _photoSlots[slotName] = '');
                        _saveDraftLocally();
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhotoForSlot(slotName, ImageSource.camera),
                    icon: Icon(LucideIcons.camera, size: 14.sp),
                    label: Text('Camera', style: TextStyle(fontSize: 11.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhotoForSlot(slotName, ImageSource.gallery),
                    icon: Icon(LucideIcons.image, size: 14.sp),
                    label: Text('Gallery', style: TextStyle(fontSize: 11.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () => _skipPhoto(slotName),
                  child: Text('Skip', style: TextStyle(fontSize: 11.sp, color: theme.textMuted)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNav(DashboardTheme theme, bool isDark) {
    final isLastStep = _currentStep == _totalSteps;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        border: Border(top: BorderSide(color: theme.dashHeaderBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Back', style: TextStyle(fontSize: 13.sp, color: theme.dashTitle)),
              ),
            ),
          if (_currentStep > 1) SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : (isLastStep ? _submitReport : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? AppColors.successGreen : AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLastStep ? 'Submit Report' : 'Next Step →',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Common UI Building Blocks
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required DashboardTheme theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
        ),
        SizedBox(width: 10.w),
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
                  color: theme.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required DashboardTheme theme, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.dashCardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required DashboardTheme theme,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField2<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            filled: true,
            fillColor: theme.isDark ? AppColors.darkSurfaceDeep : AppColors.lightSurfaceDeep,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: theme.isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: 12.sp, color: theme.dashTitle)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required DashboardTheme theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 12.sp, color: theme.dashTitle),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.sp, color: theme.textMuted),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            filled: true,
            fillColor: theme.isDark ? AppColors.darkSurfaceDeep : AppColors.lightSurfaceDeep,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: theme.isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required DashboardTheme theme,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: theme.dashTitle),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: theme.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: theme.dashTitle,
            ),
          ),
        ],
      ),
    );
  }
}
