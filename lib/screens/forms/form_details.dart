import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────

enum FormType { eicr, dampSurvey }

enum SeqStatus { none, confirmed, rejected, na }

class _HseQ {
  final String label;
  final List<String> options;
  const _HseQ(this.label, this.options);
}

class _SeqGroup {
  final String title;
  final List<String> items;
  const _SeqGroup(this.title, this.items);
}

class _FormContent {
  final String pageSubtitle;
  final String badge;
  final String scopeSubtitle;
  final String scopeBody;
  final String scopeRefs;
  final List<String> ppeItems;
  final List<_HseQ> hseQuestions;
  final List<_SeqGroup> seqGroups;

  const _FormContent({
    required this.pageSubtitle,
    required this.badge,
    required this.scopeSubtitle,
    required this.scopeBody,
    required this.scopeRefs,
    required this.ppeItems,
    required this.hseQuestions,
    required this.seqGroups,
  });
}

// ─────────────────────────────────────────────────────────────
// Static form content
// ─────────────────────────────────────────────────────────────

const _eicrContent = _FormContent(
  pageSubtitle: 'Electrical Installation Condition Report (EICR)',
  badge: 'Electrical',
  scopeSubtitle: 'Electrical · Periodic Inspection & Testing',
  scopeBody:
  'Periodic inspection and testing of an existing fixed electrical installation in accordance with BS 7671:2018+A2:2022 and IET Guidance Note 3. Outcome is an EICR with overall classification of Satisfactory or Unsatisfactory based on observation codes C1/C2/C3/FI.',
  scopeRefs:
  'BS 7671:2018+A2:2022 · IET Guidance Note 3 (8th ed) · Electricity at Work Regs 1989 · PRS Regs 2020 (if applicable)',
  ppeItems: [
    'Insulated gloves and eye protection in use',
    'Voltage indicator proven live–dead–live before test',
    'Warning notices and barriers in place where isolating',
  ],
  hseQuestions: [
    _HseQ('Safe isolation procedure followed', [
      'Yes — locked off and proved dead',
      'Partial — supervised',
      'Not possible — STOP',
    ]),
    _HseQ('Client briefed on power interruption', [
      'Briefed and consent given',
      'Unable to contact — proceed per instruction',
      'Refused — STOP',
    ]),
    _HseQ('Vulnerable occupants considered (medical equipment, lifts)', [
      'None present',
      'Present — arrangements made',
      'Present — STOP until arranged',
    ]),
  ],
  seqGroups: [
    _SeqGroup('Before work', [
      'Extent and limitations agreed with client in writing',
      'Previous EICR or installation certificate reviewed where available',
      'Consumer unit / distribution boards identified and labelled',
    ]),
    _SeqGroup('During work', [
      'Safe isolation — prove dead before test',
      'Measure supply characteristics (Ze, PSCC, PFC)',
      'Complete inspection schedule against BS 7671 checklist',
      'Record test results per circuit (continuity, insulation resistance, polarity, Zs, RCD operation)',
      'Classify each observation with C1, C2, C3 or FI and record BS 7671 regulation reference',
    ]),
    _SeqGroup('After work', [
      'Determine overall classification (Satisfactory only if no C1/C2/FI)',
      'Affix Electrical Installation Condition label at origin',
      'Issue report, schedule of inspections, schedule of test results',
      'Notify client immediately of any C1 findings; isolate or make safe on site',
      'Recommend next inspection date per GN3 Table 3.1',
    ]),
  ],
);

