import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/responsive/responsive_content.dart';
import 'package:chumley_navigator/screens/forms/eicr/models/eicr_circuit.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_circuits_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_cps_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_installation_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_risk_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_signoff_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/steps/eicr_supply_step.dart';
import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Electrical Installation Condition Report (EICR) — modularized multi-step form.
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

  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  // Step 1: Risk & HSE
  String? _riskAssessment;
  String? _workAtHeight;
  String? _safeIsolation;
  String? _clientBriefed;
  String? _vulnerable;
  final _riskNoteController = TextEditingController();

  // Step 2: CPS & Report
  String? _cpsScheme;
  final _schemeRegController = TextEditingController();
  final _partPController = TextEditingController();
  bool _cpsConfirm = false;
  final _reportNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _inspectionDatesController = TextEditingController();
  final _issuerNameController = TextEditingController();
  final _issuerPositionController = TextEditingController();

  // Step 3: Installation
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

  // Step 4: Supply
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

  // Step 5: Circuits
  final List<EicrCircuit> _circuits = [EicrCircuit()];

  // Step 6: Sign-off & Inspections
  final Map<String, String?> _section1Outcomes = {
    for (final i in _section1Items) i: null,
  };
  final Map<String, String?> _sectionOutcomes = {
    for (final s in _otherInspectionSections) s: null,
  };
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
    final raw = (_scrollController.offset / _scrollThreshold).clamp(0.0, 1.0);
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
      _snack(
        'Competent Person Scheme registration and confirmation are required.',
        error: true,
      );
      return;
    }
    if (_signatureController.text.trim().isEmpty ||
        !_declReg ||
        !_declBs7671 ||
        !_declPartP) {
      setState(() => _tabController.index = 5);
      _snack(
        'Complete signature and competency declarations to submit.',
        error: true,
      );
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
            child: ResponsiveContent.form(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        NestedScrollView(
                          controller: _scrollController,
                          headerSliverBuilder: (context, _) => [
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: _brandingExpandedHeight.h,
                              ),
                            ),
                            SliverToBoxAdapter(child: _buildIntro(theme)),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: EicrTabBarDelegate(
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
                              EicrRiskStep(
                                theme: theme,
                                riskAssessment: _riskAssessment,
                                workAtHeight: _workAtHeight,
                                safeIsolation: _safeIsolation,
                                clientBriefed: _clientBriefed,
                                vulnerable: _vulnerable,
                                riskNoteController: _riskNoteController,
                                onRiskAssessmentChanged: (v) =>
                                    setState(() => _riskAssessment = v),
                                onWorkAtHeightChanged: (v) =>
                                    setState(() => _workAtHeight = v),
                                onSafeIsolationChanged: (v) =>
                                    setState(() => _safeIsolation = v),
                                onClientBriefedChanged: (v) =>
                                    setState(() => _clientBriefed = v),
                                onVulnerableChanged: (v) =>
                                    setState(() => _vulnerable = v),
                              ),
                              EicrCpsStep(
                                theme: theme,
                                cpsScheme: _cpsScheme,
                                schemeRegController: _schemeRegController,
                                partPController: _partPController,
                                cpsConfirm: _cpsConfirm,
                                reportNumberController: _reportNumberController,
                                reasonController: _reasonController,
                                inspectionDatesController:
                                    _inspectionDatesController,
                                issuerNameController: _issuerNameController,
                                issuerPositionController:
                                    _issuerPositionController,
                                onCpsSchemeChanged: (v) =>
                                    setState(() => _cpsScheme = v),
                                onCpsConfirmChanged: (v) =>
                                    setState(() => _cpsConfirm = v ?? false),
                              ),
                              EicrInstallationStep(
                                theme: theme,
                                wiringAgeController: _wiringAgeController,
                                additions: _additions,
                                recordsAvailable: _recordsAvailable,
                                lastInspectionDateController:
                                    _lastInspectionDateController,
                                extentController: _extentController,
                                limitationsAgreed: _limitationsAgreed,
                                operationalLimitations: _operationalLimitations,
                                agreedWithController: _agreedWithController,
                                bs7671Controller: _bs7671Controller,
                                supplyPolarityController:
                                    _supplyPolarityController,
                                spdBsController: _spdBsController,
                                spdTypeController: _spdTypeController,
                                spdRatedController: _spdRatedController,
                                spdBreakingController: _spdBreakingController,
                                mainOvercurrentType: _mainOvercurrentType,
                                mainOvercurrentRatingController:
                                    _mainOvercurrentRatingController,
                                mainOvercurrentBreakingController:
                                    _mainOvercurrentBreakingController,
                                rcdMainBreakingController:
                                    _rcdMainBreakingController,
                                dbLocationController: _dbLocationController,
                                suppliedFromController: _suppliedFromController,
                                zdbController: _zdbController,
                                ipfController: _ipfController,
                                distOcpdBsController: _distOcpdBsController,
                                distOcpdTypeController: _distOcpdTypeController,
                                distOcpdRatingController:
                                    _distOcpdRatingController,
                                spdAtBoard: _spdAtBoard,
                                generalConditionController:
                                    _generalConditionController,
                                furtherInspectionController:
                                    _furtherInspectionController,
                                recommendationReasonsController:
                                    _recommendationReasonsController,
                                inspectedByNameController:
                                    _inspectedByNameController,
                                inspectedByPositionController:
                                    _inspectedByPositionController,
                                authorisedByNameController:
                                    _authorisedByNameController,
                                authorisedByPositionController:
                                    _authorisedByPositionController,
                                instrumentsController: _instrumentsController,
                                onAdditionsChanged: (v) =>
                                    setState(() => _additions = v),
                                onRecordsAvailableChanged: (v) =>
                                    setState(() => _recordsAvailable = v),
                                onLimitationsAgreedChanged: (v) =>
                                    setState(() => _limitationsAgreed = v),
                                onOperationalLimitationsChanged: (v) =>
                                    setState(() => _operationalLimitations = v),
                                onMainOvercurrentTypeChanged: (v) =>
                                    setState(() => _mainOvercurrentType = v),
                                onSpdAtBoardChanged: (v) =>
                                    setState(() => _spdAtBoard = v),
                              ),
                              EicrSupplyStep(
                                theme: theme,
                                nominalVoltageController:
                                    _nominalVoltageController,
                                numberOfPhases: _numberOfPhases,
                                frequencyController: _frequencyController,
                                zeController: _zeController,
                                psccController: _psccController,
                                pfcController: _pfcController,
                                earthingArrangement: _earthingArrangement,
                                natureOfSupply: _natureOfSupply,
                                meansOfEarthing: _meansOfEarthing,
                                maxDemandController: _maxDemandController,
                                earthingMaterial: _earthingMaterial,
                                earthingCsa: _earthingCsa,
                                earthingVerified: _earthingVerified,
                                bondingMaterial: _bondingMaterial,
                                bondingCsa: _bondingCsa,
                                bondingVerified: _bondingVerified,
                                bondWater: _bondWater,
                                bondGas: _bondGas,
                                bondOil: _bondOil,
                                bondSteel: _bondSteel,
                                bondLps: _bondLps,
                                bondOtherController: _bondOtherController,
                                mainSwitchLocationController:
                                    _mainSwitchLocationController,
                                mainSwitchBsController: _mainSwitchBsController,
                                mainSwitchPoles: _mainSwitchPoles,
                                mainSwitchCurrent: _mainSwitchCurrent,
                                mainSwitchVoltageController:
                                    _mainSwitchVoltageController,
                                mainSwitchKind: _mainSwitchKind,
                                onNumberOfPhasesChanged: (v) =>
                                    setState(() => _numberOfPhases = v),
                                onEarthingArrangementChanged: (v) =>
                                    setState(() => _earthingArrangement = v),
                                onNatureOfSupplyChanged: (v) =>
                                    setState(() => _natureOfSupply = v),
                                onMeansOfEarthingChanged: (v) =>
                                    setState(() => _meansOfEarthing = v),
                                onEarthingMaterialChanged: (v) =>
                                    setState(() => _earthingMaterial = v),
                                onEarthingCsaChanged: (v) =>
                                    setState(() => _earthingCsa = v),
                                onEarthingVerifiedChanged: (v) =>
                                    setState(() => _earthingVerified = v),
                                onBondingMaterialChanged: (v) =>
                                    setState(() => _bondingMaterial = v),
                                onBondingCsaChanged: (v) =>
                                    setState(() => _bondingCsa = v),
                                onBondingVerifiedChanged: (v) =>
                                    setState(() => _bondingVerified = v),
                                onBondWaterChanged: (v) =>
                                    setState(() => _bondWater = v),
                                onBondGasChanged: (v) =>
                                    setState(() => _bondGas = v),
                                onBondOilChanged: (v) =>
                                    setState(() => _bondOil = v),
                                onBondSteelChanged: (v) =>
                                    setState(() => _bondSteel = v),
                                onBondLpsChanged: (v) =>
                                    setState(() => _bondLps = v),
                                onMainSwitchPolesChanged: (v) =>
                                    setState(() => _mainSwitchPoles = v),
                                onMainSwitchCurrentChanged: (v) =>
                                    setState(() => _mainSwitchCurrent = v),
                                onMainSwitchKindChanged: (v) =>
                                    setState(() => _mainSwitchKind = v),
                              ),
                              EicrCircuitsStep(
                                theme: theme,
                                circuits: _circuits,
                                onAddCircuit: () => setState(
                                  () => _circuits.add(EicrCircuit()),
                                ),
                                onRemoveCircuit: (i) => setState(
                                  () => _circuits.removeAt(i).dispose(),
                                ),
                                onStateChanged: () => setState(() {}),
                              ),
                              EicrSignoffStep(
                                theme: theme,
                                section1Items: _section1Items,
                                otherInspectionSections:
                                    _otherInspectionSections,
                                section1Outcomes: _section1Outcomes,
                                sectionOutcomes: _sectionOutcomes,
                                partsUsed: _partsUsed,
                                photos: _photos,
                                officeNotesController: _officeNotesController,
                                signatureController: _signatureController,
                                customerPresent: _customerPresent,
                                declReg: _declReg,
                                declBs7671: _declBs7671,
                                declPartP: _declPartP,
                                onSection1OutcomeChanged: (item, v) =>
                                    setState(() => _section1Outcomes[item] = v),
                                onSectionOutcomeChanged: (section, v) =>
                                    setState(
                                      () => _sectionOutcomes[section] = v,
                                    ),
                                onPartsUsedChanged: (v) =>
                                    setState(() => _partsUsed = v),
                                onPhotoChanged: (title, path) {
                                  setState(() {
                                    if (path == null) {
                                      _photos.remove(title);
                                    } else {
                                      _photos[title] = path;
                                    }
                                  });
                                },
                                onCustomerPresentChanged: (v) =>
                                    setState(() => _customerPresent = v),
                                onDeclRegChanged: (v) =>
                                    setState(() => _declReg = v ?? false),
                                onDeclBs7671Changed: (v) =>
                                    setState(() => _declBs7671 = v ?? false),
                                onDeclPartPChanged: (v) =>
                                    setState(() => _declPartP = v ?? false),
                                onAddManualObservation: () => _snack(
                                  'Manual observations coming in a follow-up.',
                                ),
                                onAddPhotoSlot: () =>
                                    _snack('Additional photo slot reserved.'),
                              ),
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
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.dashMuted,
              height: 1.35,
            ),
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
            child: Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Submit EICR',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
