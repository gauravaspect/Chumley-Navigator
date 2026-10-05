import 'package:chumley_navigator/core/responsive/responsive_content.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_context_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_findings_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_notes_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_parts_used_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_photos_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_risk_assessment_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_sign_off_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_system_details_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_test_methods_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_visit_conclusion_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_visual_inspection_step.dart';
import 'package:chumley_navigator/screens/job_details/steps/ld_work_at_height_step.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  )
  onReportSubmitted;
  final String jobId;
  final String jobNumber;
  final FormDraftStore? store;

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
  final List<LdPartEntry> _parts = [];

  // ── Step 9 ──
  final Map<String, String> _capturedPhotos = {};

  // ── Step 10 ──
  late final TextEditingController _jobNotesController;
  late final TextEditingController _officeNotesController;
  bool _showSuggestedTopics = true;

  // ── Step 11 ──
  late final TextEditingController _findingsSummaryController;
  String? _findingSeverity;

  // ── Step 12 ──
  bool _confirmDeclaration = true;
  late final TextEditingController _engineerNameController;
  late final TextEditingController _signOffDateController;

  final SpeechToText _speech = SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;
  TextEditingController? _dictationController;
  String _dictationBaseText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _equipmentController = TextEditingController(
      text:
          'Standard ladders required. Double height limits on external fixture.',
    );
    _siteEntryController = TextEditingController(
      text:
          'Keys available with the site supervisor at the main front reception office.',
    );
    _riskAssessment = LdRiskAssessmentStep.riskAssessmentOptions.first;
    _leakContained = LdRiskAssessmentStep.leakContainedOptions.first;
    _ventilation = LdRiskAssessmentStep.ventilationOptions.first;
    _workAtHeight = LdWorkAtHeightStep.workAtHeightOptions.first;
    _accessMethod = LdWorkAtHeightStep.accessMethodOptions.first;
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
      LdPartEntry(
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
    final store = widget.store ?? FormDraftStore();
    if (widget.jobId.isEmpty) return;
    final step = await store.loadFurthestStep(widget.jobId);
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
    final store = widget.store ?? FormDraftStore();
    if (widget.jobId.isEmpty) return;
    await store.saveDraft(
      jobId: widget.jobId,
      step: _currentStep,
      answers: _answersMap(),
      photos: Map<String, String>.from(_capturedPhotos),
    );
  }

  @override
  void dispose() {
    _speech.stop();
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
      await widget.onReportSubmitted(
        _answersMap(),
        Map<String, String>.from(_capturedPhotos),
      );
      return;
    }
    _goToStep(_currentStep + 1);
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
  }

  Future<void> _toggleDictation(TextEditingController controller) async {
    if (_isListening && _dictationController == controller) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (_isListening) {
      await _speech.stop();
    }

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for voice input.'),
        ),
      );
      return;
    }

    if (!_speechReady) {
      await _initSpeech();
      if (!_speechReady) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition is not available on this device.',
            ),
          ),
        );
        return;
      }
    }

    _dictationController = controller;
    _dictationBaseText = controller.text;
    if (_dictationBaseText.isNotEmpty && !_dictationBaseText.endsWith(' ')) {
      _dictationBaseText = '$_dictationBaseText ';
    }

    if (mounted) setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        if (!mounted || _dictationController != controller) return;
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        controller.text = '$_dictationBaseText$words';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        if (result.finalResult) {
          _dictationBaseText = controller.text;
          if (_dictationBaseText.isNotEmpty &&
              !_dictationBaseText.endsWith(' ')) {
            _dictationBaseText = '$_dictationBaseText ';
          }
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        localeId: 'en_GB',
      ),
    );
  }

  bool _isListeningFor(TextEditingController controller) {
    return _isListening && _dictationController == controller;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: theme.isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ldBgTop, ldBgMid, ldBgBottom],
                stops: [0.0, 0.55, 1.0],
              ),
        color: theme.isDark ? theme.base : null,
      ),
      child: ResponsiveContent.form(
        child: Column(
          children: [
            _buildProgressHeader(theme),
            Expanded(child: _buildStepBody(theme)),
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  // ─── Progress header ─────────────────────────────────────────

  Widget _buildProgressHeader(DashboardTheme theme) {
    return Container(
      width: double.infinity,
      color: theme.isDark ? theme.base : ldBgTop,
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
                      decoration: BoxDecoration(
                        color: theme.surfaceDeep,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20.sp,
                        color: theme.text,
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
                        color: theme.text,
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
                                    : (theme.isDark
                                          ? theme.border
                                          : ldDotInactive),
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
                          color: theme.text,
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
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: theme.border),
        ],
      ),
    );
  }

  // ─── Step body ───────────────────────────────────────────────

  Widget _buildStepBody(DashboardTheme theme) {
    final isTestMethods = _currentStep == 5;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      physics: const BouncingScrollPhysics(),
      children: [
        if (isTestMethods) ...[
          const LdInfoBanner(
            'Up to 10 test methods. Each one carries its own before and after evidence slots.',
            ldBadgeFill,
          ),
          SizedBox(height: 12.h),
        ],
        Text(
          OnSiteWizard.stepCaptions[_currentStep],
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 17 / 12,
            color: theme.textMuted,
          ),
        ),
        SizedBox(height: 16.h),
        _buildStepContent(),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return LdRiskAssessmentStep(
          equipmentController: _equipmentController,
          siteEntryController: _siteEntryController,
          riskAssessment: _riskAssessment,
          onRiskAssessmentChanged: (v) => setState(() => _riskAssessment = v),
          competencyDeclaration: _competencyDeclaration,
          onCompetencyDeclarationChanged: (v) =>
              setState(() => _competencyDeclaration = v ?? false),
          leakContained: _leakContained,
          onLeakContainedChanged: (v) => setState(() => _leakContained = v),
          ventilation: _ventilation,
          onVentilationChanged: (v) => setState(() => _ventilation = v),
          customerDescRecorded: _customerDescRecorded,
          onCustomerDescRecordedChanged: (v) =>
              setState(() => _customerDescRecorded = v ?? false),
          systemIsolated: _systemIsolated,
          onSystemIsolatedChanged: (v) =>
              setState(() => _systemIsolated = v ?? false),
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 1:
        return LdWorkAtHeightStep(
          workAtHeight: _workAtHeight,
          onWorkAtHeightChanged: (v) => setState(() => _workAtHeight = v),
          accessMethod: _accessMethod,
          onAccessMethodChanged: (v) => setState(() => _accessMethod = v),
          equipmentInspection: _equipmentInspection,
          onEquipmentInspectionChanged: (v) =>
              setState(() => _equipmentInspection = v),
          exclusionZone: _exclusionZone,
          onExclusionZoneChanged: (v) => setState(() => _exclusionZone = v),
          weatherWindow: _weatherWindow,
          onWeatherWindowChanged: (v) => setState(() => _weatherWindow = v),
          loneWorking: _loneWorking,
          onLoneWorkingChanged: (v) => setState(() => _loneWorking = v),
          engineerTraining: _engineerTraining,
          onEngineerTrainingChanged: (v) =>
              setState(() => _engineerTraining = v),
          wahrDeclaration: _wahrDeclaration,
          onWahrDeclarationChanged: (v) =>
              setState(() => _wahrDeclaration = v ?? false),
        );
      case 2:
        return LdContextStep(
          leakType: _leakType,
          onLeakTypeChanged: (v) => setState(() => _leakType = v),
          premisesCategory: _premisesCategory,
          onPremisesCategoryChanged: (v) =>
              setState(() => _premisesCategory = v),
          leakBehaviour: _leakBehaviour,
          onLeakBehaviourChanged: (v) => setState(() => _leakBehaviour = v),
          waterClarity: _waterClarity,
          onWaterClarityChanged: (v) => setState(() => _waterClarity = v),
          waterTemperature: _waterTemperature,
          onWaterTemperatureChanged: (v) =>
              setState(() => _waterTemperature = v),
          premisesSubType: _premisesSubType,
          onPremisesSubTypeChanged: (v) => setState(() => _premisesSubType = v),
          propertyAge: _propertyAge,
          onPropertyAgeChanged: (v) => setState(() => _propertyAge = v),
          occupantPresent: _occupantPresent,
          onOccupantPresentChanged: (v) => setState(() => _occupantPresent = v),
          hasWaterMeter: _hasWaterMeter,
          onHasWaterMeterChanged: (v) => setState(() => _hasWaterMeter = v),
          insuranceClaim: _insuranceClaim,
          onInsuranceClaimChanged: (v) => setState(() => _insuranceClaim = v),
          claimRefController: _claimRefController,
          scopeNotesController: _scopeNotesController,
          scopeLimitations: _scopeLimitations,
          onScopeLimitationsChanged: (v) =>
              setState(() => _scopeLimitations = v),
          limitationsDescController: _limitationsDescController,
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 3:
        return LdSystemDetailsStep(
          plumbingSubSystem: _plumbingSubSystem,
          onPlumbingSubSystemChanged: (v) =>
              setState(() => _plumbingSubSystem = v),
          pipeMaterial: _pipeMaterial,
          onPipeMaterialChanged: (v) => setState(() => _pipeMaterial = v),
          pipeAge: _pipeAge,
          onPipeAgeChanged: (v) => setState(() => _pipeAge = v),
          lastMaintenance: _lastMaintenance,
          onLastMaintenanceChanged: (v) => setState(() => _lastMaintenance = v),
          previousLeaks: _previousLeaks,
          onPreviousLeaksChanged: (v) => setState(() => _previousLeaks = v),
          systemNotesController: _systemNotesController,
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 4:
        return LdVisualInspectionStep(
          visibleSigns: _visibleSigns,
          onVisibleSignsChanged: (v) => setState(() => _visibleSigns = v),
          affectedExtent: _affectedExtent,
          onAffectedExtentChanged: (v) => setState(() => _affectedExtent = v),
          leakActive: _leakActive,
          onLeakActiveChanged: (v) => setState(() => _leakActive = v),
          reportedPattern: _reportedPattern,
          onReportedPatternChanged: (v) => setState(() => _reportedPattern = v),
          firstImpressionController: _firstImpressionController,
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 5:
        return LdTestMethodsStep(
          testMethod: _testMethod,
          onTestMethodChanged: (v) => setState(() => _testMethod = v),
          equipmentUsed: _equipmentUsed,
          onEquipmentUsedChanged: (v) => setState(() => _equipmentUsed = v),
          equipmentCalibrated: _equipmentCalibrated,
          onEquipmentCalibratedChanged: (v) =>
              setState(() => _equipmentCalibrated = v),
          timeAllocated: _timeAllocated,
          onTimeAllocatedChanged: (v) => setState(() => _timeAllocated = v),
          thermalAnomalies: _thermalAnomalies,
          onThermalAnomaliesChanged: (v) =>
              setState(() => _thermalAnomalies = v),
          anomalyTempController: _anomalyTempController,
          dryTempController: _dryTempController,
          anomalyPattern: _anomalyPattern,
          onAnomalyPatternChanged: (v) => setState(() => _anomalyPattern = v),
          moistureVerified: _moistureVerified,
          onMoistureVerifiedChanged: (v) =>
              setState(() => _moistureVerified = v),
          testHelped: _testHelped,
          onTestHelpedChanged: (v) => setState(() => _testHelped = v),
          leakClassification: _leakClassification,
          onLeakClassificationChanged: (v) =>
              setState(() => _leakClassification = v),
          suspectedSource: _suspectedSource,
          onSuspectedSourceChanged: (v) => setState(() => _suspectedSource = v),
          testLocation: _testLocation,
          onTestLocationChanged: (v) => setState(() => _testLocation = v),
          testDescController: _testDescController,
          testBeforeSkipController: _testBeforeSkipController,
          testAfterSkipController: _testAfterSkipController,
          capturedPhotos: _capturedPhotos,
          onPhotoChanged: (key, path) {
            setState(() {
              if (path == null) {
                _capturedPhotos.remove(key);
              } else {
                _capturedPhotos[key] = path;
              }
            });
            _persistDraft();
          },
          onSnippetSnack: _snack,
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 6:
        return LdVisitConclusionStep(
          leakIdentified: _leakIdentified,
          onLeakIdentifiedChanged: (v) => setState(() => _leakIdentified = v),
          sourceDescController: _sourceDescController,
          repairedToday: _repairedToday,
          onRepairedTodayChanged: (v) => setState(() => _repairedToday = v),
          repairDescController: _repairDescController,
          repairMethod: _repairMethod,
          onRepairMethodChanged: (v) => setState(() => _repairMethod = v),
          repairTime: _repairTime,
          onRepairTimeChanged: (v) => setState(() => _repairTime = v),
          postRepairVerification: _postRepairVerification,
          onPostRepairVerificationChanged: (v) =>
              setState(() => _postRepairVerification = v),
          dryingDiscussed: _dryingDiscussed,
          onDryingDiscussedChanged: (v) => setState(() => _dryingDiscussed = v),
          dryingRequirements: _dryingRequirements,
          onDryingRequirementsChanged: (v) =>
              setState(() => _dryingRequirements = v),
          reinstatementDiscussed: _reinstatementDiscussed,
          onReinstatementDiscussedChanged: (v) =>
              setState(() => _reinstatementDiscussed = v),
          reinstatementScope: _reinstatementScope,
          onReinstatementScopeChanged: (v) =>
              setState(() => _reinstatementScope = v),
          conclusionNotesController: _conclusionNotesController,
          capturedPhotos: _capturedPhotos,
          onPhotoChanged: (key, path) {
            setState(() {
              if (path == null) {
                _capturedPhotos.remove(key);
              } else {
                _capturedPhotos[key] = path;
              }
            });
            _persistDraft();
          },
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 7:
        return LdPartsUsedStep(
          partsUsed: _partsUsed,
          parts: _parts,
          onPartsUsedChanged: (v) => setState(() {
            _partsUsed = v;
            if (v == 'Yes' && _parts.isEmpty) {
              _parts.add(LdPartEntry());
            }
          }),
          onAddPart: () => setState(() => _parts.add(LdPartEntry())),
          onPartCategoryChanged: (index, category) {
            setState(() => _parts[index].category.text = category ?? '');
          },
        );
      case 8:
        return LdPhotosStep(
          capturedPhotos: _capturedPhotos,
          onPhotoChanged: (key, path) {
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
      case 9:
        return LdNotesStep(
          jobNotesController: _jobNotesController,
          officeNotesController: _officeNotesController,
          showSuggestedTopics: _showSuggestedTopics,
          onToggleSuggestedTopics: () =>
              setState(() => _showSuggestedTopics = !_showSuggestedTopics),
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 10:
        return LdFindingsStep(
          findingsSummaryController: _findingsSummaryController,
          findingSeverity: _findingSeverity,
          onFindingSeverityChanged: (v) => setState(() => _findingSeverity = v),
          leakClassification: _leakClassification,
          onLeakClassificationChanged: (v) =>
              setState(() => _leakClassification = v),
          suspectedSource: _suspectedSource,
          onSuspectedSourceChanged: (v) => setState(() => _suspectedSource = v),
          onToggleDictation: _toggleDictation,
          isListeningFor: _isListeningFor,
        );
      case 11:
        return LdSignOffStep(
          stepTitles: OnSiteWizard.stepTitles,
          onGoToStep: _goToStep,
          confirmDeclaration: _confirmDeclaration,
          onConfirmDeclarationChanged: (v) =>
              setState(() => _confirmDeclaration = v),
          engineerNameController: _engineerNameController,
          signOffDateController: _signOffDateController,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Bottom bar ──────────────────────────────────────────────

  Widget _buildBottomBar(DashboardTheme theme) {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == OnSiteWizard.stepCount - 1;
    final leftLabel = isFirst ? 'Cancel' : 'Back';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  theme: theme,
                  label: leftLabel,
                  onTap: _onLeftAction,
                  style: _BtnStyle.secondary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _actionButton(
                  theme: theme,
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
              theme: theme,
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
    required DashboardTheme theme,
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
        fg = theme.isDark ? AppColors.accentBlue : AppColors.primaryBlue;
      case _BtnStyle.primary:
        bg = ldYellowCta;
        fg = AppColors.textDarkBlue;
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
}

enum _BtnStyle { secondary, ghost, primary }