const _dampContent = _FormContent(
  pageSubtitle: 'Damp & Moisture Survey',
  badge: 'Building Fabric',
  scopeSubtitle: 'Building Fabric · Damp, Condensation & Timber',
  scopeBody:
  'Diagnostic damp and moisture survey of an occupied property to classify the cause of dampness (rising, penetrating, condensation, plumbing leak or a combination) and to recommend remediation. Carried out to BS 5250:2021, BRE Digest 245 and the Property Care Association (PCA) Code of Practice.',
  scopeRefs: 'BS 5250:2021 · BRE Digest 245 · PCA CoP for remedial damp-proofing',
  ppeItems: [
    'Dust mask and gloves worn when lifting timber / disturbing plaster',
    'Moisture meter within calibration (last 12 months)',
    'Ladder / access equipment suitable for external inspection',
  ],
  hseQuestions: [
    _HseQ('Occupants briefed on scope and non-destructive nature of inspection', [
      'Briefed and consent given',
      'Unable to contact — letting agent authorised',
      'Refused — STOP',
    ]),
    _HseQ('Mould growth visible — respiratory risk assessed', [
      'No significant mould',
      'Present — PPE worn and ventilated',
      'Heavy contamination — STOP, refer to specialist remediation',
    ]),
    _HseQ('Evidence of asbestos-containing materials (pre-2000 building)', [
      'None suspected',
      'Present but intact — not disturbed',
      'Disturbed or damaged — STOP, refer to licensed surveyor',
    ]),
  ],
  seqGroups: [
    _SeqGroup('Before work', [
      'Property age, construction type and history of defects confirmed with occupant',
      'Previous damp reports or invoices reviewed where available',
      'Moisture meter zeroed and function-checked on known-dry timber',
    ]),
    _SeqGroup('During work', [
      'External walk-around completed: rainwater goods, pointing, DPC, ground levels',
      'Internal moisture profile taken: minimum 3 readings per affected wall at varying heights',
      'Environmental readings logged: air temp, RH, coldest surface temp, dew point calculated',
      'Affected areas photographed with scale reference and location annotation',
      'Timber in proximity probed for rot where safely accessible (skirting, joist ends, lintels)',
    ]),
    _SeqGroup('After work', [
      'Classify dampness: rising / penetrating / condensation / plumbing / combination',
      'Recommend remediation per PCA CoP and assign priority (urgent / planned / monitor)',
      'Identify whether further investigation is required (opening up, salt analysis, trace-gas leak detection)',
      'Issue report with reading schedule, annotated photographs and classification',
      'Advise occupant on immediate mitigation (ventilation, heating regime) where relevant',
    ]),
  ],
);

// ─────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────

class InspectionReportPage extends StatefulWidget {
  final FormType formType;
  const InspectionReportPage({super.key, required this.formType});

  @override
  State<InspectionReportPage> createState() => _InspectionReportPageState();
}

class _InspectionReportPageState extends State<InspectionReportPage> {
  static const _stepCount = 3;
  static const _stepTitles = [
    'Scope & Safety',
    'Work Sequence',
    'Review & Submit',
  ];

  late final _FormContent _c;
  final ScrollController _scrollController = ScrollController();

  int _currentStep = 0;

  // interactive state
  final Set<int> _ppeConfirmed = {};
  final Map<int, String?> _hseValues = {};
  final Map<String, SeqStatus> _seqStatus = {};

  DashboardTheme get _t => DashboardTheme.of(context);

  @override
  void initState() {
    super.initState();
    _c = widget.formType == FormType.eicr ? _eicrContent : _dampContent;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _totalSeqItems =>
      _c.seqGroups.fold<int>(0, (sum, g) => sum + g.items.length);

  int get _confirmedSeqCount =>
      _seqStatus.values.where((s) => s == SeqStatus.confirmed).length;

  void _goToStep(int step) {
    final next = step.clamp(0, _stepCount - 1);
    if (next == _currentStep) return;
    setState(() => _currentStep = next);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onNext() {
    if (_currentStep < _stepCount - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _submitForm();
    }
  }

  void _onPrev() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  void _submitForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Inspection report draft saved',
          style: TextStyle(fontSize: 14.sp),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _sectionWrap({required Widget child, double top = 16}) {
    return Padding(
      padding: EdgeInsets.only(top: top.h),
      child: child,
    );
  }

  Widget _formCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? _t.surface,
        border: Border.all(color: _t.border, width: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: padding ?? EdgeInsets.all(14.r),
      child: child,
    );
  }

  Widget _buildPageHeader() {
    return FadeSlideIn(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inspection Report',
                  style: TextStyle(
                    color: _t.text,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _c.pageSubtitle,
                  style: TextStyle(
                    color: _t.textMuted,
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _t.surfaceDeep,
              border: Border.all(color: _t.border, width: 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              _c.badge,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScopeSection(),
            _buildPPESection(),
            _buildHSESection(),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWorkSequenceSection(),
          ],
        );
      default:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReviewSection(),
          ],
        );
    }
  }

