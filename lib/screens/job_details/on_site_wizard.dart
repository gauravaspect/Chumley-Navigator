import 'package:chumley_navigator/pillar/visit_local_store.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Leak Detection (LD) 12-step on-site form — aligned with the Navigator prototype.
class OnSiteWizard extends StatefulWidget {
  const OnSiteWizard({
    super.key,
    required this.onCancelToInTransit,
    required this.onReportSubmitted,
    required this.jobId,
    this.jobNumber = '',
    this.store,
  });

  final VoidCallback onCancelToInTransit;
  final Future<void> Function(
    Map<String, dynamic> answers,
    Map<String, String> photos,
  ) onReportSubmitted;
  final String jobId;
  final String jobNumber;
  final VisitLocalStore? store;

  static const stepCount = 12;

  static const stepTitles = [
    'Risk assessment',
    'Work at height',
    'Context',
    'System details',
    'Visual inspection',
    'Test methods',
    'Visit conclusion',
    'Parts used',
    'Photos',
    'Notes',
    'Findings',
    'Sign off',
  ];

  static const stepCaptions = [
    'Confirm the risk assessment and safety checks before you start.',
    'Any place where a fall could cause injury. No 2 m threshold.',
    'Leak type, property profile and claim context.',
    'The system under investigation.',
    'What was visible on arrival, before any tests.',
    'Each detection method deployed, with readings.',
    'Every visit records an outcome.',
    'Record anything consumed on this visit.',
    'Capture the evidence shots for this visit.',
    'Anything the structured fields did not capture.',
    'Seeded findings from tests and visit outcome.',
    'Check every step, then declare and submit.',
  ];

  @override
  State<OnSiteWizard> createState() => _OnSiteWizardState();
}

class _OnSiteWizardState extends State<OnSiteWizard> {
  int _currentStep = 0;

  // ── Step 1 ──
  late final TextEditingController _equipmentController;
  late final TextEditingController _siteEntryController;
  String? _riskAssessment;
  bool _competencyDeclaration = true;
  String? _leakContained;
  String? _ventilation;
  bool _customerDescRecorded = true;
  bool _systemIsolated = true;

  // ── Step 2 ──
  String? _workAtHeight;
  String? _accessMethod;
  String? _equipmentInspection;
  String? _exclusionZone;
  String? _weatherWindow;
  String? _loneWorking;
  String? _engineerTraining;
  bool _wahrDeclaration = true;

  // ── Step 3 ──
  String? _leakType;
  String? _premisesCategory;
  String? _leakBehaviour;
  String? _waterClarity;
  String? _waterTemperature;
  String? _premisesSubType;
  String? _propertyAge;
  String? _occupantPresent;
  String? _hasWaterMeter;
  String? _insuranceClaim;
  late final TextEditingController _claimRefController;
  late final TextEditingController _scopeNotesController;
  String? _scopeLimitations;
  late final TextEditingController _limitationsDescController;

  // ── Step 4 ──
  String? _plumbingSubSystem;
  String? _pipeMaterial;
  String? _pipeAge;
  String? _lastMaintenance;
  String? _previousLeaks;
  late final TextEditingController _systemNotesController;

  // ── Step 5 ──
  String? _visibleSigns;
  String? _affectedExtent;
  String? _leakActive;
  String? _reportedPattern;
  late final TextEditingController _firstImpressionController;

  // ── Step 6 ──
  String? _testMethod;
  String? _equipmentUsed;
  String? _equipmentCalibrated;
  String? _timeAllocated;
  String? _thermalAnomalies;
  late final TextEditingController _anomalyTempController;
  late final TextEditingController _dryTempController;
  String? _anomalyPattern;
  String? _moistureVerified;
  String? _testHelped;
  String? _leakClassification;
  String? _suspectedSource;
  String? _testLocation;
  late final TextEditingController _testDescController;
  late final TextEditingController _testBeforeSkipController;
  late final TextEditingController _testAfterSkipController;

  // ── Step 7 ──
  String? _leakIdentified;
  late final TextEditingController _sourceDescController;
  String? _repairedToday;
  late final TextEditingController _repairDescController;
  String? _repairMethod;
  String? _repairTime;
  String? _postRepairVerification;
  String? _dryingDiscussed;
  String? _dryingRequirements;
  String? _reinstatementDiscussed;
  String? _reinstatementScope;
  late final TextEditingController _conclusionNotesController;

  // ── Step 8 ──
  String? _partsUsed;
  final List<_PartEntry> _parts = [];

  // ── Step 9 ──
  final Map<String, String> _capturedPhotos = {};

  // ── Step 10 ──
  late final TextEditingController _jobNotesController;
  late final TextEditingController _officeNotesController;
  bool _showSuggestedTopics = true;

  static const _jobNotesSuggestedTopics = [
    'Customer description of leak recorded; affected area photographed as first reported',
    'System isolated or pressure-tested to confirm the leak is active before detection',
    'Detection method(s) selected based on suspected leak type and substrate',
    'Thermal imaging scan performed with representative load applied',
    'Acoustic trace run with pipework under live pressure',
    'Tracer gas introduced at low pressure where other methods are inconclusive',
    'Moisture profile taken across affected surfaces to corroborate source',
    'Confirmed leak source photographed with detection method visible in frame',
    'Proposed access route photographed and annotated for the repair team',
    'Report issued with findings, detection method, and recommended access/repair',
  ];

  // ── Step 11 ──
  late final TextEditingController _findingsSummaryController;
  String? _findingSeverity;

  // ── Step 12 ──
  bool _confirmDeclaration = true;
  late final TextEditingController _engineerNameController;
  late final TextEditingController _signOffDateController;

  static const _riskAssessmentOptions = [
    'Yes - risk assessment completed, standard controls in place',
    'Yes - risk assessment completed, additional controls in place (note below)',
    'Yes - risk assessment identifies low-medium risk, work proceeds with controls',
    'STOP - risk cannot be safely controlled today, work not commenced',
  ];

  static const _leakContainedOptions = [
    'Contained',
    'Active flow - isolate first',
    'STOP - electrics compromised, isolate circuit',
  ];

  static const _ventilationOptions = [
    'Adequate',
    'Restricted - use acoustic or thermal instead',
    'N/A - not using tracer gas',
  ];

  static const _workAtHeightOptions = [
    'Yes - work at height in scope today',
    'No - task is ground-level only',
  ];

  static const _accessMethodOptions = [
    'Avoid - drone / pole camera (no person at height)',
    'Prevent - MEWP / scaffold with edge protection',
    'Minimise - ladder with three points of contact',
  ];

