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

/// Landlord Gas Safety Record (CP12) — fields aligned with the HTML preview.
class Cp12FormPage extends StatefulWidget {
  const Cp12FormPage({
    super.key,
    this.appointmentNumber = '',
    this.engineerName = '',
    this.postcode = '',
    this.subject = '',
    this.jobId = '',
    this.onSubmitted,
  });

  final String appointmentNumber;
  final String engineerName;
  final String postcode;
  final String subject;
  final String jobId;
  final VoidCallback? onSubmitted;

  @override
  State<Cp12FormPage> createState() => _Cp12FormPageState();
}

class _Cp12FormPageState extends State<Cp12FormPage>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Risk & HSE',
    'Gas Safe',
    'Tightness',
    'Pipework',
    'Appliances',
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

  static const _gasSmellOptions = [
    'No smell - safe to proceed',
    'Faint smell - ventilate and retest',
    'STOP - strong smell, call National Gas Emergency 0800 111 999',
  ];

  static const _occupantBriefedOptions = [
    'Briefed and consented',
    'Prior consent on file',
    'Property vacant - no occupant to brief',
    'STOP - unable to brief, occupant vulnerable / no consent',
  ];

  static const _smokeAlarmOptions = [
    'Present, push-test passed',
    'Present, push-test failed - advise replacement',
    'Absent in one or more locations - log as NCS',
    'N/A - non-domestic / commercial property',
  ];

  static const _coAlarmOptions = [
    'Present, push-test passed',
    'Present, push-test failed - advise replacement',
    'Absent in rooms with fixed combustion appliances - log as AR per GIUSP',
    'N/A - no combustion appliances in scope rooms',
  ];

  static const _lastInspectionOptions = [
    'Within 12 months - on cycle',
    'More than 12 months - landlord overdue, advisory note',
    'First inspection - no prior CP12 on record',
    'Unable to confirm - customer / landlord cannot produce previous record',
  ];

  static const _yesNo = ['Yes', 'No'];

  static const _letByOptions = [
    'Yes - ECV held',
    'No - ECV failed let-by (escalate, do not commission)',
  ];

  static const _fuelTypes = ['Natural Gas', 'LPG', 'LPG/Air'];

  static const _meterTypes = [
    'G4 / U6 Diaphragm',
    'E6 Ultrasonic Smart',
    'U16 Diaphragm',
    'Other',
  ];

  static const _ivMeterTypes = [
    'G4 / U6 Diaphragm (0.008 m³)',
    'E6 Ultrasonic Smart (0.0024 m³)',
    'U16 Diaphragm (0.025 m³)',
    'Other (enter IV manually in tightness-test row)',
  ];

  static const _tightnessResultOptions = [
    'Pass - within IV-band permissible drop',
    'Auto-pass - drop below fuel auto-pass threshold',
    'Fail - exceeds permissible drop, meter to be capped/isolated',
  ];

  static const _ldfOptions = [
    'Yes',
    'No - none disturbed',
    'Not applicable',
  ];

  static const _ecvPresentOptions = [
    'Yes - present and accessible',
    'Yes - present but obstructed (advise rectification)',
    'No - log as AR per GIUSP',
  ];

  static const _ecvOperateOptions = [
    'Yes',
    'Stiff - advise replacement',
    'Failed - log as AR per GIUSP',
  ];

  static const _pipeMaterials = [
    'Copper',
    'Steel',
    'MDPE (incoming service)',
    'Mixed',
    'Other',
  ];

  static const _bondingOptions = [
    'Yes - bonding cable visible at meter',
    'No - log as NCS per GIUSP',
    'N/A - IT or specialist supply',
  ];

  static const _labellingOptions = [
    'Yes - labelled per BS 1710',
    'Partial - advisory note added',
    'No - log as NCS per GIUSP',
  ];

  static const _lastInspectionOnRecordOptions = [
    'Yes - visible on previous CP12 or customer record',
    'No - not known / first record on this property',
  ];

  static const _applianceTypes = [
    'Combi boiler',
    'System boiler',
    'Heat-only / Regular boiler',
    'Gas water heater - instantaneous',
    'Gas water heater - storage',
    'Warm air heater',
    'Gas fire - decorative / open / closed',
    'Gas hob / oven / cooker',
    'Range cooker / AGA',
    'Other',
  ];

  static const _locations = [
    'Kitchen',
    'Bathroom',
    'En-suite',
    'Utility / boot room',
    'WC / cloakroom',
    'Bedroom',
    'Hallway / landing',
    'Loft',
    'Cellar / basement',
    'Boiler cupboard',
    'Plant room',
    'External - front',
    'External - rear',
    'External - boundary / meter',
    'Outhouse / outbuilding',
    'Whole property',
    'Other - describe below',
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

  // Risk & HSE
  String? _riskAssessment;
  String? _workAtHeight;
  String? _gasSmell;
  String? _occupantBriefed;
  String? _smokeAlarm;
  String? _coAlarm;
  String? _lastInspectionCycle;
  final _riskNoteController = TextEditingController();

  // Gas Safe
  final _gasSafeRegController = TextEditingController();
  bool _gasSafeConfirm = false;

  // Tightness
  String? _letBy;
  String? _fuelType;
  final _testPressureController = TextEditingController();
  String? _stabilisation;
  final _measuredDropController = TextEditingController();
  String? _meterType;
  final _installationVolumeController = TextEditingController();
  final _permissibleDropController = TextEditingController();
  String? _tightnessResult;
  String? _ldf;
  String? _ivMeterType;

  // Pipework
  String? _ecvPresent;
  String? _ecvOperates;
  final _regulatorPressureController = TextEditingController();
  String? _pipeMaterial;
  String? _bonding;
  String? _labelling;
  String? _lastInspectionOnRecord;

  // Appliances
  final List<_ApplianceRow> _appliances = [
    _ApplianceRow(),
  ];

  // Sign-off
  bool _partsUsed = false;
  final _officeNotesController = TextEditingController();
  final _signatureController = TextEditingController();
  String? _customerPresent;
  bool _declRegValid = false;
  bool _declWorkCompliant = false;
  bool _declWarningNotice = false;

  final Map<String, String> _capturedPhotos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _riskNoteController.dispose();
    _gasSafeRegController.dispose();
    _testPressureController.dispose();
    _measuredDropController.dispose();
    _installationVolumeController.dispose();
    _permissibleDropController.dispose();
    _regulatorPressureController.dispose();
    _officeNotesController.dispose();
    _signatureController.dispose();
    for (final a in _appliances) {
      a.dispose();
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

  void _applyIvFromMeter() {
    final map = {
      'G4 / U6 Diaphragm (0.008 m³)': '0.008',
      'E6 Ultrasonic Smart (0.0024 m³)': '0.0024',
      'U16 Diaphragm (0.025 m³)': '0.025',
    };
    final v = map[_ivMeterType];
    if (v == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select a meter type with a known volume, or enter IV manually.',
            style: TextStyle(fontSize: 13.sp),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _installationVolumeController.text = v;
      if (_ivMeterType!.startsWith('G4')) {
        _meterType = 'G4 / U6 Diaphragm';
      } else if (_ivMeterType!.startsWith('E6')) {
        _meterType = 'E6 Ultrasonic Smart';
      } else if (_ivMeterType!.startsWith('U16')) {
        _meterType = 'U16 Diaphragm';
      }
    });
  }

  void _onCancel() => Navigator.of(context).maybePop(false);

  void _onSave() {
    if (_gasSafeRegController.text.trim().isEmpty || !_gasSafeConfirm) {
      setState(() => _tabController.index = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gas Safe registration and confirmation are required.',
            style: TextStyle(fontSize: 13.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.errorText,
        ),
      );
      return;
    }
    if (_signatureController.text.trim().isEmpty ||
        !_declRegValid ||
        !_declWorkCompliant ||
        !_declWarningNotice) {
      setState(() => _tabController.index = 5);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete signature and competency declarations to submit.',
            style: TextStyle(fontSize: 13.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.errorText,
        ),
      );
      return;
    }

    widget.onSubmitted?.call();
    if (widget.onSubmitted == null) {
      Navigator.of(context).pop(true);
    }
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
                            delegate: _Cp12TabBarDelegate(
                              theme: theme,
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.ppmAccent,
                                unselectedLabelColor: theme.textMuted,
                                indicatorColor: AppColors.ppmAccent,
                                labelStyle: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [
                                  for (final t in _tabs) Tab(text: t),
                                ],
                              ),
                            ),
                          ),
                        ],
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRiskTab(theme),
                            _buildGasSafeTab(theme),
                            _buildTightnessTab(theme),
                            _buildPipeworkTab(theme),
                            _buildAppliancesTab(theme),
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
                                'CP12 Form',
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
                  color: AppColors.ppmAccent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'CP12',
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
                  'Landlord Gas Safety Record (CP12)',
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
            'This Landlord Gas Safety Record (CP12) records the annual gas safety inspection performed at the address overleaf.',
            style: TextStyle(fontSize: 12.sp, color: theme.dashMuted, height: 1.35),
          ),
          SizedBox(height: 10.h),
          _readOnlyChip(
            theme,
            'Appointment',
            widget.appointmentNumber.isNotEmpty
                ? widget.appointmentNumber
                : '—',
          ),
          SizedBox(height: 6.h),
          _readOnlyChip(
            theme,
            'Property / postcode',
            widget.postcode.isNotEmpty ? widget.postcode : '—',
          ),
          if (widget.subject.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _readOnlyChip(theme, 'Subject', widget.subject),
          ],
        ],
      ),
    );
  }

  Widget _readOnlyChip(DashboardTheme theme, String label, String value) {
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
              value,
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
        _sectionTitle(theme, 'Property & installation details'),
        Text(
          'Property details will populate from the site record.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'On-site risk assessment'),
        Text(
          'Confirm the on-site risk assessment is complete before you start work.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 10.h),
        _labeled(
          theme,
          'Has an on-site risk assessment been completed? *',
          _dropdown(
            theme,
            value: _riskAssessment,
            items: _riskAssessmentOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _riskAssessment = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Additional controls note',
          _textField(theme, _riskNoteController, 'Note (if required)…', maxLines: 3),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Work at Height - pre-work'),
        Text(
          'WAHR 2005 reminder. Will today\'s task involve work where a fall could cause injury?',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 10.h),
        _labeled(
          theme,
          'Will today\'s task involve work where a fall could cause injury? *',
          _dropdown(
            theme,
            value: _workAtHeight,
            items: _workAtHeightOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _workAtHeight = v),
          ),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'HSE gatekeeper checks'),
        _labeled(
          theme,
          'No current gas smell on arrival (High risk)',
          _dropdown(
            theme,
            value: _gasSmell,
            items: _gasSmellOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _gasSmell = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Customer / occupant briefed that gas may be turned off (Medium risk)',
          _dropdown(
            theme,
            value: _occupantBriefed,
            items: _occupantBriefedOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _occupantBriefed = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Smoke alarm present and push-tested (High risk)',
          _dropdown(
            theme,
            value: _smokeAlarm,
            items: _smokeAlarmOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _smokeAlarm = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Carbon monoxide alarm present and push-tested (High risk)',
          _dropdown(
            theme,
            value: _coAlarm,
            items: _coAlarmOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _coAlarm = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Date of last gas safety inspection - within last 12 months? (Medium risk)',
          _dropdown(
            theme,
            value: _lastInspectionCycle,
            items: _lastInspectionOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _lastInspectionCycle = v),
          ),
        ),
      ],
    );
  }

  Widget _buildGasSafeTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _sectionTitle(theme, 'Gas Safe compliance'),
        Text(
          'Your Gas Safe registration must be recorded before any work narrative. Engineer ID or company registration accepted.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        if (widget.engineerName.isNotEmpty)
          _readOnlyChip(theme, 'Engineer', widget.engineerName),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Gas Safe registration number *',
          _textField(
            theme,
            _gasSafeRegController,
            '1–7 digits - your engineer ID or the company registration',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 14.h),
        _checkboxTile(
          theme,
          value: _gasSafeConfirm,
          onChanged: (v) => setState(() => _gasSafeConfirm = v ?? false),
          label:
              'I confirm I hold valid Gas Safe registration that covers the appliance category and work I am about to carry out on this system. If unsure, I will stop and reassess. *',
        ),
      ],
    );
  }

  Widget _buildTightnessTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _sectionTitle(theme, 'Tightness test (Section 1)'),
        Text(
          'Pressure-test the installation pipework per IGEM/UP/1B Edition 4.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Let-by test passed (7-10 mbar for 1 min) *',
          _dropdown(
            theme,
            value: _letBy,
            items: _letByOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _letBy = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Fuel type *',
          _dropdown(
            theme,
            value: _fuelType,
            items: _fuelTypes,
            hint: 'Select…',
            onChanged: (v) => setState(() => _fuelType = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Test pressure * (mbar)',
          _textField(
            theme,
            _testPressureController,
            'Natural Gas: 20-21 mbar · LPG: 37 mbar',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          '1-minute stabilisation observed *',
          _dropdown(
            theme,
            value: _stabilisation,
            items: _yesNo,
            hint: 'Select…',
            onChanged: (v) => setState(() => _stabilisation = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Measured drop after 2-minute test * (mbar)',
          _textField(
            theme,
            _measuredDropController,
            '≤1 mbar NG auto-pass',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Gas meter type',
          _dropdown(
            theme,
            value: _meterType,
            items: _meterTypes,
            hint: 'Select…',
            onChanged: (v) => setState(() => _meterType = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Installation Volume (IV) (m³)',
          _textField(
            theme,
            _installationVolumeController,
            'From IGEM/UP/1B Ed 4 calculation',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Permissible drop (from IV-band table) (mbar)',
          _textField(
            theme,
            _permissibleDropController,
            'Look up against fuel-specific table',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Overall tightness test result *',
          _dropdown(
            theme,
            value: _tightnessResult,
            items: _tightnessResultOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _tightnessResult = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Leak detection fluid (LDF) applied to disturbed joints *',
          _dropdown(
            theme,
            value: _ldf,
            items: _ldfOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _ldf = v),
          ),
        ),
        SizedBox(height: 20.h),
        _sectionTitle(theme, 'IV Calculator (helper)'),
        Text(
          'Optional helper. Select meter type and Apply IV to copy into the tightness-test row.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 10.h),
        _labeled(
          theme,
          'Gas meter type',
          _dropdown(
            theme,
            value: _ivMeterType,
            items: _ivMeterTypes,
            hint: 'Select…',
            onChanged: (v) => setState(() => _ivMeterType = v),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _applyIvFromMeter,
            icon: Icon(LucideIcons.calculator, size: 16.sp),
            label: Text(
              'Apply IV to tightness-test row →',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.ppmAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildPipeworkTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _sectionTitle(theme, 'Installation pipework (Section 2)'),
        Text(
          'Inspect the supplying installation - ECV state, regulator, pipework material and electrical bonding to gas service.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Emergency Control Valve (ECV) present and accessible *',
          _dropdown(
            theme,
            value: _ecvPresent,
            items: _ecvPresentOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _ecvPresent = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'ECV operates correctly (turns freely, holds let-by) *',
          _dropdown(
            theme,
            value: _ecvOperates,
            items: _ecvOperateOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _ecvOperates = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Regulator working pressure * (mbar)',
          _textField(
            theme,
            _regulatorPressureController,
            'Natural Gas typical: 20-21 mbar',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Predominant pipework material *',
          _dropdown(
            theme,
            value: _pipeMaterial,
            items: _pipeMaterials,
            hint: 'Select…',
            onChanged: (v) => setState(() => _pipeMaterial = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Equipotential bonding to gas service present *',
          _dropdown(
            theme,
            value: _bonding,
            items: _bondingOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _bonding = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Pipework labelling and sundries compliant *',
          _dropdown(
            theme,
            value: _labelling,
            items: _labellingOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _labelling = v),
          ),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Is the date of the last gas safety inspection on record?',
          _dropdown(
            theme,
            value: _lastInspectionOnRecord,
            items: _lastInspectionOnRecordOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _lastInspectionOnRecord = v),
          ),
        ),
      ],
    );
  }

  Widget _buildAppliancesTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _sectionTitle(theme, 'Appliance inspection (Sections 3+)'),
        Text(
          'Inspect each gas appliance and record the readings, verdict and any actions taken. One row per appliance.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        for (var i = 0; i < _appliances.length; i++) ...[
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.ppmAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Appliance ${i + 1}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    const Spacer(),
                    if (_appliances.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _appliances.removeAt(i).dispose();
                          });
                        },
                        icon: Icon(
                          LucideIcons.trash2,
                          size: 16.sp,
                          color: AppColors.errorText,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                _labeled(
                  theme,
                  'Appliance type *',
                  _dropdown(
                    theme,
                    value: _appliances[i].type,
                    items: _applianceTypes,
                    hint: 'Select…',
                    onChanged: (v) =>
                        setState(() => _appliances[i].type = v),
                  ),
                ),
                SizedBox(height: 10.h),
                _labeled(
                  theme,
                  'Location in property *',
                  _dropdown(
                    theme,
                    value: _appliances[i].location,
                    items: _locations,
                    hint: 'Select…',
                    onChanged: (v) =>
                        setState(() => _appliances[i].location = v),
                  ),
                ),
                SizedBox(height: 10.h),
                _labeled(
                  theme,
                  'Notes / measurements',
                  _textField(
                    theme,
                    _appliances[i].notes,
                    'Add another reading or measurement…',
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
        TextButton.icon(
          onPressed: () => setState(() => _appliances.add(_ApplianceRow())),
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: Text(
            '+ Add another appliance',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(foregroundColor: AppColors.ppmAccent),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Findings & observations'),
        Text(
          'Classify findings using GIUSP codes (ID, AR, NCS, NCT).',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Findings capture coming in a follow-up.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add finding'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ppmAccent,
            side: BorderSide(color: AppColors.ppmAccent.withValues(alpha: 0.5)),
          ),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Parts used'),
        Text(
          'Only if anything was consumed on site',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 8.h),
        _labeled(
          theme,
          'Have any parts been used during your visit?',
          _dropdown(
            theme,
            value: _partsUsed ? 'Yes' : 'No',
            items: _yesNo,
            hint: 'Select…',
            onChanged: (v) => setState(() => _partsUsed = v == 'Yes'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOffTab(DashboardTheme theme) {
    final photoItems = [
      ('Appliance data plate', 'Make / model / serial / GC number'),
      ('Flue - internal termination', 'Internal spigot and support'),
      ('Flue - external termination', 'External terminal clearances visible'),
      ('FGA reading - in steady state', 'Analyser display showing CO, CO₂, ratio'),
      ('Gas meter & ECV', 'Meter index for gas rate verification'),
      (
        'Tightness test - manometer reading',
        'Manometer reading at end-of-test',
      ),
      (
        'Warning Notice (RIDDOR Form 8) issued',
        'Photograph of the issued Warning Notice',
      ),
      (
        'Gas + ventilation interlock panel',
        'Interlock controller / actuator photographed',
      ),
      (
        'Kitchen ventilation hood / extraction',
        'Extraction hood with appliances visible',
      ),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _sectionTitle(theme, 'Photographic evidence'),
        for (final item in photoItems) ...[
          _photoRow(theme, item.$1, item.$2),
          SizedBox(height: 8.h),
        ],
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Additional photo slot reserved.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: const Text('+ Add another photo'),
          style: TextButton.styleFrom(foregroundColor: AppColors.ppmAccent),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Office notes'),
        Text(
          'For the office only - NOT shown to the customer',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 8.h),
        _labeled(
          theme,
          'Office notes (optional)',
          _textField(
            theme,
            _officeNotesController,
            'Office notes…',
            maxLines: 4,
          ),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Signatures & sign-off'),
        _labeled(
          theme,
          'Engineer signature *',
          _textField(theme, _signatureController, 'Sign here (type full name)'),
        ),
        SizedBox(height: 12.h),
        _labeled(
          theme,
          'Is the customer present at the end of the visit?',
          _dropdown(
            theme,
            value: _customerPresent,
            items: _customerPresentOptions,
            hint: 'Select…',
            onChanged: (v) => setState(() => _customerPresent = v),
          ),
        ),
        SizedBox(height: 16.h),
        _sectionTitle(theme, 'Engineer competency declaration'),
        Text(
          'Before signing off, confirm your competency and the validity of the gas work performed today.',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 10.h),
        _checkboxTile(
          theme,
          value: _declRegValid,
          onChanged: (v) => setState(() => _declRegValid = v ?? false),
          label:
              'I confirm my Gas Safe registration (number recorded above) is valid and current, and that it covers the appliance category(ies) I worked on today. *',
        ),
        _checkboxTile(
          theme,
          value: _declWorkCompliant,
          onChanged: (v) => setState(() => _declWorkCompliant = v ?? false),
          label:
              'I confirm the gas work performed today was completed in accordance with the Gas Safety (Installation and Use) Regulations 1998, BS 6798 / BS EN 26 / BS 5440 (where applicable). *',
        ),
        _checkboxTile(
          theme,
          value: _declWarningNotice,
          onChanged: (v) => setState(() => _declWarningNotice = v ?? false),
          label:
              'Where an Immediately Dangerous or At Risk situation was identified, I confirm I issued the appropriate warning notice (GIUSP) and recorded the action taken. *',
        ),
      ],
    );
  }

  Widget _photoRow(DashboardTheme theme, String title, String subtitle) {
    return JobPhotoSlot(
      label: '$title · $subtitle',
      filePath: _capturedPhotos[title],
      onChanged: (path) {
        setState(() {
          if (path == null) {
            _capturedPhotos.remove(title);
          } else {
            _capturedPhotos[title] = path;
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
                backgroundColor: AppColors.ppmAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Submit CP12',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(DashboardTheme theme, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: theme.dashHeading,
        ),
      ),
    );
  }

  Widget _labeled(DashboardTheme theme, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.textBody,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _textField(
    DashboardTheme theme,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.ppmAccent, width: 1),
        ),
      ),
    );
  }

  Widget _dropdown(
    DashboardTheme theme, {
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.only(right: 8.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.ppmAccent, width: 1),
        ),
      ),
      hint: Text(hint, style: TextStyle(fontSize: 13.sp, color: theme.textMuted)),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.textMuted,
          size: 20.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 280.h,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _checkboxTile(
    DashboardTheme theme, {
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.ppmAccent,
      title: Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: theme.text, height: 1.35),
      ),
    );
  }
}

class _ApplianceRow {
  String? type;
  String? location;
  final notes = TextEditingController();

  void dispose() => notes.dispose();
}

class _Cp12TabBarDelegate extends SliverPersistentHeaderDelegate {
  _Cp12TabBarDelegate({required this.theme, required this.child});

  final DashboardTheme theme;
  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: theme.base,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _Cp12TabBarDelegate oldDelegate) =>
      theme != oldDelegate.theme || child != oldDelegate.child;
}