  Widget _buildReviewSection() {
    final ppeDone = _ppeConfirmed.length;
    final ppeTotal = _c.ppeItems.length;
    final hseDone =
        _hseValues.values.where((v) => v != null && v.isNotEmpty).length;
    final hseTotal = _c.hseQuestions.length;

    return _sectionWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Review & submit',
            'Check your answers before submitting the report',
          ),
          SizedBox(height: 12.h),
          _formCard(
            child: Column(
              children: [
                _reviewRow(
                  'PPE checks',
                  '$ppeDone / $ppeTotal confirmed',
                  ppeDone == ppeTotal,
                ),
                Divider(height: 20.h, color: _t.border),
                _reviewRow(
                  'HSE gatekeeper',
                  '$hseDone / $hseTotal answered',
                  hseDone == hseTotal,
                ),
                Divider(height: 20.h, color: _t.border),
                _reviewRow(
                  'Work sequence',
                  '$_confirmedSeqCount / $_totalSeqItems confirmed',
                  _confirmedSeqCount > 0,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _formCard(
            backgroundColor: _t.surfaceDeep,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Submitting saves your progress as a draft. You can return to complete remaining steps later.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.45,
                      color: _t.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, bool complete) {
    return Row(
      children: [
        Icon(
          complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: complete ? AppColors.successText : _t.textMuted,
          size: 20.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _t.text,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _t.textMuted,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(88.h),
      child: AppBar(
        backgroundColor: _t.base,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 60.w,
        titleSpacing: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CommandCentreBackButton(
              onTap: () => Navigator.maybePop(context),
            ),
          ),
        ),
        title: const AspectBranding(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // INFO CARD  (Customer / Appointment / Ref)
  // ═══════════════════════════════════════════════════════════

  Widget _buildInfoCard() {
    return _sectionWrap(
      top: 0,
      child: _formCard(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCell('CUSTOMER', '–', mono: false),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: _buildInfoCell(
                    'APPOINTMENT',
                    '21/05/2026 · 08:00 — 17:00',
                    mono: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _buildInfoCell('REF', '05-21001', mono: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCell(String label, String value,
      {required bool mono}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: _t.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: mono ? 16.sp : 15.sp,
            fontWeight: FontWeight.w700,
            color: _t.text,
            fontFamily: mono ? 'monospace' : null,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SHARED: section header
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _t.text,
            height: 1.25,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: _t.textMuted,
                  height: 1.35)),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SCOPE OF WORK
  // ═══════════════════════════════════════════════════════════

  Widget _buildScopeSection() {
    return _sectionWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Scope of work', _c.scopeSubtitle),
          SizedBox(height: 12.h),
          _formCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _c.scopeBody,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _t.textMuted,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  _c.scopeRefs,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _t.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PPE & PRE-WORK SAFETY
  // ═══════════════════════════════════════════════════════════

  Widget _buildPPESection() {
    return _sectionWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PPE & pre-work safety'),
          SizedBox(height: 12.h),
          ...List.generate(_c.ppeItems.length, (i) {
            final confirmed = _ppeConfirmed.contains(i);
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildPPECard(i, _c.ppeItems[i], confirmed),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPPECard(int i, String label, bool confirmed) {
    return PressableScale(
      onTap: () => setState(() {
        confirmed ? _ppeConfirmed.remove(i) : _ppeConfirmed.add(i);
      }),
      scale: 0.99,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: confirmed ? _t.surfaceDeep : _t.surface,
          border: Border.all(
            color: confirmed ? AppColors.primaryBlue : _t.border,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: _t.text,
                    height: 1.45),
              ),
            ),
            SizedBox(width: 12.w),
            // ── confirm pill ──────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: confirmed
                  ? BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(999),
                    )
                  : BoxDecoration(
                      color: _t.surfaceDeep,
                      border: Border.all(color: _t.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (confirmed) ...[
                    Icon(LucideIcons.check,
                        color: AppColors.white, size: 13.sp),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    confirmed ? 'Confirmed' : 'Confirm',
                    style: TextStyle(
                      color: confirmed
                          ? AppColors.white
                          : AppColors.primaryBlue,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HSE GATEKEEPER CHECKS
  // ═══════════════════════════════════════════════════════════

  Widget _buildHSESection() {
    return _sectionWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'HSE gatekeeper checks',
            'A STOP response blocks submission',
          ),
          SizedBox(height: 12.h),
          ...List.generate(
            _c.hseQuestions.length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildHSECard(i, _c.hseQuestions[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHSECard(int i, _HseQ q) {
    return _formCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.label,
            style: TextStyle(
              fontSize: 14.sp,
              color: _t.text,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          SizedBox(height: 10.h),
          // ── styled dropdown ───────────────────────────
          Container(
            decoration: BoxDecoration(
              color: _t.surfaceDeep,
              border: Border.all(color: _t.border, width: 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.only(left: 14.w, right: 10.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _hseValues[i],
                isExpanded: true,
                hint: Text(
                  'Select response…',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: _t.textMuted),
                ),
                icon: Icon(LucideIcons.chevronDown,
                    color: _t.textMuted, size: 16.sp),
                style: TextStyle(
                    fontSize: 13.sp,
                    color: _t.text),
                borderRadius: BorderRadius.circular(12.r),
                onChanged: (val) =>
                    setState(() => _hseValues[i] = val),
                items: q.options
                    .map((o) =>
                    DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WORK SEQUENCE
  // ═══════════════════════════════════════════════════════════

  Widget _buildWorkSequenceSection() {
    return _sectionWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Work sequence',
            'Confirm each step, or mark as skipped / not applicable',
          ),
          SizedBox(height: 12.h),
          ...List.generate(_c.seqGroups.length, (gi) {
            final group = _c.seqGroups[gi];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gi > 0) SizedBox(height: 10.h),
                // ── group label ───────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    group.title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _t.textMuted,
                    ),
                  ),
                ),
                ...List.generate(
                  group.items.length,
                      (ii) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: _buildSeqCard('${gi}_$ii', group.items[ii]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSeqCard(String key, String label) {
    final status = _seqStatus[key] ?? SeqStatus.none;
    return _formCard(
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.w, top: 2.h),
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: _t.text,
                    height: 1.45),
              ),
            ),
          ),
          // ── tri-button group ──────────────────────────
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: [
              _buildSeqBtn('Confirmed', SeqStatus.confirmed, key, status),
              _buildSeqBtn('Rejected', SeqStatus.rejected, key, status),
              _buildSeqBtn('N/A', SeqStatus.na, key, status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeqBtn(
      String label, SeqStatus target, String key, SeqStatus current) {
    final sel = current == target;

    // resolve colours per state
    final Color bg;
    final Color fg;
    final Color border;

    if (!sel) {
      bg = _t.surface;
      fg = _t.textMuted;
      border = _t.border;
    } else {
      switch (target) {
        case SeqStatus.confirmed:
          bg = AppColors.primaryBlue;
          fg = AppColors.white;
          border = AppColors.primaryBlue;
          break;
        case SeqStatus.rejected:
          bg = AppColors.errorBackground;
          fg = AppColors.errorText;
          border = AppColors.errorBorder;
          break;
        case SeqStatus.na:
          bg = _t.surfaceDeep;
          fg = _t.textMuted;
          border = _t.border;
          break;
        default:
          bg = _t.surface;
          fg = _t.textMuted;
          border = _t.border;
      }
    }

    return PressableScale(
      onTap: () => setState(() {
        _seqStatus[key] = sel ? SeqStatus.none : target;
      }),
      scale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: BoxConstraints(minHeight: 36.h),
        padding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: sel && target == SeqStatus.confirmed
            ? BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(999),
              )
            : BoxDecoration(
                color: bg,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(999),
              ),
        child: Text(
          label,
          style: TextStyle(
              color: fg,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STICKY FOOTER
  // ═══════════════════════════════════════════════════════════

  Widget _buildStickyFooter() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepCount - 1;

    return Container(
      decoration: BoxDecoration(
        color: _t.surface,
        border: Border(top: BorderSide(color: _t.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(_stepCount, (i) {
                      final active = i <= _currentStep;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i < _stepCount - 1 ? 4.w : 0,
                          ),
                          height: 3.h,
                          decoration: active
                              ? BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(3.r),
                                )
                              : BoxDecoration(
                                  color: _t.progressTrack,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 6.h),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _t.textMuted,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Step ${_currentStep + 1}/$_stepCount: ',
                        ),
                        TextSpan(
                          text: _stepTitles[_currentStep],
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Row(
                children: [
                  _buildFooterBtn(
                    icon: LucideIcons.arrowLeft,
                    label: 'Prev',
                    onTap: isFirst ? null : _onPrev,
                    bg: _t.surfaceDeep,
                    fg: AppColors.primaryBlue,
                    border: _t.border,
                    disabled: isFirst,
                  ),
                  SizedBox(width: 8.w),
                  _buildFooterBtn(
                    icon: LucideIcons.save,
                    label: 'Save draft',
                    onTap: _submitForm,
                    bg: _t.surfaceDeep,
                    fg: AppColors.primaryBlue,
                    border: _t.border,
                  ),
                  const Spacer(),
                  _buildFooterBtn(
                    label: isLast ? 'Submit' : 'Next',
                    icon: isLast ? LucideIcons.send : LucideIcons.arrowRight,
                    iconTrailing: true,
                    onTap: _onNext,
                    bg: AppColors.primaryBlue,
                    fg: Colors.white,
                    border: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBtn({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required Color bg,
    required Color fg,
    required Color border,
    bool iconTrailing = false,
    bool disabled = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? [
        Text(label,
            style: TextStyle(
                color: fg,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700)),
        SizedBox(width: 6.w),
        Icon(icon, color: fg, size: 15.sp),
      ]
          : [
        Icon(icon, color: fg, size: 15.sp),
        SizedBox(width: 6.w),
        Text(label,
            style: TextStyle(
                color: fg,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700)),
      ],
    );

    return PressableScale(
      onTap: disabled ? null : onTap,
      scale: disabled ? 1.0 : 0.97,
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          constraints: BoxConstraints(minHeight: 46.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bg,
            border: border == Colors.transparent
                ? null
                : Border.all(color: border),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: content,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _t.base,
          appBar: _buildAppBar(),
          body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPageHeader(),
                  SizedBox(height: 16.h),
                  _buildInfoCard(),
                  SizedBox(height: 8.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(),
                  ),
                ],
              ),
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
        );
      },
    );
  }
}