  @override
  void initState() {
    super.initState();
    _equipmentController = TextEditingController(
      text:
          'Standard ladders required. Double height limits on external fixture.',
    );
    _siteEntryController = TextEditingController(
      text:
          'Keys available with the site supervisor at the main front reception office.',
    );
    _riskAssessment = _riskAssessmentOptions.first;
    _leakContained = _leakContainedOptions.first;
    _ventilation = _ventilationOptions.first;
    _workAtHeight = _workAtHeightOptions.first;
    _accessMethod = _accessMethodOptions.first;
    _equipmentInspection = 'Within 6 months - certificate on person or vehicle';
    _exclusionZone = 'Established - pedestrian barrier and signage';
    _weatherWindow = 'Dry, calm - within tolerance';
    _loneWorking = 'Alone - lone-worker check-in protocol active';
    _engineerTraining = 'Current - IPAF (MEWP)';

    _claimRefController = TextEditingController(text: '98123218');
    _scopeNotesController = TextEditingController(
      text:
          'Kitchen sink cupboard damp patch, worsens when mixer tap runs. Prior leak repaired 2022.',
    );
    _limitationsDescController = TextEditingController(
      text:
          'Tenant declined second-floor bathroom access; loft needs scaffold tower.',
    );
    _leakType = 'Plumbing';
    _premisesCategory = 'Domestic';
    _leakBehaviour = 'Worse when a fixture is running (tap, shower, appliance)';
    _waterClarity = 'Clear / clean - typical of fresh supply';
    _waterTemperature = 'Ambient / cold - typical of cold supply or external';
    _premisesSubType = 'Owner-occupied (single household)';
    _propertyAge = '1945-1980 - modern (cavity wall era)';
    _occupantPresent = 'Yes - occupant present and briefed';
    _hasWaterMeter = 'Yes - water meter present and accessible';
    _insuranceClaim = 'Yes - customer is claiming on insurance';
    _scopeLimitations = 'Yes - limitations recorded below';

    _plumbingSubSystem = 'Cold mains supply (incoming and distribution)';
    _pipeMaterial = 'Copper';
    _pipeAge = '20-40 yrs';
    _lastMaintenance = 'Within 12 months';
    _previousLeaks = 'Yes - previous leak in same area (repeat issue)';
    _systemNotesController = TextEditingController(
      text:
          'Recent kitchen refit; cold-main route under hallway; prior leak near same run.',
    );

    _visibleSigns = 'Wet patch / surface dampness (no active drip)';
    _affectedExtent = 'Moderate (0.5-2 m2)';
    _leakActive = 'Yes - active wetness, no visible drip';
    _reportedPattern = 'Continuous - present at all times';
    _firstImpressionController = TextEditingController(
      text:
          'Cupboard base is saturated but no active drip. Staining runs toward the hallway threshold, suggesting a run under the floor rather than a fitting above.',
    );

    _testMethod = 'Thermal imaging';
    _equipmentUsed = 'FLIR C5 / C3 / E-series';
    _equipmentCalibrated = 'Yes - calibration in date and working today';
    _timeAllocated = '30-60 minutes';
    _thermalAnomalies = 'Yes - anomalies identified';
    _anomalyTempController = TextEditingController(text: '14.2');
    _dryTempController = TextEditingController(text: '19.8');
    _anomalyPattern = 'Cooler in a linear pattern matching a pipe run';
    _moistureVerified = 'Yes - moisture meter confirmed the anomaly';
    _testHelped = 'Yes - narrowed the search significantly';
    _leakClassification = 'Active leak - behind surface';
    _suspectedSource = 'Cold mains';
    _testLocation = 'Kitchen';
    _testDescController = TextEditingController(
      text:
          'Thermal scan of kitchen and hallway; strongest anomaly under hallway boards.',
    );
    _testBeforeSkipController = TextEditingController();
    _testAfterSkipController = TextEditingController();

    _leakIdentified = 'Yes - definitive source identified';
    _sourceDescController = TextEditingController(
      text: 'Cold-main pinhole under hallway floorboards near kitchen doorway.',
    );
    _repairedToday = 'Yes - full repair completed + tested';
    _repairDescController = TextEditingController(
      text:
          'Isolated supply, lifted boards, cut out section, fitted 15 mm compression coupler, reinstated boards.',
    );
    _repairMethod = 'Joint re-make (compression / push-fit)';
    _repairTime = '30-60 minutes';
    _postRepairVerification = 'Pressure test passed - no further loss';
    _dryingDiscussed = 'Yes - drying requirements discussed';
    _dryingRequirements =
        'Wet substrate / saturated finishes - drying contractor recommended';
    _reinstatementDiscussed = 'Yes - reinstatement requirements discussed';
    _reinstatementScope = 'Finishes damaged - full make-good required';
    _conclusionNotesController = TextEditingController(
      text:
          'Source found and repaired. Pressure test passed. Drying and make-good recommended.',
    );

    _partsUsed = 'Yes';
    _parts.add(
      _PartEntry(
        category: 'Consumable',
        description: 'Compression coupler, 15 mm',
        ref: '67238',
        qty: '1',
      ),
    );

    _jobNotesController = TextEditingController(
      text:
          'Tenant concerned about hallway damp. Thermal image confirmed cool linear run. Kept hallway clear for drying.',
    );
    _officeNotesController = TextEditingController(
      text: 'Request drying quote callback. Flag previous 2022 leak on file.',
    );

    _findingsSummaryController = TextEditingController(
      text:
          'Active cold-mains pinhole under hallway; repaired with compression coupler; pressure test passed.',
    );
    _findingSeverity = 'Medium';

    _engineerNameController = TextEditingController(text: 'Marcus Bell');
    _signOffDateController = TextEditingController(text: '5 Aug 2026, 15:20');
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
  }

  Future<void> _restoreDraft() async {
    final store = widget.store;
    if (store == null || widget.jobId.isEmpty) return;
    final step = await store.loadStep(widget.jobId);
    final photos = await store.loadPhotos(widget.jobId);
    final answers = await store.loadAnswers(widget.jobId);
    if (!mounted) return;
    setState(() {
      if (step > 0) _currentStep = step.clamp(0, OnSiteWizard.stepCount - 1);
      _capturedPhotos
        ..clear()
        ..addAll(photos);
      if (answers['job_notes'] is String) {
        _jobNotesController.text = answers['job_notes'] as String;
      }
    });
  }

  Map<String, dynamic> _answersMap() => {
        'form': 'leak_detection',
        'risk_assessment': _riskAssessment,
        'work_at_height': _workAtHeight,
        'leak_type': _leakType,
        'leak_identified': _leakIdentified,
        'repaired_today': _repairedToday,
        'visit_conclusion': _leakIdentified,
        'job_notes': _jobNotesController.text,
        'engineer_name': _engineerNameController.text,
        'job_number': widget.jobNumber,
      };

  Future<void> _persistDraft() async {
    final store = widget.store;
    if (store == null || widget.jobId.isEmpty) return;
    await store.saveStep(widget.jobId, _currentStep);
    await store.saveAnswers(widget.jobId, _answersMap());
    await store.savePhotos(
      widget.jobId,
      Map<String, String>.from(_capturedPhotos),
    );
  }

