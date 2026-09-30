import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_additional_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_conclusion_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_customer_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_drying_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_estimate_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_info_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_repair_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/steps/damp_visual_step.dart';
import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/screens/forms/widgets/hse_risk_section.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Damp Survey Form — modularized multi-tab inspection with repair, estimate, drying & conclusion.
class DampSurveyFormPage extends StatefulWidget {
  const DampSurveyFormPage({
    super.key,
    this.workOrderId = '',
    this.workOrderLabel = '',
    this.workTypeId = 'damp_survey',
    this.saId = '',
  });

  final String workOrderId;
  final String workOrderLabel;
  final String workTypeId;
  final String saId;

  @override
  State<DampSurveyFormPage> createState() => _DampSurveyFormPageState();
}

class _DampSurveyFormPageState extends State<DampSurveyFormPage>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Risk & HSE',
    'Information',
    'Customer Details',
    'Compulsory Visual Inspection',
    'Repair',
    'Estimate',
    'Drying',
    'Additional Comments',
    'Conclusion',
  ];

  final _hse = HseRiskFormController();

  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  // Step 2: Information
  final _formNameController = TextEditingController(text: 'Damp Survey Form');
  final _pdfUrlController = TextEditingController();
  final _appointmentSearchController = TextEditingController();

  // Step 3: Customer Details
  final _operativeSearchController = TextEditingController();
  final _frontOfPropertyController = TextEditingController();

  // Step 4: Compulsory Visual Inspection
  final _visualImageDescController = TextEditingController();
  final _visualFindingsController = TextEditingController();
  final _weatherOtherController = TextEditingController();
  final _accessMadeOtherController = TextEditingController();
  final _whatAccessedOtherController = TextEditingController();
  final _afterAccessImageDescController = TextEditingController();

  // Step 5: Repair
  final _beforeRepairPhotoDescController = TextEditingController();
  final _worksUndertakenController = TextEditingController();
  final _repairDurationController = TextEditingController();
  final _materialsUsedController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _afterRepairImageDescController = TextEditingController();

  // Step 6: Estimate
  final _furtherWorksDescController = TextEditingController();

  // Step 8: Additional Comments
  final _additionalCommentsController = TextEditingController();

  // Step 9: Conclusion
  final _leakDescriptionController = TextEditingController();
  final _briefImageDescController = TextEditingController();
  final _furtherVisitOtherController = TextEditingController();
  final _leakPresentController = TextEditingController();

  String? _selectedAppointment;
  String? _selectedOperative;
  DateTime? _surveyDateTime;
  String? _dateTimeError;

  String? _weather;
  String? _accessType;
  String? _accessLocation;
  String? _whatAccessed;

  String? _didMakeRepair;
  String? _repairKind;
  String? _boughtMaterials;

  String? _furtherWorkRequired;
  String? _dryingRequired;
  String? _dryingOption;
  String? _needAdditionalComments;
  String? _conclusion;
  String? _furtherVisitRequired;
  final Set<String> _diagnosisMethods = {};

  final _jobs = JobsRepository();

  String get _effectiveSaId {
    if (widget.saId.trim().isNotEmpty) return widget.saId.trim();
    if (widget.workOrderId.trim().isNotEmpty) return widget.workOrderId.trim();
    return '';
  }

  String get _workOrderDisplay {
    if (widget.workOrderLabel.trim().isNotEmpty) {
      return widget.workOrderLabel.trim();
    }
    if (widget.workOrderId.trim().isNotEmpty) {
      return widget.workOrderId.trim();
    }
    return '—';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final saId = _effectiveSaId;
    if (saId.isEmpty) return;
    try {
      final draft = await _jobs.fetchFormDraft(
        saId: saId,
        workTypeId: widget.workTypeId,
      );
      if (draft != null && mounted) {
        final answers = draft.answers;
        setState(() {
          if (answers['form_name'] != null) {
            _formNameController.text = answers['form_name'].toString();
          }
          if (answers['pdf_url'] != null) {
            _pdfUrlController.text = answers['pdf_url'].toString();
          }
          if (answers['front_of_property'] != null) {
            _frontOfPropertyController.text = answers['front_of_property']
                .toString();
          }
          if (answers['visual_image_desc'] != null) {
            _visualImageDescController.text = answers['visual_image_desc']
                .toString();
          }
          if (answers['visual_findings'] != null) {
            _visualFindingsController.text = answers['visual_findings']
                .toString();
          }
          if (answers['weather_other'] != null) {
            _weatherOtherController.text = answers['weather_other'].toString();
          }
          if (answers['access_made_other'] != null) {
            _accessMadeOtherController.text = answers['access_made_other']
                .toString();
          }
          if (answers['what_accessed_other'] != null) {
            _whatAccessedOtherController.text = answers['what_accessed_other']
                .toString();
          }
          if (answers['after_access_image_desc'] != null) {
            _afterAccessImageDescController.text =
                answers['after_access_image_desc'].toString();
          }
          if (answers['before_repair_photo_desc'] != null) {
            _beforeRepairPhotoDescController.text =
                answers['before_repair_photo_desc'].toString();
          }
          if (answers['works_undertaken'] != null) {
            _worksUndertakenController.text = answers['works_undertaken']
                .toString();
          }
          if (answers['repair_duration'] != null) {
            _repairDurationController.text = answers['repair_duration']
                .toString();
          }
          if (answers['materials_used'] != null) {
            _materialsUsedController.text = answers['materials_used']
                .toString();
          }
          if (answers['material_cost'] != null) {
            _materialCostController.text = answers['material_cost'].toString();
          }
          if (answers['after_repair_image_desc'] != null) {
            _afterRepairImageDescController.text =
                answers['after_repair_image_desc'].toString();
          }
          if (answers['further_works_desc'] != null) {
            _furtherWorksDescController.text = answers['further_works_desc']
                .toString();
          }
          if (answers['additional_comments'] != null) {
            _additionalCommentsController.text = answers['additional_comments']
                .toString();
          }
          if (answers['leak_description'] != null) {
            _leakDescriptionController.text = answers['leak_description']
                .toString();
          }
          if (answers['brief_image_desc'] != null) {
            _briefImageDescController.text = answers['brief_image_desc']
                .toString();
          }
          if (answers['further_visit_other'] != null) {
            _furtherVisitOtherController.text = answers['further_visit_other']
                .toString();
          }
          if (answers['leak_present'] != null) {
            _leakPresentController.text = answers['leak_present'].toString();
          }
          if (answers['service_appointment'] != null) {
            _selectedAppointment = answers['service_appointment'] as String?;
          }
          if (answers['operative'] != null) {
            _selectedOperative = answers['operative'] as String?;
          }
          if (answers['weather'] != null) {
            _weather = answers['weather'] as String?;
          }
          if (answers['access_type'] != null) {
            _accessType = answers['access_type'] as String?;
          }
          if (answers['access_location'] != null) {
            _accessLocation = answers['access_location'] as String?;
          }
          if (answers['what_accessed'] != null) {
            _whatAccessed = answers['what_accessed'] as String?;
          }
          if (answers['did_make_repair'] != null) {
            _didMakeRepair = answers['did_make_repair'] as String?;
          }
          if (answers['repair_kind'] != null) {
            _repairKind = answers['repair_kind'] as String?;
          }
          if (answers['bought_materials'] != null) {
            _boughtMaterials = answers['bought_materials'] as String?;
          }
          if (answers['further_work_required'] != null) {
            _furtherWorkRequired = answers['further_work_required'] as String?;
          }
          if (answers['drying_required'] != null) {
            _dryingRequired = answers['drying_required'] as String?;
          }
          if (answers['drying_option'] != null) {
            _dryingOption = answers['drying_option'] as String?;
          }
          if (answers['need_additional_comments'] != null) {
            _needAdditionalComments =
                answers['need_additional_comments'] as String?;
          }
          if (answers['conclusion'] != null) {
            _conclusion = answers['conclusion'] as String?;
          }
          if (answers['further_visit_required'] != null) {
            _furtherVisitRequired =
                answers['further_visit_required'] as String?;
          }
          if (answers['diagnosis_methods'] is List) {
            _diagnosisMethods.clear();
            _diagnosisMethods.addAll(
              (answers['diagnosis_methods'] as List).map((e) => e.toString()),
            );
          }
          if (answers['survey_date_time'] != null) {
            _surveyDateTime = DateTime.tryParse(
              answers['survey_date_time'].toString(),
            );
          }
          final rawHse = answers['hse'];
          if (rawHse is Map) {
            _hse.fromMap(Map<String, dynamic>.from(rawHse));
          }
          if (draft.step > 0 && draft.step < _tabs.length) {
            _tabController.index = draft.step;
          }
        });
      }
    } catch (e) {
      Log(
        'Failed to restore draft for Damp Survey form: $e',
        name: 'DampSurveyFormPage',
      );
    }
  }

  Map<String, dynamic> _buildAnswersMap() => {
    'form_name': _formNameController.text.trim(),
    'pdf_url': _pdfUrlController.text.trim(),
    'service_appointment': _selectedAppointment,
    'operative': _selectedOperative,
    'front_of_property': _frontOfPropertyController.text.trim(),
    'weather': _weather,
    'weather_other': _weatherOtherController.text.trim(),
    'survey_date_time': _surveyDateTime?.toIso8601String(),
    'access_type': _accessType,
    'access_location': _accessLocation,
    'access_made_other': _accessMadeOtherController.text.trim(),
    'what_accessed': _whatAccessed,
    'what_accessed_other': _whatAccessedOtherController.text.trim(),
    'visual_image_desc': _visualImageDescController.text.trim(),
    'visual_findings': _visualFindingsController.text.trim(),
    'after_access_image_desc': _afterAccessImageDescController.text.trim(),
    'did_make_repair': _didMakeRepair,
    'repair_kind': _repairKind,
    'before_repair_photo_desc': _beforeRepairPhotoDescController.text.trim(),
    'works_undertaken': _worksUndertakenController.text.trim(),
    'repair_duration': _repairDurationController.text.trim(),
    'bought_materials': _boughtMaterials,
    'materials_used': _materialsUsedController.text.trim(),
    'material_cost': _materialCostController.text.trim(),
    'after_repair_image_desc': _afterRepairImageDescController.text.trim(),
    'further_work_required': _furtherWorkRequired,
    'further_works_desc': _furtherWorksDescController.text.trim(),
    'drying_required': _dryingRequired,
    'drying_option': _dryingOption,
    'need_additional_comments': _needAdditionalComments,
    'additional_comments': _additionalCommentsController.text.trim(),
    'conclusion': _conclusion,
    'leak_description': _leakDescriptionController.text.trim(),
    'brief_image_desc': _briefImageDescController.text.trim(),
    'further_visit_required': _furtherVisitRequired,
    'further_visit_other': _furtherVisitOtherController.text.trim(),
    'leak_present': _leakPresentController.text.trim(),
    'diagnosis_methods': _diagnosisMethods.toList(),
    'hse': _hse.toMap(),
  };

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _formNameController.dispose();
    _pdfUrlController.dispose();
    _appointmentSearchController.dispose();
    _operativeSearchController.dispose();
    _frontOfPropertyController.dispose();
    _visualImageDescController.dispose();
    _visualFindingsController.dispose();
    _weatherOtherController.dispose();
    _accessMadeOtherController.dispose();
    _whatAccessedOtherController.dispose();
    _afterAccessImageDescController.dispose();
    _beforeRepairPhotoDescController.dispose();
    _worksUndertakenController.dispose();
    _repairDurationController.dispose();
    _materialsUsedController.dispose();
    _materialCostController.dispose();
    _afterRepairImageDescController.dispose();
    _furtherWorksDescController.dispose();
    _additionalCommentsController.dispose();
    _leakDescriptionController.dispose();
    _briefImageDescController.dispose();
    _furtherVisitOtherController.dispose();
    _leakPresentController.dispose();
    _hse.dispose();
    super.dispose();
  }

  void _onScroll() {
    final raw = (_scrollController.offset / _scrollThreshold).clamp(0.0, 1.0);
    final progress = Curves.easeOutCubic.transform(raw);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  bool _isPastDateTime(DateTime value) {
    return value.isBefore(DateTime.now().subtract(const Duration(seconds: 30)));
  }

  Future<void> _pickSurveyDate() async {
    final theme = DashboardTheme.of(context);
    final now = DateTime.now();
    var draft = _surveyDateTime ?? now;
    if (_isPastDateTime(draft)) draft = now;

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (sheetContext) {
        return Container(
          height: 320.h,
          decoration: BoxDecoration(
            color: theme.dashCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              _pickerHeader(
                theme: theme,
                title: 'Survey date',
                onCancel: () => Navigator.pop(sheetContext),
                onDone: () => Navigator.pop(sheetContext, draft),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 22.sp,
                        color: theme.dashTitle,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: draft,
                    minimumDate: DateTime(now.year, now.month, now.day),
                    onDateTimeChanged: (value) => draft = value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;
    final existing = _surveyDateTime ?? now;
    _applySurveyDateTime(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        existing.hour,
        existing.minute,
      ),
    );
  }

  Future<void> _pickSurveyTime() async {
    final theme = DashboardTheme.of(context);
    final now = DateTime.now();
    final baseDate = _surveyDateTime ?? now;
    var draft = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      (_surveyDateTime ?? now).hour,
      (_surveyDateTime ?? now).minute,
    );
    if (_isPastDateTime(draft)) {
      draft = now.add(const Duration(minutes: 1));
    }

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (sheetContext) {
        return Container(
          height: 320.h,
          decoration: BoxDecoration(
            color: theme.dashCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              _pickerHeader(
                theme: theme,
                title: 'Survey time',
                onCancel: () => Navigator.pop(sheetContext),
                onDone: () => Navigator.pop(sheetContext, draft),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 22.sp,
                        color: theme.dashTitle,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: draft,
                    use24hFormat: true,
                    onDateTimeChanged: (value) {
                      draft = DateTime(
                        baseDate.year,
                        baseDate.month,
                        baseDate.day,
                        value.hour,
                        value.minute,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;
    _applySurveyDateTime(picked);
  }

  void _applySurveyDateTime(DateTime value) {
    setState(() {
      if (_isPastDateTime(value)) {
        _dateTimeError = 'Survey date/time cannot be in the past.';
        _surveyDateTime = value;
      } else {
        _dateTimeError = null;
        _surveyDateTime = value;
      }
    });
  }

  Widget _pickerHeader({
    required DashboardTheme theme,
    required String title,
    required VoidCallback onCancel,
    required VoidCallback onDone,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dashBorderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 16.sp, color: theme.dashSubtitle),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.dashTitle,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onDone,
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.dashPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForSave() {
    if (_surveyDateTime != null && _isPastDateTime(_surveyDateTime!)) {
      setState(() {
        _dateTimeError = 'Survey date/time cannot be in the past.';
        _tabController.index = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please choose a survey date/time that is not in the past.',
            style: TextStyle(fontSize: 14.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.errorText,
        ),
      );
      return false;
    }
    return true;
  }

  void _resetForm() {
    setState(() {
      _formNameController.text = 'Damp Survey Form';
      _pdfUrlController.clear();
      _appointmentSearchController.clear();
      _operativeSearchController.clear();
      _frontOfPropertyController.clear();
      _visualImageDescController.clear();
      _visualFindingsController.clear();
      _weatherOtherController.clear();
      _accessMadeOtherController.clear();
      _whatAccessedOtherController.clear();
      _afterAccessImageDescController.clear();
      _beforeRepairPhotoDescController.clear();
      _worksUndertakenController.clear();
      _repairDurationController.clear();
      _materialsUsedController.clear();
      _materialCostController.clear();
      _afterRepairImageDescController.clear();
      _furtherWorksDescController.clear();
      _additionalCommentsController.clear();
      _leakDescriptionController.clear();
      _briefImageDescController.clear();
      _furtherVisitOtherController.clear();
      _leakPresentController.clear();
      _selectedAppointment = null;
      _selectedOperative = null;
      _surveyDateTime = null;
      _dateTimeError = null;
      _weather = null;
      _accessType = null;
      _accessLocation = null;
      _whatAccessed = null;
      _didMakeRepair = null;
      _repairKind = null;
      _boughtMaterials = null;
      _furtherWorkRequired = null;
      _dryingRequired = null;
      _dryingOption = null;
      _needAdditionalComments = null;
      _conclusion = null;
      _furtherVisitRequired = null;
      _diagnosisMethods.clear();
      _hse.clear();
      _tabController.index = 0;
    });
  }

  void _onCancel() => Navigator.of(context).maybePop(false);

  Future<void> _onSave({required bool andNew}) async {
    final saId = _effectiveSaId;
    final answers = _buildAnswersMap();

    if (andNew) {
      if (saId.isNotEmpty) {
        await _jobs.saveFormDraft(
          saId: saId,
          workTypeId: widget.workTypeId,
          answers: answers,
          step: _tabController.index,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Damp Survey form draft saved — ready for another.',
            style: TextStyle(fontSize: 14.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      _resetForm();
    } else {
      if (!_validateForSave()) return;
      if (saId.isNotEmpty) {
        try {
          await _jobs.submitForm(
            saId: saId,
            workTypeId: widget.workTypeId,
            reportType: 'DAMP_SURVEY',
            reportSuffix: 'damp_survey',
            answers: answers,
            photoSlots: const {},
          );
        } catch (e) {
          Log('Submit damp survey form failed: $e', name: 'DampSurveyFormPage');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Damp Survey form submitted successfully.',
            style: TextStyle(fontSize: 14.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
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
                          SliverToBoxAdapter(child: _buildTitle(theme)),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: DampSurveyTabBarDelegate(
                              theme: theme,
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.primaryBlue,
                                unselectedLabelColor: theme.textMuted,
                                indicatorColor: AppColors.primaryBlue,
                                labelStyle: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 12.sp,
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
                            ListView(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                16.h,
                                16.w,
                                24.h,
                              ),
                              children: [
                                HseRiskSection(
                                  theme: theme,
                                  controller: _hse,
                                  onChanged: () => setState(() {}),
                                ),
                              ],
                            ),
                            DampInfoStep(
                              theme: theme,
                              formNameController: _formNameController,
                              workOrderDisplay: _workOrderDisplay,
                              pdfUrlController: _pdfUrlController,
                              selectedAppointment: _selectedAppointment,
                              appointmentSearchController:
                                  _appointmentSearchController,
                              onAppointmentChanged: (v) =>
                                  setState(() => _selectedAppointment = v),
                            ),
                            DampCustomerStep(
                              theme: theme,
                              selectedOperative: _selectedOperative,
                              operativeSearchController:
                                  _operativeSearchController,
                              frontOfPropertyController:
                                  _frontOfPropertyController,
                              surveyDateTime: _surveyDateTime,
                              dateTimeError: _dateTimeError,
                              onOperativeChanged: (v) =>
                                  setState(() => _selectedOperative = v),
                              onPickDate: _pickSurveyDate,
                              onPickTime: _pickSurveyTime,
                            ),
                            DampVisualStep(
                              theme: theme,
                              visualImageDescController:
                                  _visualImageDescController,
                              visualFindingsController:
                                  _visualFindingsController,
                              weather: _weather,
                              weatherOtherController: _weatherOtherController,
                              accessType: _accessType,
                              accessLocation: _accessLocation,
                              accessMadeOtherController:
                                  _accessMadeOtherController,
                              whatAccessed: _whatAccessed,
                              whatAccessedOtherController:
                                  _whatAccessedOtherController,
                              afterAccessImageDescController:
                                  _afterAccessImageDescController,
                              onWeatherChanged: (v) =>
                                  setState(() => _weather = v),
                              onAccessTypeChanged: (v) =>
                                  setState(() => _accessType = v),
                              onAccessLocationChanged: (v) =>
                                  setState(() => _accessLocation = v),
                              onWhatAccessedChanged: (v) =>
                                  setState(() => _whatAccessed = v),
                            ),
                            DampRepairStep(
                              theme: theme,
                              didMakeRepair: _didMakeRepair,
                              beforeRepairPhotoDescController:
                                  _beforeRepairPhotoDescController,
                              repairKind: _repairKind,
                              worksUndertakenController:
                                  _worksUndertakenController,
                              repairDurationController:
                                  _repairDurationController,
                              materialsUsedController: _materialsUsedController,
                              boughtMaterials: _boughtMaterials,
                              materialCostController: _materialCostController,
                              afterRepairImageDescController:
                                  _afterRepairImageDescController,
                              onDidMakeRepairChanged: (v) =>
                                  setState(() => _didMakeRepair = v),
                              onRepairKindChanged: (v) =>
                                  setState(() => _repairKind = v),
                              onBoughtMaterialsChanged: (v) =>
                                  setState(() => _boughtMaterials = v),
                            ),
                            DampEstimateStep(
                              theme: theme,
                              furtherWorkRequired: _furtherWorkRequired,
                              furtherWorksDescController:
                                  _furtherWorksDescController,
                              onFurtherWorkRequiredChanged: (v) =>
                                  setState(() => _furtherWorkRequired = v),
                            ),
                            DampDryingStep(
                              theme: theme,
                              dryingRequired: _dryingRequired,
                              dryingOption: _dryingOption,
                              onDryingRequiredChanged: (v) =>
                                  setState(() => _dryingRequired = v),
                              onDryingOptionChanged: (v) =>
                                  setState(() => _dryingOption = v),
                            ),
                            DampAdditionalStep(
                              theme: theme,
                              needAdditionalComments: _needAdditionalComments,
                              additionalCommentsController:
                                  _additionalCommentsController,
                              onNeedAdditionalCommentsChanged: (v) =>
                                  setState(() => _needAdditionalComments = v),
                            ),
                            DampConclusionStep(
                              theme: theme,
                              conclusion: _conclusion,
                              leakDescriptionController:
                                  _leakDescriptionController,
                              briefImageDescController:
                                  _briefImageDescController,
                              furtherVisitRequired: _furtherVisitRequired,
                              furtherVisitOtherController:
                                  _furtherVisitOtherController,
                              leakPresentController: _leakPresentController,
                              diagnosisMethods: _diagnosisMethods,
                              onConclusionChanged: (v) =>
                                  setState(() => _conclusion = v),
                              onFurtherVisitRequiredChanged: (v) =>
                                  setState(() => _furtherVisitRequired = v),
                              onToggleDiagnosisMethod: (option) {
                                setState(() {
                                  if (_diagnosisMethods.contains(option)) {
                                    _diagnosisMethods.remove(option);
                                  } else {
                                    _diagnosisMethods.add(option);
                                  }
                                });
                              },
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
                                'Damp Survey',
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
                        top: 8.h,
                        left: 16.w,
                        child: CommandCentreBackButton(onTap: _onCancel),
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Damp Survey Form',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Surface / depth readings · BS 5250:2021',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DashboardTheme theme) {
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
          SizedBox(width: 8.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onSave(andNew: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('Save & New', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onSave(andNew: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
