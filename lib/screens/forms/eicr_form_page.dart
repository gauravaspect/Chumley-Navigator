import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Electrical Installation Condition Report (EICR) — fields aligned with HTML preview.
class EicrFormPage extends StatefulWidget {
  const EicrFormPage({
    super.key,
    this.appointmentNumber = '',
    this.engineerName = '',
    this.postcode = '',
    this.subject = '',
  });

  final String appointmentNumber;
  final String engineerName;
  final String postcode;
  final String subject;

  @override
  State<EicrFormPage> createState() => _EicrFormPageState();
}

class _EicrFormPageState extends State<EicrFormPage>
    with SingleTickerProviderStateMixin {
  static const _accent = AppColors.primaryBlue;

  static const _tabs = [
    'Risk & HSE',
    'CPS & Report',
    'Installation',
    'Supply',
    'Circuits',
    'Sign-off',
  ];

  static const _riskAssessmentOptions = [
    'Yes - risk assessment completed, standard controls in place',
    'Yes - risk assessment completed, additional controls in place (note below)',
    'Yes - risk assessment identifies low-medium risk, work proceeds with controls',
    'STOP - risk cannot be safely controlled today, work not commenced',
  ];

  static const _workAtHeightOptions = [
    'Yes - work at height in scope today',
    'No - task is ground-level only',
  ];

  static const _safeIsolationOptions = [
    'Yes - locked off and proved dead',
    'Partial - supervised',
    'Not possible - STOP',
  ];

  static const _clientBriefedOptions = [
    'Briefed and consent given',
    'Unable to contact - proceed per instruction',
    'Refused - STOP',
  ];

  static const _vulnerableOptions = [
    'None present',
    'Present - arrangements made',
    'Present - STOP until arranged',
  ];

  static const _cpsSchemes = ['NICEIC', 'NAPIT', 'ECA', 'Stroma', 'Other'];
  static const _yesNo = ['Yes', 'No'];
  static const _yesNotApparent = ['Yes', 'Not apparent'];
  static const _yesNoFull = ['Yes', 'No - full inspection agreed'];
  static const _yesNoSimple = ['Yes', 'No'];

  static const _overcurrentTypes = ['MCCB', 'ACB', 'Fuse(s)', 'Other'];
  static const _spdTypes = ['T1', 'T2', 'T3', 'T1+T2', 'T2+T3', 'N/A'];
  static const _phases = ['1 (single)', '3 (three)'];
  static const _earthingArrangements = [
    'TN-S',
    'TN-C-S (PME)',
    'TN-C-S (PNB)',
    'TT',
    'TN-C',
    'IT',
  ];
  static const _natureOfSupplyOptions = [
    'Public LV network',
    'Private generator',
    'Dual (public + generator)',
    'Microgeneration tied to public',
  ];
  static const _meansOfEarthingOptions = [
    "Distributor's facility (TN-S / TN-C-S)",
    'Installation earth electrode (TT)',
  ];
  static const _conductorMaterials = [
    'Copper',
    'Aluminium',
    'Steel',
    'Other - specify',
  ];
  static const _csaOptions = [
    '1.0',
    '1.5',
    '2.5',
    '4',
    '6',
    '10',
    '16',
    '25',
    '35',
    '50',
    '70',
    '95',
    'Other - specify',
  ];
  static const _yesNoNa = ['Yes', 'No', 'N/A - not present'];
  static const _yesNoNaLps = ['Yes', 'No', 'N/A - no LPS present'];
  static const _poles = ['1', '2', '3', '4'];
  static const _currentRatings = [
    '3',
    '5',
    '6',
    '10',
    '13',
    '16',
    '20',
    '25',
    '32',
    '40',
    '45',
    '50',
    '63',
    '80',
    '100',
    '125',
    'Other - specify',
  ];
  static const _deviceKinds = [
    'Isolator / switch-disconnector',
    'Switch-fuse',
    'Circuit-breaker / MCCB',
    'RCD main switch',
    'Other - specify',
  ];

  static const _circuitDescriptions = [
    'Lighting',
    'Sockets - ring final',
    'Sockets - radial',
    'Cooker',
    'Shower',
    'Immersion heater',
    'Heating / boiler',
    'Smoke / heat alarms',
    'Outdoor / garage',
    'EV charger',
    'Submain',
    'Other',
  ];

  static const _wiringTypes = [
    'A - Thermoplastic insulated/sheathed cables',
    'B - Thermoplastic cables in metallic conduit',
    'C - Thermoplastic cables in non-metallic conduit',
    'D - Thermoplastic cables in metallic trunking',
    'E - Thermoplastic cables in non-metallic trunking',
    'F - Thermoplastic SWA cables',
    'G - Thermosetting SWA cables',
    'H - Mineral insulated cables',
    'Other - specify',
  ];

  static const _refMethods = [
    'A1 - Insulated conductors in conduit, thermally insulated wall',
    'A2 - Multicore cable in conduit, thermally insulated wall',
    'B1 - Insulated conductors in conduit on a wall',
    'B2 - Multicore cable in conduit on a wall',
    'C - Clipped direct on a wall or ceiling',
    'D1 - Cables direct in ground',
    'D2 - Cables in ducts in ground',
    'E - Single multicore cable in free air',
    'F - Multicore cables touching',
    'G - Multicore cables spaced',
    'Other - specify',
  ];

  static const _ocpdTypes = [
    'Type B (MCB)',
    'Type C (MCB)',
    'Type D (MCB)',
    'RCBO',
    'BS 88 fuse (HRC)',
    'BS 1361 fuse (cartridge)',
    'BS 3036 fuse (rewireable)',
    'BS 3871 Type 1',
    'BS 3871 Type 2',
    'BS 3871 Type 3',
    'MCCB (BS EN 60947-2)',
    'Other - specify',
  ];

  static const _breakingCapacity = [
    '1',
    '3',
    '4.5',
    '6',
    '10',
    '16',
    '25',
    '36',
    '50',
    'Other - specify',
  ];

  static const _continuityMethods = ['(R1 + R2)', 'R2 only', 'N/A'];
  static const _irVoltages = ['250 V', '500 V', '1000 V'];
  static const _polarityOptions = [
    'Correct',
    'Reversed - rectified',
    'Reversed - C1',
  ];
  static const _yesNoNaSimple = ['Yes', 'No', 'N/A'];

  static const _inspectionCodes = [
    '✓',
    'C1',
    'C2',
    'C3',
    'FI',
    'LIM',
    'N/A',
    'N/V',
  ];

  static const _section1Items = [
    '1.1 Distributor / supplier intake equipment - service cable, service head, distributor\'s earthing arrangement, meter tails, metering equipment and means of isolation (where present)',
    '1.2 Consumer\'s means of isolation (where present)',
    '1.3 Consumer\'s meter tails',
  ];

  static const _otherInspectionSections = [
    '2. Presence of adequate arrangements for other sources such as microgenerators',
    '3. Earthing and Bonding Arrangements',
    '4. Consumer Unit or Distribution Board',
    '5. Distribution / Final Circuits',
    '6. Location(s) Containing a Bath or Shower',
    '7. Other Part 7 Special Installations or Locations',
    '8. Prosumer\'s Low Voltage Electrical Installation(s)',
  ];

  static const _customerPresentOptions = [
    'Yes - customer on site',
    'No - customer not present',
  ];

  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  // Risk
  String? _riskAssessment;
  String? _workAtHeight;
  String? _safeIsolation;
  String? _clientBriefed;
  String? _vulnerable;
  final _riskNoteController = TextEditingController();

  // CPS & Report
  String? _cpsScheme;
  final _schemeRegController = TextEditingController();
  final _partPController = TextEditingController();
  bool _cpsConfirm = false;
  final _reportNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _inspectionDatesController = TextEditingController();
  final _issuerNameController = TextEditingController();
  final _issuerPositionController = TextEditingController();

  // Installation
  final _wiringAgeController = TextEditingController();
  String? _additions;
  String? _recordsAvailable;
  final _lastInspectionDateController = TextEditingController();
  final _extentController = TextEditingController();
  String? _limitationsAgreed;
  String? _operationalLimitations;
  final _agreedWithController = TextEditingController();
  final _bs7671Controller = TextEditingController();
  final _supplyPolarityController = TextEditingController();
  final _spdBsController = TextEditingController();
  final _spdTypeController = TextEditingController();
  final _spdRatedController = TextEditingController();
  final _spdBreakingController = TextEditingController();
  String? _mainOvercurrentType;
  final _mainOvercurrentRatingController = TextEditingController();
  final _mainOvercurrentBreakingController = TextEditingController();
  final _rcdMainBreakingController = TextEditingController();
  final _dbLocationController = TextEditingController();
  final _suppliedFromController = TextEditingController();
  final _zdbController = TextEditingController();
  final _ipfController = TextEditingController();
  final _distOcpdBsController = TextEditingController();
  final _distOcpdTypeController = TextEditingController();
  final _distOcpdRatingController = TextEditingController();
  String? _spdAtBoard;
  final _generalConditionController = TextEditingController();
  final _furtherInspectionController = TextEditingController();
  final _recommendationReasonsController = TextEditingController();
  final _inspectedByNameController = TextEditingController();
  final _inspectedByPositionController = TextEditingController();
  final _authorisedByNameController = TextEditingController();
  final _authorisedByPositionController = TextEditingController();
  final _instrumentsController = TextEditingController();

  // Supply
  final _nominalVoltageController = TextEditingController(text: '230');
  String? _numberOfPhases;
  final _frequencyController = TextEditingController(text: '50');
  final _zeController = TextEditingController();
  final _psccController = TextEditingController();
  final _pfcController = TextEditingController();
  String? _earthingArrangement;
  String? _natureOfSupply;
  String? _meansOfEarthing;
  final _maxDemandController = TextEditingController();
  String? _earthingMaterial;
  String? _earthingCsa;
  String? _earthingVerified;
  String? _bondingMaterial;
  String? _bondingCsa;
  String? _bondingVerified;
  String? _bondWater;
  String? _bondGas;
  String? _bondOil;
  String? _bondSteel;
  String? _bondLps;
  final _bondOtherController = TextEditingController();
  final _mainSwitchLocationController = TextEditingController();
  final _mainSwitchBsController = TextEditingController();
  String? _mainSwitchPoles;
  String? _mainSwitchCurrent;
  final _mainSwitchVoltageController = TextEditingController();
  String? _mainSwitchKind;

  // Circuits
  final List<_EicrCircuit> _circuits = [_EicrCircuit()];

  // Inspections
  final Map<String, String?> _section1Outcomes = {
    for (final i in _section1Items) i: null,
  };
  final Map<String, String?> _sectionOutcomes = {
    for (final s in _otherInspectionSections) s: null,
  };

  // Sign-off
  bool _partsUsed = false;
  final _officeNotesController = TextEditingController();
  final _signatureController = TextEditingController();
  String? _customerPresent;
  bool _declReg = false;
  bool _declBs7671 = false;
  bool _declPartP = false;
  final Map<String, String> _photos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
    if (widget.engineerName.isNotEmpty) {
      _inspectedByNameController.text = widget.engineerName;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    for (final c in [
      _riskNoteController,
      _schemeRegController,
      _partPController,
      _reportNumberController,
      _reasonController,
      _inspectionDatesController,
      _issuerNameController,
      _issuerPositionController,
      _wiringAgeController,
      _lastInspectionDateController,
      _extentController,
      _agreedWithController,
      _bs7671Controller,
      _supplyPolarityController,
      _spdBsController,
      _spdTypeController,
      _spdRatedController,
      _spdBreakingController,
      _mainOvercurrentRatingController,
      _mainOvercurrentBreakingController,
      _rcdMainBreakingController,
      _dbLocationController,
      _suppliedFromController,
      _zdbController,
      _ipfController,
      _distOcpdBsController,
      _distOcpdTypeController,
      _distOcpdRatingController,
      _generalConditionController,
      _furtherInspectionController,
      _recommendationReasonsController,
      _inspectedByNameController,
      _inspectedByPositionController,
      _authorisedByNameController,
      _authorisedByPositionController,
      _instrumentsController,
      _nominalVoltageController,
      _frequencyController,
      _zeController,
      _psccController,
      _pfcController,
      _maxDemandController,
      _bondOtherController,
      _mainSwitchLocationController,
      _mainSwitchBsController,
      _mainSwitchVoltageController,
      _officeNotesController,
      _signatureController,
    ]) {
      c.dispose();
    }
    for (final c in _circuits) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final raw =
        (_scrollController.offset / _scrollThreshold).clamp(0.0, 1.0);
    final progress = Curves.easeOutCubic.transform(raw);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  void _onCancel() => Navigator.of(context).maybePop(false);

  void _onSave() {
    if (_cpsScheme == null ||
        _schemeRegController.text.trim().isEmpty ||
        !_cpsConfirm) {
      setState(() => _tabController.index = 1);
      _snack('Competent Person Scheme registration and confirmation are required.', error: true);
      return;
    }
    if (_signatureController.text.trim().isEmpty ||
        !_declReg ||
        !_declBs7671 ||
        !_declPartP) {
      setState(() => _tabController.index = 5);
      _snack('Complete signature and competency declarations to submit.', error: true);
      return;
    }
    _snack('EICR form saved.');
    Navigator.of(context).pop(true);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontSize: 13.sp)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.errorText : _accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);
        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (context, _) => [
                          SliverToBoxAdapter(
                            child: SizedBox(height: _brandingExpandedHeight.h),
                          ),
                          SliverToBoxAdapter(child: _buildIntro(theme)),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _EicrTabBarDelegate(
                              theme: theme,
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: _accent,
                                unselectedLabelColor: theme.textMuted,
                                indicatorColor: _accent,
                                labelStyle: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [for (final t in _tabs) Tab(text: t)],
                              ),
                            ),
                          ),
                        ],
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRiskTab(theme),
                            _buildCpsTab(theme),
                            _buildInstallationTab(theme),
                            _buildSupplyTab(theme),
                            _buildCircuitsTab(theme),
                            _buildSignOffTab(theme),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AspectBranding(
                              progress: progress,
                              expandedHeight: _brandingExpandedHeight,
                              collapsedHeight: _brandingCollapsedHeight,
                              theme: theme,
                              hasBackButton: true,
                              title: Text(
                                'EICR Form',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: theme.textBody,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 12.h,
                        left: 16.w,
                        child: CommandCentreBackButton(onTap: _onCancel),
                      ),
                    ],
                  ),
                ),
                _buildFooter(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntro(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'EICR',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Electrical Installation Condition Report (EICR)',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.dashHeading,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'This Electrical Installation Condition Report records the periodic inspection and testing of the existing fixed electrical installation at the address overleaf.',
            style: TextStyle(fontSize: 12.sp, color: theme.dashMuted, height: 1.35),
          ),
          SizedBox(height: 10.h),
          _chip(theme, 'Appointment', widget.appointmentNumber),
          SizedBox(height: 6.h),
          _chip(theme, 'Property / postcode', widget.postcode),
          if (widget.subject.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _chip(theme, 'Subject', widget.subject),
          ],
        ],
      ),
    );
  }

  Widget _chip(DashboardTheme theme, String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: TextStyle(fontSize: 11.sp, color: theme.textMuted)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Property & installation details'),
        Text(
          'Property details will populate from the site record.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 16.h),
        _title(theme, 'On-site risk assessment'),
        _field(
          theme,
          'Has an on-site risk assessment been completed? *',
          _dd(theme, _riskAssessment, _riskAssessmentOptions, (v) => setState(() => _riskAssessment = v)),
        ),
        SizedBox(height: 12.h),
        _field(theme, 'Additional controls note', _tf(theme, _riskNoteController, 'Note (if required)…', maxLines: 3)),
        SizedBox(height: 16.h),
        _title(theme, 'Work at Height - pre-work'),
        _field(
          theme,
          'Will today\'s task involve work where a fall could cause injury? *',
          _dd(theme, _workAtHeight, _workAtHeightOptions, (v) => setState(() => _workAtHeight = v)),
        ),
        SizedBox(height: 16.h),
        _title(theme, 'HSE gatekeeper checks'),
        _field(
          theme,
          'Safe isolation procedure followed (High risk)',
          _dd(theme, _safeIsolation, _safeIsolationOptions, (v) => setState(() => _safeIsolation = v)),
        ),
        SizedBox(height: 12.h),
        _field(
          theme,
          'Client briefed on power interruption (High risk)',
          _dd(theme, _clientBriefed, _clientBriefedOptions, (v) => setState(() => _clientBriefed = v)),
        ),
        SizedBox(height: 12.h),
        _field(
          theme,
          'Vulnerable occupants considered (medical equipment, lifts) (High risk)',
          _dd(theme, _vulnerable, _vulnerableOptions, (v) => setState(() => _vulnerable = v)),
        ),
      ],
    );
  }

  Widget _buildCpsTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Competent Person Scheme registration'),
        Text(
          'Your Competent Person Scheme registration must be recorded before any test results.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        _field(theme, 'Competent Person Scheme *', _dd(theme, _cpsScheme, _cpsSchemes, (v) => setState(() => _cpsScheme = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Scheme registration number *', _tf(theme, _schemeRegController, 'Your enrolment / membership number')),
        SizedBox(height: 12.h),
        _field(theme, 'Part P registration number (dwellings)', _tf(theme, _partPController, 'Optional')),
        SizedBox(height: 12.h),
        _check(
          theme,
          _cpsConfirm,
          (v) => setState(() => _cpsConfirm = v ?? false),
          'I confirm my Competent Person Scheme registration is current and covers the work I am about to carry out on this installation. *',
        ),
        SizedBox(height: 16.h),
        _title(theme, 'Report details (Sections A & B)'),
        _field(theme, 'Report number', _tf(theme, _reportNumberController, 'Report number')),
        SizedBox(height: 12.h),
        _field(theme, 'Reason for producing this report (Section B)', _tf(theme, _reasonController, 'Reason…', maxLines: 2)),
        SizedBox(height: 12.h),
        _field(theme, 'Date(s) on which inspection and testing was carried out', _tf(theme, _inspectionDatesController, 'e.g. 03 Aug 2026')),
        SizedBox(height: 12.h),
        _field(theme, 'Issuer details - name', _tf(theme, _issuerNameController, 'Issuer name')),
        SizedBox(height: 12.h),
        _field(theme, 'Issuer details - position', _tf(theme, _issuerPositionController, 'Position')),
      ],
    );
  }

  Widget _buildInstallationTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Installation details (Section C)'),
        _field(theme, 'Estimated age of wiring system (years)', _tf(theme, _wiringAgeController, 'Years', keyboardType: TextInputType.number)),
        SizedBox(height: 12.h),
        _field(theme, 'Evidence of additions / alterations?', _dd(theme, _additions, _yesNotApparent, (v) => setState(() => _additions = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Installation records available? (Reg 651.1)', _dd(theme, _recordsAvailable, _yesNo, (v) => setState(() => _recordsAvailable = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Date of last inspection', _tf(theme, _lastInspectionDateController, 'Date')),
        SizedBox(height: 16.h),
        _title(theme, 'Extent & limitations of the inspection'),
        _field(theme, 'Extent of the installation covered by this report *', _tf(theme, _extentController, 'Extent…', maxLines: 3)),
        SizedBox(height: 12.h),
        _field(theme, 'Were any limitations to the inspection agreed with the client? (Reg 653.2) *', _dd(theme, _limitationsAgreed, _yesNoFull, (v) => setState(() => _limitationsAgreed = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Were there any operational limitations during the inspection? *', _dd(theme, _operationalLimitations, _yesNoSimple, (v) => setState(() => _operationalLimitations = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Agreed with (name / role)', _tf(theme, _agreedWithController, 'Name / role')),
        SizedBox(height: 12.h),
        _field(theme, 'Inspection carried out to BS 7671:2018 as amended to', _tf(theme, _bs7671Controller, 'e.g. A2:2022')),
        SizedBox(height: 16.h),
        _title(theme, 'Supply protective device (Section I)'),
        _field(theme, 'Confirmation of supply polarity', _tf(theme, _supplyPolarityController, 'Polarity')),
        SizedBox(height: 12.h),
        _field(theme, 'Supply protective device - BS (EN)', _tf(theme, _spdBsController, 'BS (EN)')),
        SizedBox(height: 12.h),
        _field(theme, 'Supply protective device - Type', _tf(theme, _spdTypeController, 'Type')),
        SizedBox(height: 12.h),
        _field(theme, 'Supply protective device - rated current (A)', _tf(theme, _spdRatedController, 'A', keyboardType: TextInputType.number)),
        SizedBox(height: 12.h),
        _field(theme, 'Supply protective device - breaking capacity (kA)', _tf(theme, _spdBreakingController, 'kA', keyboardType: TextInputType.number)),
        SizedBox(height: 16.h),
        _title(theme, 'Main switch device ratings (Section J)'),
        _field(theme, 'If overcurrent device - device type', _dd(theme, _mainOvercurrentType, _overcurrentTypes, (v) => setState(() => _mainOvercurrentType = v))),
        SizedBox(height: 12.h),
        _field(theme, 'If overcurrent device - rating / setting (A)', _tf(theme, _mainOvercurrentRatingController, 'A')),
        SizedBox(height: 12.h),
        _field(theme, 'If overcurrent device - breaking capacity (kA)', _tf(theme, _mainOvercurrentBreakingController, 'kA')),
        SizedBox(height: 12.h),
        _field(theme, 'If RCD main switch - breaking capacity (kA)', _tf(theme, _rcdMainBreakingController, 'kA')),
        SizedBox(height: 16.h),
        _title(theme, 'Distribution board details'),
        _field(theme, 'DB / CU location', _tf(theme, _dbLocationController, 'Location')),
        SizedBox(height: 12.h),
        _field(theme, 'Supplied from', _tf(theme, _suppliedFromController, 'Supplied from')),
        SizedBox(height: 12.h),
        _field(theme, 'Zdb at this board (Ω)', _tf(theme, _zdbController, 'Ω')),
        SizedBox(height: 12.h),
        _field(theme, 'Ipf at this board (kA)', _tf(theme, _ipfController, 'kA')),
        SizedBox(height: 12.h),
        _field(theme, 'Distribution circuit OCPD - BS (EN)', _tf(theme, _distOcpdBsController, 'BS (EN)')),
        SizedBox(height: 12.h),
        _field(theme, 'Distribution circuit OCPD - Type', _tf(theme, _distOcpdTypeController, 'Type')),
        SizedBox(height: 12.h),
        _field(theme, 'Distribution circuit OCPD - rating / setting (A)', _tf(theme, _distOcpdRatingController, 'A')),
        SizedBox(height: 12.h),
        _field(theme, 'SPD Type(s) at this board', _dd(theme, _spdAtBoard, _spdTypes, (v) => setState(() => _spdAtBoard = v))),
        SizedBox(height: 16.h),
        _title(theme, 'Summary & next inspection (Sections E & F)'),
        _field(theme, 'General condition of the installation (electrical safety)', _tf(theme, _generalConditionController, 'Condition…', maxLines: 3)),
        SizedBox(height: 12.h),
        _field(theme, 'Further inspection & testing recommended before', _tf(theme, _furtherInspectionController, 'Date / period')),
        SizedBox(height: 12.h),
        _field(theme, 'Reasons for the recommendation', _tf(theme, _recommendationReasonsController, 'Reasons…', maxLines: 2)),
        SizedBox(height: 16.h),
        _title(theme, 'Declaration details (Section G)'),
        _field(theme, 'Inspected & tested by - name', _tf(theme, _inspectedByNameController, 'Name')),
        SizedBox(height: 12.h),
        _field(theme, 'Inspected & tested by - position', _tf(theme, _inspectedByPositionController, 'Position')),
        SizedBox(height: 12.h),
        _field(theme, 'Report authorized for issue by - name', _tf(theme, _authorisedByNameController, 'Name')),
        SizedBox(height: 12.h),
        _field(theme, 'Report authorized for issue by - position', _tf(theme, _authorisedByPositionController, 'Position')),
        SizedBox(height: 12.h),
        _field(theme, 'Test instruments used (serial / asset numbers)', _tf(theme, _instrumentsController, 'Instruments…', maxLines: 2)),
      ],
    );
  }

  Widget _buildSupplyTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Supply characteristics (BS 7671 Appendix 6)'),
        Text('Supply 1', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: theme.text)),
        SizedBox(height: 10.h),
        _field(theme, 'Nominal voltage U₀ (V)', _tf(theme, _nominalVoltageController, 'Typical UK = 230 V')),
        SizedBox(height: 12.h),
        _field(theme, 'Number of phases', _dd(theme, _numberOfPhases, _phases, (v) => setState(() => _numberOfPhases = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Nominal frequency (Hz)', _tf(theme, _frequencyController, 'UK public LV = 50 Hz')),
        SizedBox(height: 12.h),
        _field(theme, 'External earth loop Ze (Ω)', _tf(theme, _zeController, 'Ω')),
        SizedBox(height: 12.h),
        _field(theme, 'Prospective short-circuit current (PSCC) (kA)', _tf(theme, _psccController, 'kA')),
        SizedBox(height: 12.h),
        _field(theme, 'Prospective fault current (PFC) (kA)', _tf(theme, _pfcController, 'kA')),
        SizedBox(height: 12.h),
        _field(theme, 'Earthing arrangement', _dd(theme, _earthingArrangement, _earthingArrangements, (v) => setState(() => _earthingArrangement = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Nature of supply', _dd(theme, _natureOfSupply, _natureOfSupplyOptions, (v) => setState(() => _natureOfSupply = v))),
        SizedBox(height: 16.h),
        _title(theme, 'Installation particulars - earthing, bonding & main switch (Section J)'),
        _field(theme, 'Means of earthing *', _dd(theme, _meansOfEarthing, _meansOfEarthingOptions, (v) => setState(() => _meansOfEarthing = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Maximum demand (load) (kVA / A)', _tf(theme, _maxDemandController, 'kVA / A')),
        SizedBox(height: 12.h),
        _field(theme, 'Earthing conductor - material *', _dd(theme, _earthingMaterial, _conductorMaterials, (v) => setState(() => _earthingMaterial = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Earthing conductor - csa *', _dd(theme, _earthingCsa, _csaOptions, (v) => setState(() => _earthingCsa = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Earthing conductor connection / continuity verified *', _dd(theme, _earthingVerified, _yesNo, (v) => setState(() => _earthingVerified = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main protective bonding - material *', _dd(theme, _bondingMaterial, _conductorMaterials, (v) => setState(() => _bondingMaterial = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main protective bonding - csa *', _dd(theme, _bondingCsa, _csaOptions, (v) => setState(() => _bondingCsa = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding connection / continuity verified *', _dd(theme, _bondingVerified, _yesNo, (v) => setState(() => _bondingVerified = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to water service *', _dd(theme, _bondWater, _yesNoNa, (v) => setState(() => _bondWater = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to gas service *', _dd(theme, _bondGas, _yesNoNa, (v) => setState(() => _bondGas = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to oil service *', _dd(theme, _bondOil, _yesNoNa, (v) => setState(() => _bondOil = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to structural steel *', _dd(theme, _bondSteel, _yesNoNa, (v) => setState(() => _bondSteel = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to lightning protection system *', _dd(theme, _bondLps, _yesNoNaLps, (v) => setState(() => _bondLps = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main bonding to other extraneous-conductive-parts', _tf(theme, _bondOtherController, 'Optional - specify')),
        SizedBox(height: 16.h),
        _title(theme, 'Main switch'),
        _field(theme, 'Main switch - location *', _tf(theme, _mainSwitchLocationController, 'Location')),
        SizedBox(height: 12.h),
        _field(theme, 'Main switch - BS (EN) *', _tf(theme, _mainSwitchBsController, 'BS (EN)')),
        SizedBox(height: 12.h),
        _field(theme, 'Main switch - number of poles *', _dd(theme, _mainSwitchPoles, _poles, (v) => setState(() => _mainSwitchPoles = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main switch - current rating *', _dd(theme, _mainSwitchCurrent, _currentRatings, (v) => setState(() => _mainSwitchCurrent = v))),
        SizedBox(height: 12.h),
        _field(theme, 'Main switch - voltage rating * (V)', _tf(theme, _mainSwitchVoltageController, 'V')),
        SizedBox(height: 12.h),
        _field(theme, 'Main switch - device kind *', _dd(theme, _mainSwitchKind, _deviceKinds, (v) => setState(() => _mainSwitchKind = v))),
      ],
    );
  }

  Widget _buildCircuitsTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Schedule of circuit details & test results'),
        Text(
          'Record the design and test results for every final circuit (BS 7671 Appendix 6).',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        for (var i = 0; i < _circuits.length; i++) _circuitCard(theme, i),
        TextButton.icon(
          onPressed: () => setState(() => _circuits.add(_EicrCircuit())),
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: Text('+ Add another circuit', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(foregroundColor: _accent),
        ),
      ],
    );
  }

  Widget _circuitCard(DashboardTheme theme, int i) {
    final c = _circuits[i];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Circuit ${i + 1}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: theme.text)),
              const Spacer(),
              if (_circuits.length > 1)
                IconButton(
                  onPressed: () => setState(() => _circuits.removeAt(i).dispose()),
                  icon: Icon(LucideIcons.trash2, size: 16.sp, color: AppColors.errorText),
                ),
            ],
          ),
          _field(theme, 'DB / CU reference *', _tf(theme, c.dbRef, 'DB ref')),
          SizedBox(height: 10.h),
          _field(theme, 'Circuit number (way) *', _tf(theme, c.way, 'Way')),
          SizedBox(height: 10.h),
          _field(theme, 'Circuit description *', _dd(theme, c.description, _circuitDescriptions, (v) => setState(() => c.description = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Type of wiring *', _dd(theme, c.wiring, _wiringTypes, (v) => setState(() => c.wiring = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Reference method (Table 4A2) *', _dd(theme, c.refMethod, _refMethods, (v) => setState(() => c.refMethod = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Number of points served', _tf(theme, c.points, 'Points', keyboardType: TextInputType.number)),
          SizedBox(height: 10.h),
          _field(theme, 'csa Live conductor *', _dd(theme, c.csaLive, _csaOptions, (v) => setState(() => c.csaLive = v))),
          SizedBox(height: 10.h),
          _field(theme, 'csa Neutral conductor *', _dd(theme, c.csaNeutral, _csaOptions, (v) => setState(() => c.csaNeutral = v))),
          SizedBox(height: 10.h),
          _field(theme, 'csa CPC *', _dd(theme, c.csaCpc, _csaOptions, (v) => setState(() => c.csaCpc = v))),
          SizedBox(height: 10.h),
          _field(theme, 'OCPD BS (EN) *', _tf(theme, c.ocpdBs, 'e.g. BS EN 60898')),
          SizedBox(height: 10.h),
          _field(theme, 'OCPD Type *', _dd(theme, c.ocpdType, _ocpdTypes, (v) => setState(() => c.ocpdType = v))),
          SizedBox(height: 10.h),
          _field(theme, 'OCPD rating *', _dd(theme, c.ocpdRating, _currentRatings, (v) => setState(() => c.ocpdRating = v))),
          SizedBox(height: 10.h),
          _field(theme, 'OCPD breaking capacity *', _dd(theme, c.ocpdBreaking, _breakingCapacity, (v) => setState(() => c.ocpdBreaking = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Maximum permitted Zs * (Ω)', _tf(theme, c.maxZs, 'From BS 7671 Chapter 41')),
          SizedBox(height: 10.h),
          _field(theme, 'RCD fitted on this circuit *', _dd(theme, c.rcdFitted, _yesNo, (v) => setState(() => c.rcdFitted = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Protective conductor continuity method *', _dd(theme, c.continuityMethod, _continuityMethods, (v) => setState(() => c.continuityMethod = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Protective conductor continuity reading * (Ω)', _tf(theme, c.continuityReading, 'Ω')),
          SizedBox(height: 10.h),
          _field(theme, 'IR test voltage *', _dd(theme, c.irVoltage, _irVoltages, (v) => setState(() => c.irVoltage = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Insulation resistance L-L (or L-N) * (MΩ)', _tf(theme, c.irLl, 'MΩ')),
          SizedBox(height: 10.h),
          _field(theme, 'Insulation resistance L-E * (MΩ)', _tf(theme, c.irLe, 'Min 1.0 MΩ')),
          SizedBox(height: 10.h),
          _field(theme, 'Insulation resistance N-E * (MΩ)', _tf(theme, c.irNe, 'Min 1.0 MΩ')),
          SizedBox(height: 10.h),
          _field(theme, 'Polarity *', _dd(theme, c.polarity, _polarityOptions, (v) => setState(() => c.polarity = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Maximum measured Zs * (Ω)', _tf(theme, c.measuredZs, 'Ω')),
          SizedBox(height: 10.h),
          _field(theme, 'AFDD fitted on this circuit *', _dd(theme, c.afdd, _yesNoNaSimple, (v) => setState(() => c.afdd = v))),
          SizedBox(height: 10.h),
          _field(theme, 'SPD fitted on or upstream of this circuit *', _dd(theme, c.spd, _yesNo, (v) => setState(() => c.spd = v))),
          SizedBox(height: 10.h),
          _field(theme, 'Remarks', _tf(theme, c.remarks, 'Remarks…', maxLines: 2)),
        ],
      ),
    );
  }

  Widget _buildSignOffTab(DashboardTheme theme) {
    final photos = [
      ('Distribution board - overall', 'Full DB with cover removed, all ways visible'),
      ('Distribution board - labelling', 'Close-up of circuit chart & engineer label'),
      ('Origin of supply', 'Cut-out, meter, and tails visible'),
      ('Defect(s) logged as observations', 'Per observation row - use 1 photo per C1/C2'),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _title(theme, 'Schedule of Inspections (Appendix 6)'),
        Text(
          'Walk every item and assign an outcome. Anything not ✓ or N/A creates an observation.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        Text('1. Intake Equipment (visual inspection only)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: theme.text)),
        SizedBox(height: 8.h),
        for (final item in _section1Items) ...[
          _field(theme, item, _dd(theme, _section1Outcomes[item], _inspectionCodes, (v) => setState(() => _section1Outcomes[item] = v))),
          SizedBox(height: 10.h),
        ],
        for (final section in _otherInspectionSections) ...[
          _field(
            theme,
            section,
            _dd(theme, _sectionOutcomes[section], _inspectionCodes, (v) => setState(() => _sectionOutcomes[section] = v)),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 8.h),
        _title(theme, 'Findings & observations'),
        OutlinedButton.icon(
          onPressed: () => _snack('Manual observations coming in a follow-up.'),
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add manual observation (not auto-flagged)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _accent,
            side: BorderSide(color: _accent.withValues(alpha: 0.5)),
          ),
        ),
        SizedBox(height: 16.h),
        _title(theme, 'Parts used'),
        _field(theme, 'Have any parts been used during your visit?', _dd(theme, _partsUsed ? 'Yes' : 'No', _yesNo, (v) => setState(() => _partsUsed = v == 'Yes'))),
        SizedBox(height: 16.h),
        _title(theme, 'Photographic evidence'),
        for (final p in photos) ...[
          _photoRow(theme, p.$1, p.$2),
          SizedBox(height: 8.h),
        ],
        TextButton.icon(
          onPressed: () => _snack('Additional photo slot reserved.'),
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add another photo'),
          style: TextButton.styleFrom(foregroundColor: _accent),
        ),
        SizedBox(height: 16.h),
        _title(theme, 'Office notes'),
        _field(theme, 'Office notes (optional)', _tf(theme, _officeNotesController, 'For the office only…', maxLines: 3)),
        SizedBox(height: 16.h),
        _title(theme, 'Signatures & sign-off'),
        _field(theme, 'Engineer signature *', _tf(theme, _signatureController, 'Sign here (type full name)')),
        SizedBox(height: 12.h),
        _field(theme, 'Is the customer present at the end of the visit?', _dd(theme, _customerPresent, _customerPresentOptions, (v) => setState(() => _customerPresent = v))),
        SizedBox(height: 16.h),
        _title(theme, 'Engineer competency declaration'),
        _check(theme, _declReg, (v) => setState(() => _declReg = v ?? false), 'I confirm my Competent Person Scheme registration (number recorded above) is valid and current, and that it covers the installation type I tested or inspected today. *'),
        _check(theme, _declBs7671, (v) => setState(() => _declBs7671 = v ?? false), 'I confirm the electrical work performed today was tested and verified in accordance with BS 7671:2018+A4:2026 (or the latest applicable amendment) and IET Guidance Note 3. *'),
        _check(theme, _declPartP, (v) => setState(() => _declPartP = v ?? false), 'Where notifiable under Building Regulations Part P (dwellings), I confirm the work will be notified via my CPS scheme within the statutory window. *'),
      ],
    );
  }

  Widget _photoRow(DashboardTheme theme, String title, String subtitle) {
    return JobPhotoSlot(
      label: '$title · $subtitle',
      filePath: _photos[title],
      onChanged: (path) {
        setState(() {
          if (path == null) {
            _photos.remove(title);
          } else {
            _photos[title] = path;
          }
        });
      },
    );
  }

  Widget _buildFooter(DashboardTheme theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.text,
                side: BorderSide(color: theme.border),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Submit EICR', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(DashboardTheme theme, String t) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(t, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: theme.dashHeading)),
      );

  Widget _field(DashboardTheme theme, String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.textBody)),
          SizedBox(height: 6.h),
          child,
        ],
      );

  Widget _tf(
    DashboardTheme theme,
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: theme.border, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: theme.border, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: _accent, width: 1)),
      ),
    );
  }

  Widget _dd(
    DashboardTheme theme,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.only(right: 8.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: theme.border, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: theme.border, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: _accent, width: 1)),
      ),
      hint: Text('Select…', style: TextStyle(fontSize: 13.sp, color: theme.textMuted)),
      iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.textMuted, size: 20.sp)),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 280.h,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _check(DashboardTheme theme, bool value, ValueChanged<bool?> onChanged, String label) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: _accent,
      title: Text(label, style: TextStyle(fontSize: 12.sp, color: theme.text, height: 1.35)),
    );
  }
}

class _EicrCircuit {
  String? description;
  String? wiring;
  String? refMethod;
  String? csaLive;
  String? csaNeutral;
  String? csaCpc;
  String? ocpdType;
  String? ocpdRating;
  String? ocpdBreaking;
  String? rcdFitted;
  String? continuityMethod;
  String? irVoltage;
  String? polarity;
  String? afdd;
  String? spd;

  final dbRef = TextEditingController();
  final way = TextEditingController();
  final points = TextEditingController();
  final ocpdBs = TextEditingController();
  final maxZs = TextEditingController();
  final continuityReading = TextEditingController();
  final irLl = TextEditingController();
  final irLe = TextEditingController();
  final irNe = TextEditingController();
  final measuredZs = TextEditingController();
  final remarks = TextEditingController();

  void dispose() {
    for (final c in [
      dbRef,
      way,
      points,
      ocpdBs,
      maxZs,
      continuityReading,
      irLl,
      irLe,
      irNe,
      measuredZs,
      remarks,
    ]) {
      c.dispose();
    }
  }
}

class _EicrTabBarDelegate extends SliverPersistentHeaderDelegate {
  _EicrTabBarDelegate({required this.theme, required this.child});

  final DashboardTheme theme;
  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: theme.base, alignment: Alignment.centerLeft, child: child);
  }

  @override
  bool shouldRebuild(covariant _EicrTabBarDelegate oldDelegate) =>
      theme != oldDelegate.theme || child != oldDelegate.child;
}