  @override
  void dispose() {
    _equipmentController.dispose();
    _siteEntryController.dispose();
    _claimRefController.dispose();
    _scopeNotesController.dispose();
    _limitationsDescController.dispose();
    _systemNotesController.dispose();
    _firstImpressionController.dispose();
    _anomalyTempController.dispose();
    _dryTempController.dispose();
    _testDescController.dispose();
    _testBeforeSkipController.dispose();
    _testAfterSkipController.dispose();
    _sourceDescController.dispose();
    _repairDescController.dispose();
    _conclusionNotesController.dispose();
    for (final part in _parts) {
      part.dispose();
    }
    _jobNotesController.dispose();
    _officeNotesController.dispose();
    _findingsSummaryController.dispose();
    _engineerNameController.dispose();
    _signOffDateController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    final next = step.clamp(0, OnSiteWizard.stepCount - 1);
    if (next == _currentStep) return;
    setState(() => _currentStep = next);
    _persistDraft();
  }

  void _onLeftAction() {
    if (_currentStep == 0) {
      widget.onCancelToInTransit();
      return;
    }
    _goToStep(_currentStep - 1);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Future<void> _onSaveDraft() async {
    await _persistDraft();
    if (!mounted) return;
    _snack('Draft saved on this device');
  }

  Future<void> _onNext() async {
    if (_currentStep >= OnSiteWizard.stepCount - 1) {
      await _persistDraft();
      await widget.onReportSubmitted(_answersMap(), Map<String, String>.from(_capturedPhotos));
      return;
    }
    _goToStep(_currentStep + 1);
  }

  // Prototype palette
  static const _bgTop = Color(0xFFF4F9FF);
  static const _bgMid = Color(0xFFEDF4FE);
  static const _bgBottom = Color(0xFFE2ECFA);
  static const _textPrimary = Color(0xFF0B1F3A);
  static const _textSecondary = Color(0xFF5A6B85);
  static const _textCaption = Color(0xFF0B1F3A);
  static const _fieldFill = Color(0xFFE9EDF5);
  static const _fieldBorder = Color(0xFFE2E7F0);
  static const _dotInactive = Color(0xFFD8E6FC);
  static const _badgeFill = Color(0xFFD8E6FC);
  static const _yellowCta = Color(0xFFFFF23D);
  static const _greenCheck = Color(0xFF15803D);
  static const _backCircle = Color(0xFFE9EDF5);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgMid, _bgBottom],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        children: [
          _buildProgressHeader(),
          Expanded(child: _buildStepBody()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─── Progress header ─────────────────────────────────────────

  Widget _buildProgressHeader() {
    return Container(
      width: double.infinity,
      color: _bgTop,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
            child: SizedBox(
              height: 50.h,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onLeftAction,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: const BoxDecoration(
                        color: _backCircle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20.sp,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.jobNumber.isNotEmpty
                          ? widget.jobNumber
                          : 'Work order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 23 / 17,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 12.h),
            child: Column(
              children: [
                Row(
                  children: List.generate(OnSiteWizard.stepCount, (i) {
                    final isActive = i == _currentStep;
                    final isDone = i < _currentStep;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _goToStep(i),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 32.h,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: isActive ? 24.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: isActive || isDone
                                    ? AppColors.primaryBlue
                                    : _dotInactive,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        OnSiteWizard.stepTitles[_currentStep],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          height: 19 / 13,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Step ${_currentStep + 1} of ${OnSiteWizard.stepCount}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        height: 19 / 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: _fieldBorder),
        ],
      ),
    );
  }

  // ─── Step body ───────────────────────────────────────────────

  Widget _buildStepBody() {
    final isTestMethods = _currentStep == 5;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      physics: const BouncingScrollPhysics(),
      children: [
        if (isTestMethods) ...[
          _infoBanner(
            'Up to 10 test methods. Each one carries its own before and after evidence slots.',
            _badgeFill,
          ),
          SizedBox(height: 12.h),
        ],
        Text(
          OnSiteWizard.stepCaptions[_currentStep],
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 17 / 12,
            color: _textCaption,
          ),
        ),
        SizedBox(height: 16.h),
        ..._stepChildren(),
      ],
    );
  }

  List<Widget> _stepChildren() {
    switch (_currentStep) {
      case 0:
        return _step1();
      case 1:
        return _step2();
      case 2:
        return _step3();
      case 3:
        return _step4();
      case 4:
        return _step5();
      case 5:
        return _step6();
      case 6:
        return _step7();
      case 7:
        return _step8();
      case 8:
        return _step9();
      case 9:
        return _step10();
      case 10:
        return _step11();
      case 11:
        return _step12();
      default:
        return [];
    }
  }

  List<Widget> _step1() => [
    _sectionCard(
      icon: LucideIcons.key500,
      title: 'Access',
      subtitle: 'Confirm the access equipment and how you got on site.',
      children: [
        _labeled(
          'Equipment *',
          _textField(_equipmentController, 'Equipment notes…', maxLines: 3),
          icon: LucideIcons.toolbox500,
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Site entry *',
          _textField(_siteEntryController, 'Site entry notes…', maxLines: 3),
          icon: LucideIcons.key500,
        ),
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      icon: LucideIcons.shieldCheck,
      title: 'On-site risk assessment',
      subtitle:
          'Confirm the on-site risk assessment is complete before you start work',
      children: [
        _labeled(
          'Has an on-site risk assessment been completed?',
          _dropdown(
            value: _riskAssessment,
            items: _riskAssessmentOptions,
            onChanged: (v) => setState(() => _riskAssessment = v),
          ),
        ),
        SizedBox(height: 12.h),
        _declarationTile(
          checked: _competencyDeclaration,
          onChanged: (v) => setState(() => _competencyDeclaration = v ?? false),
          text:
              'I confirm I am a competent person for this trade, I hold current public liability insurance, and I have completed the on-site risk assessment above. This declaration is recorded against my engineer ID and forms part of the contract evidence for this visit.',
        ),
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      icon: LucideIcons.triangleAlert,
      title: 'HSE gatekeeper checks',
      subtitle: 'Trade-specific stop/go checks for this work type',
      children: [
        _chipGroup(
          label: 'Leak contained - no electrical risk from water ingress',
          hint: 'High risk',
          options: _leakContainedOptions,
          value: _leakContained,
          onChanged: (v) => setState(() => _leakContained = v),
        ),
        SizedBox(height: 14.h),
        _chipGroup(
          label: 'Ventilation adequate for tracer gas use',
          hint: 'Medium risk',
          options: _ventilationOptions,
          value: _ventilation,
          onChanged: (v) => setState(() => _ventilation = v),
        ),
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      title: 'Before you start',
      children: [
        _checkRow(
          'Customer description of leak recorded, affected area photographed as first reported',
          _customerDescRecorded,
          (v) => setState(() => _customerDescRecorded = v ?? false),
        ),
        SizedBox(height: 8.h),
        _checkRow(
          'System isolated or pressure-tested to confirm the leak is active',
          _systemIsolated,
          (v) => setState(() => _systemIsolated = v ?? false),
        ),
      ],
    ),
  ];

  List<Widget> _step2() => [
    _infoBanner(
      'WAHR 2005 reminder. "Work at height" means any place where, if measures were not taken, a person could fall a distance liable to cause personal injury. The 2-metre threshold was repealed in 2005 - height alone is not the test.',
      const Color(0xFFFEF6E7),
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      icon: LucideIcons.shieldCheck,
      title: 'Work at height - pre-work',
      subtitle:
          'Confirm whether this visit involves work where a fall could cause injury',
      children: [
        _labeled(
          'Will today’s task involve work where a fall could cause injury?',
          _dropdown(
            value: _workAtHeight,
            items: _workAtHeightOptions,
            onChanged: (v) => setState(() => _workAtHeight = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Access method (avoid, prevent, minimise)',
          _dropdown(
            value: _accessMethod,
            items: _accessMethodOptions,
            onChanged: (v) => setState(() => _accessMethod = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Equipment inspection currency',
          _dropdown(
            value: _equipmentInspection,
            items: const [
              'Within 6 months - certificate on person or vehicle',
              'Overdue - STOP until inspected',
              'N/A - no height access equipment in use',
            ],
            onChanged: (v) => setState(() => _equipmentInspection = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Falling-objects exclusion zone (WAHR s.9)',
          _dropdown(
            value: _exclusionZone,
            items: const [
              'Established - pedestrian barrier and signage',
              'Not required - no public exposure',
              'Unable to establish - STOP',
            ],
            onChanged: (v) => setState(() => _exclusionZone = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Weather and working window',
          _dropdown(
            value: _weatherWindow,
            items: const [
              'Dry, calm - within tolerance',
              'Marginal - proceed with caution',
              'Unsafe - postpone',
            ],
            onChanged: (v) => setState(() => _weatherWindow = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Lone working',
          _dropdown(
            value: _loneWorking,
            items: const [
              'Alone - lone-worker check-in protocol active',
              'Paired / supervised',
              'STOP - lone working not permitted for this task',
            ],
            onChanged: (v) => setState(() => _loneWorking = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Engineer training currency (IPAF / PASMA / harness)',
          _dropdown(
            value: _engineerTraining,
            items: const [
              'Current - IPAF (MEWP)',
              'Current - PASMA',
              'Current - harness / rescue',
              'Expired - STOP',
            ],
            onChanged: (v) => setState(() => _engineerTraining = v),
          ),
        ),
        SizedBox(height: 12.h),
        _declarationTile(
          checked: _wahrDeclaration,
          onChanged: (v) => setState(() => _wahrDeclaration = v ?? false),
          text:
              'I confirm I am trained and competent for the access method recorded above, my equipment is in inspection date, the rescue and exclusion arrangements are in place, and the work-at-height controls are appropriate to today\'s task. This declaration is recorded against my engineer ID under WAHR 2005.',
        ),
      ],
    ),
  ];

  List<Widget> _step3() => [
    _sectionCard(
      icon: LucideIcons.droplet,
      title: 'Context + property profile',
      isRequired: true,
      subtitle:
          'Capture the leak type, property profile and insurance-claim context before starting the investigation.',
      children: [
        _labeled(
          'Type of leak detection *',
          _dropdown(
            value: _leakType,
            items: const [
              'Plumbing',
              'Central heating',
              'Drainage',
              'Roof / external',
            ],
            onChanged: (v) => setState(() => _leakType = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Premises category *',
          _dropdown(
            value: _premisesCategory,
            items: const ['Domestic', 'Commercial', 'Communal / MDU'],
            onChanged: (v) => setState(() => _premisesCategory = v),
          ),
        ),
        SizedBox(height: 4.h),
        _hint('Broad category. The next question narrows it down.'),
        SizedBox(height: 12.h),
        _labeled(
          'Leak behaviour (triage) *',
          _dropdown(
            value: _leakBehaviour,
            items: const [
              'Worse when a fixture is running (tap, shower, appliance)',
              'Continuous regardless of fixtures',
              'Intermittent / weather-related',
              'Unknown / not observed',
            ],
            onChanged: (v) => setState(() => _leakBehaviour = v),
          ),
        ),
        _hint("Options are tailored to the leak detection type chosen above."),
        SizedBox(height: 12.h),
        _labeled(
          'Water clarity / contamination',
          _dropdown(
            value: _waterClarity,
            items: const [
              'Clear / clean - typical of fresh supply',
              'Discoloured / dirty',
              'Odorous / contaminated',
              'Not observed',
            ],
            onChanged: (v) => setState(() => _waterClarity = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Water temperature (where felt)',
          _dropdown(
            value: _waterTemperature,
            items: const [
              'Ambient / cold - typical of cold supply or external',
              'Warm / hot - heating or HW circuit',
              'Not felt',
            ],
            onChanged: (v) => setState(() => _waterTemperature = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Premises sub-type *',
          _dropdown(
            value: _premisesSubType,
            items: const [
              'Owner-occupied (single household)',
              'Tenanted / private rental',
              'Social housing',
              'Holiday let / short stay',
            ],
            onChanged: (v) => setState(() => _premisesSubType = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Property age band *',
          _dropdown(
            value: _propertyAge,
            items: const [
              'Pre-1919 - traditional',
              '1919-1944',
              '1945-1980 - modern (cavity wall era)',
              '1981-2000',
              'Post-2000',
            ],
            onChanged: (v) => setState(() => _propertyAge = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Occupant present during visit *',
          _dropdown(
            value: _occupantPresent,
            items: const [
              'Yes - occupant present and briefed',
              'No - vacant / keyholder only',
              'Partial - arrived mid-visit',
            ],
            onChanged: (v) => setState(() => _occupantPresent = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Does the property have a water meter? *',
          _dropdown(
            value: _hasWaterMeter,
            items: const [
              'Yes - water meter present and accessible',
              'Yes - present but inaccessible',
              'No meter',
              'Unknown',
            ],
            onChanged: (v) => setState(() => _hasWaterMeter = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Insurance claim related? *',
          _dropdown(
            value: _insuranceClaim,
            items: const [
              'Yes - customer is claiming on insurance',
              'No - not an insurance claim',
              'Unknown / not disclosed',
            ],
            onChanged: (v) => setState(() => _insuranceClaim = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Insurance claim reference (if available)',
          _textField(_claimRefController, 'Claim reference…'),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Scope notes - customer’s reported symptom + history',
          _textField(_scopeNotesController, 'Scope notes…', maxLines: 4),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Were there any scope or access limitations on this visit? *',
          _dropdown(
            value: _scopeLimitations,
            items: const [
              'Yes - limitations recorded below',
              'No - full access',
            ],
            onChanged: (v) => setState(() => _scopeLimitations = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Describe the scope / access limitations',
          _textField(_limitationsDescController, 'Limitations…', maxLines: 3),
        ),
      ],
    ),
  ];

  List<Widget> _step4() => [
    _sectionCard(
      icon: LucideIcons.wrench,
      title: 'System details (per leak type)',
      subtitle: 'Fields follow the leak type selected in Context.',
      isRequired: true,
      children: [
        _labeled(
          'Plumbing sub-system',
          _dropdown(
            value: _plumbingSubSystem,
            items: const [
              'Cold mains supply (incoming and distribution)',
              'Hot water circuit',
              'Central heating',
              'Waste / drainage',
            ],
            onChanged: (v) => setState(() => _plumbingSubSystem = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Supply pipework material (visible)',
          _dropdown(
            value: _pipeMaterial,
            items: const [
              'Copper',
              'Plastic (PEX / MDPE)',
              'Lead',
              'Mixed / unknown',
            ],
            onChanged: (v) => setState(() => _pipeMaterial = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Pipework age band',
          _dropdown(
            value: _pipeAge,
            items: const [
              '<10 yrs',
              '10-20 yrs',
              '20-40 yrs',
              '40+ yrs',
              'Unknown',
            ],
            onChanged: (v) => setState(() => _pipeAge = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Last known maintenance / service date *',
          _dropdown(
            value: _lastMaintenance,
            items: const [
              'Within 12 months',
              '1-3 years',
              'Over 3 years / unknown',
              'No record',
            ],
            onChanged: (v) => setState(() => _lastMaintenance = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Has this property had previous leaks in this area? *',
          _dropdown(
            value: _previousLeaks,
            items: const [
              'Yes - previous leak in same area (repeat issue)',
              'Yes - different area',
              'No known previous leaks',
              'Unknown',
            ],
            onChanged: (v) => setState(() => _previousLeaks = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'System details notes',
          _textField(_systemNotesController, 'System notes…', maxLines: 4),
        ),
        _hint(
          "Anything specific about the system that informs the investigation",
        ),
      ],
    ),
    SizedBox(height: 12.h),
    _infoBanner(
      "These fields follow the leak type chosen in step 3. Plumbing is selected, so the plumbing sub-system fields are shown.",
      _fieldFill,
    ),
  ];

  List<Widget> _step5() => [
    _sectionCard(
      icon: LucideIcons.eye,
      title: 'Visual inspection (baseline)',
      isRequired: true,
      children: [
        _labeled(
          'Visible signs of leak *',
          _dropdown(
            value: _visibleSigns,
            items: const [
              'Wet patch / surface dampness (no active drip)',
              'Active drip / running water',
              'Staining only (dry)',
              'No visible signs',
            ],
            onChanged: (v) => setState(() => _visibleSigns = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Affected area extent *',
          _dropdown(
            value: _affectedExtent,
            items: const [
              'Localised (<0.5 m2)',
              'Moderate (0.5-2 m2)',
              'Extensive (>2 m2)',
              'Multiple rooms',
            ],
            onChanged: (v) => setState(() => _affectedExtent = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Is the leak active during the visit? *',
          _dropdown(
            value: _leakActive,
            items: const [
              'Yes - active wetness, no visible drip',
              'Yes - visible active flow',
              'No - dry at time of visit',
              'Intermittent',
            ],
            onChanged: (v) => setState(() => _leakActive = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Customer’s reported leak pattern *',
          _dropdown(
            value: _reportedPattern,
            items: const [
              'Continuous - present at all times',
              'Only when fixtures used',
              'Weather / rain related',
              'Unknown',
            ],
            onChanged: (v) => setState(() => _reportedPattern = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Engineer’s first impression (voice-to-text)',
          _textField(
            _firstImpressionController,
            'What you noted on arrival…',
            maxLines: 4,
          ),
        ),
      ],
    ),
  ];

  List<Widget> _step6() => [
    _sectionCard(
      icon: LucideIcons.thermometer,
      title: 'Test methods & measurements',
      subtitle:
          'Record each test method deployed - equipment, calibration, readings and whether it located the source.',
      isRequired: true,
      children: [
        _labeled(
          'Test method deployed *',
          _dropdown(
            value: _testMethod,
            items: const [
              'Thermal imaging',
              'Acoustic listening',
              'Tracer gas',
              'Moisture mapping',
              'Visual + dye / leak-detection fluid',
            ],
            onChanged: (v) => setState(() => _testMethod = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Equipment used *',
          _dropdown(
            value: _equipmentUsed,
            items: const [
              'FLIR C5 / C3 / E-series',
              'Acoustic ground mic',
              'Tracer gas kit',
              'Protimeter / moisture meter',
            ],
            onChanged: (v) => setState(() => _equipmentUsed = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Equipment calibrated and in working order? *',
          _dropdown(
            value: _equipmentCalibrated,
            items: const [
              'Yes - calibration in date and working today',
              'No - proceed with caveat',
              'N/A',
            ],
            onChanged: (v) => setState(() => _equipmentCalibrated = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Time allocated to this test *',
          _dropdown(
            value: _timeAllocated,
            items: const [
              'Under 15 minutes',
              '15-30 minutes',
              '30-60 minutes',
              'Over 60 minutes',
            ],
            onChanged: (v) => setState(() => _timeAllocated = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Thermal anomalies identified?',
          _dropdown(
            value: _thermalAnomalies,
            items: const [
              'Yes - anomalies identified',
              'No anomalies',
              'Inconclusive',
            ],
            onChanged: (v) => setState(() => _thermalAnomalies = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Anomaly spot temperature (deg C)',
          _textField(_anomalyTempController, 'e.g. 14.2'),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Dry reference spot temperature (deg C)',
          _textField(_dryTempController, 'e.g. 19.8'),
        ),
        SizedBox(height: 4.h),
        _hint(
          "Same camera, on a DRY equivalent area. Delta-T is derived from the two.",
        ),
        SizedBox(height: 12.h),
        _infoBanner(
          "Delta-T 5.6 deg C, cooler than the dry reference - consistent with a cold-water leak.",
          _badgeFill,
        ),
        SizedBox(height: 4.h),
        _labeled(
          'Anomaly direction and pattern',
          _dropdown(
            value: _anomalyPattern,
            items: const [
              'Cooler in a linear pattern matching a pipe run',
              'Localised cool spot',
              'Warm anomaly',
              'Diffuse / unclear',
            ],
            onChanged: (v) => setState(() => _anomalyPattern = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Verified the thermal anomaly with a moisture meter?',
          _dropdown(
            value: _moistureVerified,
            items: const [
              'Yes - moisture meter confirmed the anomaly',
              'No - not verified',
              'N/A',
            ],
            onChanged: (v) => setState(() => _moistureVerified = v),
          ),
        ),
        SizedBox(height: 4.h),
        _hint("Thermal indicates, moisture confirms."),
        SizedBox(height: 12.h),
        _labeled(
          'Did this test help find the source of the leak? *',
          _dropdown(
            value: _testHelped,
            items: const [
              'Yes - narrowed the search significantly',
              'Partially helpful',
              'No - inconclusive',
            ],
            onChanged: (v) => setState(() => _testHelped = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Leak classification (for the seeded finding)',
          _dropdown(
            value: _leakClassification,
            items: const [
              'Active leak - behind surface',
              'Active leak - visible',
              'Historic / dried',
              'Condensation / non-leak',
            ],
            onChanged: (v) => setState(() => _leakClassification = v),
          ),
        ),
        SizedBox(height: 4.h),
        _hint(
          "Populates the finding's leak classification automatically. Pick what this test actually evidenced.",
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Suspected source (for the seeded finding)',
          _dropdown(
            value: _suspectedSource,
            items: const [
              'Cold mains',
              'Hot water',
              'Central heating',
              'Waste / drainage',
              'Roof / external',
            ],
            onChanged: (v) => setState(() => _suspectedSource = v),
          ),
        ),
        SizedBox(height: 4.h),
        _hint(
          "Engineer's interpretation based on what this test evidenced. Mirrors into the seeded finding.",
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Location indicated by this test',
          _dropdown(
            value: _testLocation,
            items: const [
              'Kitchen',
              'Bathroom',
              'Hallway',
              'Loft',
              'External',
              'Other - specify',
            ],
            onChanged: (v) => setState(() => _testLocation = v),
          ),
        ),
        SizedBox(height: 4.h),
        _hint(
          "Mirrors into the seeded finding's location. Use Other - specify for anywhere outside the list.",
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Brief test description (voice-to-text)',
          _textField(_testDescController, 'What was tested…', maxLines: 3),
        ),
        // SizedBox(height: 4.h),
        _hint("What was tested and what was found."),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _fieldFill,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Test evidence photos',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              _hint(
                "Mandatory per slot - either upload the photo or type a skip reason. The PDF collages these alongside this test's results.",
              ),
              SizedBox(height: 8.h),
              _photoSlot('Test BEFORE - equipment + setup', 'test_before'),
              SizedBox(height: 8.h),
              _labeled(
                'Skip reason (optional)',
                _textField(_testBeforeSkipController, 'Or type a skip reason…'),
              ),
              SizedBox(height: 12.h),
              _photoSlot(
                'Test AFTER - reading / result captured',
                'test_after',
              ),
              SizedBox(height: 8.h),
              _labeled(
                'Skip reason (optional)',
                _textField(_testAfterSkipController, 'Or type a skip reason…'),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _testCollapsedRow('Test 2', 'Visual + dye / leak-detection fluid'),
      ],
    ),
  ];

  List<Widget> _step7() => [
    _sectionCard(
      icon: LucideIcons.search,
      title: 'Visit conclusion + customer engagement',
      subtitle:
          'What was found, what was repaired, and what the customer was told.',
      children: [
        _labeled(
          'Has the leak been identified during this visit? *',
          _dropdown(
            value: _leakIdentified,
            items: const [
              'Yes - definitive source identified',
              'Partially - narrowed area',
              'No - further investigation required',
            ],
            onChanged: (v) => setState(() => _leakIdentified = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Identified source description',
          _textField(_sourceDescController, 'Source description…', maxLines: 3),
        ),
        _hint(
          "e.g. 'Kitchen ceiling NE corner - pinhole in hot supply elbow at first-floor bathroom basin trap'",
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Has the leak been repaired today? *',
          _dropdown(
            value: _repairedToday,
            items: const [
              'Yes - full repair completed + tested',
              'Temporary make-safe only',
              'No - repair deferred',
            ],
            onChanged: (v) => setState(() => _repairedToday = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Repair description (what was done)',
          _textField(_repairDescController, 'Repair summary…', maxLines: 3),
        ),
        _hint("Customer-facing summary."),
        SizedBox(height: 12.h),
        _labeled(
          'Repair method',
          _dropdown(
            value: _repairMethod,
            items: const [
              'Joint re-make (compression / push-fit)',
              'Pipe section replacement',
              'Clamp / temporary',
              'N/A - not repaired',
            ],
            onChanged: (v) => setState(() => _repairMethod = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Time allocated to the repair',
          _dropdown(
            value: _repairTime,
            items: const [
              'Under 15 minutes',
              '15-30 minutes',
              '30-60 minutes',
              'Over 60 minutes',
            ],
            onChanged: (v) => setState(() => _repairTime = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Post-repair verification',
          _dropdown(
            value: _postRepairVerification,
            items: const [
              'Pressure test passed - no further loss',
              'Visual check only',
              'Not verified',
              'N/A',
            ],
            onChanged: (v) => setState(() => _postRepairVerification = v),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: _fieldFill,
            borderRadius: BorderRadius.circular(6.r),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Repair evidence photos',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              _photoSlot('Leak location', 'repair_location'),
              SizedBox(height: 8.h),
              _photoSlot('Before repair (defect close-up)', 'repair_before'),
              SizedBox(height: 8.h),
              _photoSlot('After repair (completed fix)', 'repair_after'),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _labeled(
          'Discussed drying requirements with customer? *',
          _dropdown(
            value: _dryingDiscussed,
            items: const [
              'Yes - drying requirements discussed',
              'No - customer unavailable',
              'N/A - dry / no damage',
            ],
            onChanged: (v) => setState(() => _dryingDiscussed = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Drying requirements indicated *',
          _dropdown(
            value: _dryingRequirements,
            items: const [
              'Wet substrate / saturated finishes - drying contractor recommended',
              'Natural drying adequate',
              'None',
            ],
            onChanged: (v) => setState(() => _dryingRequirements = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Discussed reinstatement / making-good with customer? *',
          _dropdown(
            value: _reinstatementDiscussed,
            items: const [
              'Yes - reinstatement requirements discussed',
              'No',
              'N/A',
            ],
            onChanged: (v) => setState(() => _reinstatementDiscussed = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Reinstatement scope indicated *',
          _dropdown(
            value: _reinstatementScope,
            items: const [
              'Finishes damaged - full make-good required',
              'Minor making-good',
              'None',
            ],
            onChanged: (v) => setState(() => _reinstatementScope = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Conclusion notes / customer briefing summary',
          _textField(_conclusionNotesController, 'Final summary…', maxLines: 4),
        ),
        SizedBox(height: 4.h),
        _hint("Final summary - what the engineer told the customer plus anything for the loss adjuster or insurance file.")
      ],
    ),
  ];

  List<Widget> _step8() => [
    _sectionCard(
      icon: LucideIcons.wrench,
      title: 'Parts used',
      subtitle: 'Only if anything was consumed on site.',
      children: [
        _chipGroup(
          label: 'Have any parts been used during your visit?',
          options: const ['No', 'Yes'],
          value: _partsUsed,
          onChanged: (v) => setState(() {
            _partsUsed = v;
            if (v == 'Yes' && _parts.isEmpty) {
              _parts.add(_PartEntry());
            }
          }),
        ),
      ],
    ),
    if (_partsUsed == 'Yes') ...[
      for (var i = 0; i < _parts.length; i++) ...[
        SizedBox(height: 16.h),
        _partFormCard(index: i, part: _parts[i]),
      ],
      SizedBox(height: 16.h),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _parts.add(_PartEntry()));
          },
          borderRadius: BorderRadius.circular(12.r),
          child: VcrDashedBorder(
            color: const Color(0xFFC9DCF7),
            borderRadius: 12.r,
            child: Container(
              width: double.infinity,
              height: 48.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.plus,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add part',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ];

  Widget _partFormCard({required int index, required _PartEntry part}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _fieldBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PART ${index + 1}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              letterSpacing: 0.3,
              color: const Color(0xFF8A99B0),
            ),
          ),
          SizedBox(height: 14.h),
          _labeled(
            'Category',
            _dropdown(
              value: part.category.text.isEmpty ? null : part.category.text,
              items: const ['Consumable', 'Fitting', 'Pipe', 'Other'],
              onChanged: (v) {
                setState(() => part.category.text = v ?? '');
              },
            ),
          ),
          SizedBox(height: 12.h),
          _labeled(
            'Description',
            _textField(part.description, 'Part description…'),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _labeled(
                  'Part ref',
                  _textField(part.ref, 'Reference…'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _labeled(
                  'Qty',
                  _textField(part.qty, 'Qty'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _step9() {
    const slots = [
      ('Front of property *', 'front'),
      ('Affected area - overview *', 'overview'),
      ('Affected area - close-up *', 'closeup'),
      ('Water meter reading', 'meter'),
      ('Source - confirmed leak', 'source'),
      ('Test BEFORE - equipment + setup', 't_before'),
      ('Test AFTER - reading / result captured', 't_after'),
      ('Repair - completed work', 'repair'),
      ('Proposed access route (optional)', 'access_route'),
    ];
    final captured =
        slots.where((s) => (_capturedPhotos[s.$2] ?? '').isNotEmpty).length;

    return [
      _sectionCard(
        icon: LucideIcons.camera,
        title: 'Photographic evidence',
        // subtitle: '$captured of ${slots.length} captured',
        subtitle:
            '$captured of ${slots.length} attached. Required slots need a real photo.',
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _photoSlot(slots[i].$1, slots[i].$2),
          ],
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: null,
            icon: Icon(LucideIcons.plus, size: 16.sp),
            label: const Text('Add extra'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _step10() => [
    _sectionCard(
      icon: LucideIcons.check,
      title: 'Engineer Job Notes',
      subtitle:
          'Customer-facing narrative. Anything the structured fields did not capture: unique situations, observations, customer context. Skip if it is already in the structured data.',
      children: [
        _labeled(
          'Describe in plain language. Chumley AI will polish this when you compile.',
          _textField(_jobNotesController, 'Job notes…', maxLines: 6),
        ),
        SizedBox(height: 6.h),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _jobNotesController,
          builder: (context, value, _) {
            final count = value.text.trim().length;
            final met = count >= 50;
            return Text(
              '$count / 50 character minimum',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                height: 14 / 11,
                letterSpacing: 0.1,
                color: met ? const Color(0xFF15803D) : _textSecondary,
              ),
            );
          },
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () =>
              setState(() => _showSuggestedTopics = !_showSuggestedTopics),
          child: Row(
            children: [
              Icon(
                _showSuggestedTopics
                    ? LucideIcons.chevronUp
                    : LucideIcons.chevronDown,
                size: 16.sp,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 6.w),
              Text(
                _showSuggestedTopics
                    ? 'Hide suggested topics (${_jobNotesSuggestedTopics.length})'
                    : 'Show suggested topics (${_jobNotesSuggestedTopics.length})',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        if (_showSuggestedTopics) ...[
          SizedBox(height: 12.h),
          for (var i = 0; i < _jobNotesSuggestedTopics.length; i++) ...[
            if (i > 0) SizedBox(height: 9.h),
            _suggestedTopicRow(_jobNotesSuggestedTopics[i]),
          ],
        ],
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      icon: LucideIcons.building2,
      title: 'Office notes',
      subtitle:
          'For the office only. NOT shown to the customer. Use this to flag actions, callbacks and dispatch updates.',
      children: [
        _labeled(
          'Office notes (optional)',
          _textField(_officeNotesController, 'Internal notes…', maxLines: 4),
        ),
      ],
    ),
  ];

  Widget _suggestedTopicRow(String topic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7.h),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: Color(0xFFC9DCF7),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            topic,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 19 / 13,
              color: _textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _step11() => [
    _sectionCard(
      icon: LucideIcons.searchCheck,
      title: 'Findings',
      subtitle: 'Seeded from tests and visit conclusion. Edit if needed.',
      children: [
        _labeled(
          'Finding summary',
          _textField(
            _findingsSummaryController,
            'Finding summary…',
            maxLines: 4,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Severity',
          _dropdown(
            value: _findingSeverity,
            items: const ['Low', 'Medium', 'High', 'Critical'],
            onChanged: (v) => setState(() => _findingSeverity = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Classification',
          _dropdown(
            value: _leakClassification,
            items: const [
              'Active leak - behind surface',
              'Active leak - visible',
              'Historic / dried',
              'Condensation / non-leak',
            ],
            onChanged: (v) => setState(() => _leakClassification = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Suspected source',
          _dropdown(
            value: _suspectedSource,
            items: const [
              'Cold mains',
              'Hot water',
              'Central heating',
              'Waste / drainage',
              'Roof / external',
            ],
            onChanged: (v) => setState(() => _suspectedSource = v),
          ),
        ),
      ],
    ),
  ];

  List<Widget> _step12() => [
    _sectionCard(
      title: 'Review your report',
      subtitle: '10 of 10 complete',
      children: [
        for (var i = 0; i < 10; i++) ...[
          if (i > 0) Divider(height: 1, color: _fieldBorder),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              '${i + 1} — ${OnSiteWizard.stepTitles[i]}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            trailing: Icon(
              LucideIcons.chevronRight,
              size: 16.sp,
              color: _textCaption,
            ),
            onTap: () => _goToStep(i),
          ),
        ],
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      title: 'Declaration',
      children: [
        Text(
          'I, having exercised reasonable skill and care during this leak investigation, declare that the findings within this report reflect the source and character of the leak as established by the detection methods deployed on the date of investigation. Concealed services or leaks arising after this investigation are outside the scope of this report.',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            height: 19 / 13,
            color: _textSecondary,
          ),
        ),
        SizedBox(height: 14.h),
        Material(
          color: _confirmDeclaration ? AppColors.primaryBlue : _fieldFill,
          borderRadius: BorderRadius.circular(500.r),
          child: InkWell(
            onTap: () =>
                setState(() => _confirmDeclaration = !_confirmDeclaration),
            borderRadius: BorderRadius.circular(500.r),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 40.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500.r),
                border: _confirmDeclaration
                    ? null
                    : Border.all(color: _fieldBorder, width: 1),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_confirmDeclaration) ...[
                    Icon(
                      LucideIcons.check,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    'I confirm this declaration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: _confirmDeclaration
                          ? FontWeight.w500
                          : FontWeight.w400,
                      height: 19 / 13,
                      color: _confirmDeclaration
                          ? Colors.white
                          : _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: 16.h),
    _sectionCard(
      icon: LucideIcons.penLine,
      title: 'Sign off',
      children: [
        _labeled('Engineer name', _textField(_engineerNameController, 'Name')),
        SizedBox(height: 12.h),
        _labeled(
          'Date and time',
          _textField(_signOffDateController, 'Date and time'),
        ),
        SizedBox(height: 12.h),
        _labeled(
          'Engineer signature',
          Container(
            width: double.infinity,
            height: 100.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _fieldFill,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _fieldBorder, width: 1),
            ),
            child: Text(
              'Sign here',
              style: TextStyle(fontSize: 13.sp, color: _textCaption),
            ),
          ),
        ),
      ],
    ),
  ];

  // ─── Bottom bar ──────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == OnSiteWizard.stepCount - 1;
    final leftLabel = isFirst ? 'Cancel' : 'Back';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: leftLabel,
                  onTap: _onLeftAction,
                  style: _BtnStyle.secondary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _actionButton(
                  label: 'Save draft',
                  onTap: _onSaveDraft,
                  style: _BtnStyle.ghost,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              label: isLast ? 'Submit report' : 'Next',
              onTap: _onNext,
              style: _BtnStyle.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    required _BtnStyle style,
  }) {
    final Color bg;
    final Color fg;
    Border? border;
    switch (style) {
      case _BtnStyle.secondary:
        bg = AppColors.primaryBlue;
        fg = Colors.white;
      case _BtnStyle.ghost:
        bg = Colors.transparent;
        fg = AppColors.primaryBlue;
      case _BtnStyle.primary:
        bg = _yellowCta;
        fg = _textPrimary;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 34.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: border,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
    String? subtitle,
    IconData? icon,
    bool isRequired = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: _badgeFill,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 23 / 17,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        if (isRequired) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.fromLTRB(10.w, 5.h, 12.w, 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF6E7),
                              borderRadius: BorderRadius.circular(500.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Required',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          height: 15 / 11,
                          color: _textCaption,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _testCollapsedRow(String title, String method) {
    return InkWell(
      onTap: () => _snack('$title — expand coming soon'),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _fieldBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      height: 14 / 11,
                      letterSpacing: 0.1,
                      color: const Color(0xFF8A99B0),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              size: 18.sp,
              color: const Color(0xFF8A99B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner(String text, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _textPrimary, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 19 / 13,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 17 / 12,
        color: _textCaption,
      ),
    );
  }

  Widget _labeled(String label, Widget child, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: _badgeFill,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, size: 12.sp, color: AppColors.primaryBlue),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 16 / 12,
                  color: _textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    final isMulti = maxLines > 1;
    final field = TextField(
      controller: controller,
      maxLines: isMulti ? null : 1,
      minLines: isMulti ? 3 : 1,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: _textCaption),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: EdgeInsets.fromLTRB(
          14.w,
          isMulti ? 12.h : 13.h,
          isMulti ? 48.w : 14.w,
          isMulti ? 12.h : 13.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _fieldBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
        ),
      ),
    );

    if (!isMulti) return field;

    return SizedBox(
      height: 96.h,
      child: Stack(
        children: [
          Positioned.fill(child: field),
          Positioned(
            right: 6.w,
            bottom: 25.h,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD3DBE8), width: 1),
              ),
              child: Icon(
                LucideIcons.mic,
                size: 18.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final display = (value != null && items.contains(value)) ? value : null;

    return Material(
      color: _fieldFill,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => _openDropdownSheet(
          items: items,
          value: display,
          onChanged: onChanged,
        ),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 13.h, 10.w, 13.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _fieldBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  display ?? 'Select…',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 21 / 14,
                    color: display == null ? _textCaption : _textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _textCaption,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDropdownSheet({
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _fieldBorder,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 16.h),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: _fieldBorder),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == value;
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(item),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        title: Text(
                          item,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 21 / 14,
                            color: _textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.check,
                                size: 18.sp,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  Widget _chipGroup({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 16 / 12,
                  color: _textSecondary,
                ),
              ),
            ),
            if (hint != null)
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: _textCaption,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        ...options.asMap().entries.map((entry) {
          final i = entry.key;
          final opt = entry.value;
          final selected = opt == value;
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8.h),
            child: Material(
              color: selected ? AppColors.primaryBlue : _fieldFill,
              borderRadius: BorderRadius.circular(500.r),
              child: InkWell(
                onTap: () => onChanged(opt),
                borderRadius: BorderRadius.circular(500.r),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 40.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500.r),
                    border: selected
                        ? null
                        : Border.all(color: _fieldBorder, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selected) ...[
                        Icon(
                          LucideIcons.check,
                          size: 15.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Flexible(
                        child: Text(
                          opt,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selected
                                ? FontWeight.w500
                                : FontWeight.w400,
                            height: 19 / 13,
                            color: selected ? Colors.white : _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _declarationTile({
    required bool checked,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              margin: EdgeInsets.only(top: 1.h),
              decoration: BoxDecoration(
                color: checked ? _greenCheck : Colors.white,
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(color: checked ? _greenCheck : _fieldBorder),
              ),
              child: checked
                  ? Icon(LucideIcons.check, size: 13.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  height: 19 / 13,
                  color: _textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return _declarationTile(checked: value, onChanged: onChanged, text: label);
  }

  Widget _photoSlot(String label, String key) {
    return JobPhotoSlot(
      label: label,
      filePath: _capturedPhotos[key],
      onChanged: (path) {
        setState(() {
          if (path == null) {
            _capturedPhotos.remove(key);
          } else {
            _capturedPhotos[key] = path;
          }
        });
        _persistDraft();
      },
    );
  }
}

enum _BtnStyle { secondary, ghost, primary }

class _PartEntry {
  _PartEntry({
    String category = '',
    String description = '',
    String ref = '',
    String qty = '',
  })  : category = TextEditingController(text: category),
        description = TextEditingController(text: description),
        ref = TextEditingController(text: ref),
        qty = TextEditingController(text: qty);

  final TextEditingController category;
  final TextEditingController description;
  final TextEditingController ref;
  final TextEditingController qty;

  void dispose() {
    category.dispose();
    description.dispose();
    ref.dispose();
    qty.dispose();
  }
}
