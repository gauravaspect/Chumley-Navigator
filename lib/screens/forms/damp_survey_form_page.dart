import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/screens/forms/widgets/hse_risk_section.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Damp Survey Form — multi-tab inspection with repair, estimate, drying & conclusion.
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

  static const _serviceAppointments = [
    'SA-10021 · 12 High Street',
    'SA-10045 · 4 Station Road',
    'SA-10088 · Flat 2B Oak Court',
    'SA-10102 · 19 Mill Lane',
  ];

  static const _people = [
    'Alex Morgan',
    'Jordan Lee',
    'Sam Patel',
    'Taylor Brooks',
    'Casey Nguyen',
  ];

  static const _weatherOptions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Windy',
    'Foggy',
    'Other',
  ];

  static const _accessTypeOptions = ['Internal', 'External', 'Both'];
  static const _accessLocationOptions = [
    'Roof space',
    'Floor void',
    'Wall cavity',
    'Under stairs',
    'Cupboard',
    'Other',
  ];
  static const _whatAccessedOptions = [
    'Pipework',
    'Tank',
    'Radiator',
    'Floorboards',
    'Ceiling',
    'Wall',
    'Other',
  ];
  static const _yesNoOptions = ['Yes', 'No'];
  static const _yesNoPartialOptions = ['Yes', 'No', 'Partial'];
  static const _repairKindOptions = [
    'Temporary',
    'Permanent',
    'Make-safe',
    'Other',
  ];
  static const _furtherWorkOptions = ['Yes', 'No', 'Monitor'];
  static const _dryingRequiredOptions = ['Yes', 'No'];
  static const _dryingMethodOptions = [
    'Dehumidifier',
    'Fans',
    'Natural ventilation',
    'Specialist drying',
    'Not applicable',
  ];
  static const _conclusionOptions = [
    'Rising damp',
    'Penetrating damp',
    'Condensation',
    'Plumbing leak',
    'Combination',
    'Inconclusive',
  ];
  static const _furtherVisitOptions = [
    'Yes',
    'No',
    'Monitor only',
    'Other',
  ];
  static const _diagnosisMethodOptions = [
    'Thermal imaging',
    'Moisture profiling',
    'Trace dye',
    'Salt analysis',
    'Camera inspection',
    'Pressure test',
    'Other',
  ];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  // Information
  final _formNameController = TextEditingController(text: 'Damp Survey Form');
  final _pdfUrlController = TextEditingController();
  final _appointmentSearchController = TextEditingController();

  // Customer
  final _operativeSearchController = TextEditingController();
  final _frontOfPropertyController = TextEditingController();

  // Visual
  final _visualImageDescController = TextEditingController();
  final _visualFindingsController = TextEditingController();
  final _weatherOtherController = TextEditingController();
  final _accessMadeOtherController = TextEditingController();
  final _whatAccessedOtherController = TextEditingController();
  final _afterAccessImageDescController = TextEditingController();

  // Repair
  final _beforeRepairPhotoDescController = TextEditingController();
  final _worksUndertakenController = TextEditingController();
  final _repairDurationController = TextEditingController();
  final _materialsUsedController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _afterRepairImageDescController = TextEditingController();

  // Estimate
  final _furtherWorksDescController = TextEditingController();

  // Additional
  final _additionalCommentsController = TextEditingController();

  // Conclusion
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
            _frontOfPropertyController.text = answers['front_of_property'].toString();
          }
          if (answers['visual_image_desc'] != null) {
            _visualImageDescController.text = answers['visual_image_desc'].toString();
          }
          if (answers['visual_findings'] != null) {
            _visualFindingsController.text = answers['visual_findings'].toString();
          }
          if (answers['weather_other'] != null) {
            _weatherOtherController.text = answers['weather_other'].toString();
          }
          if (answers['access_made_other'] != null) {
            _accessMadeOtherController.text = answers['access_made_other'].toString();
          }
          if (answers['what_accessed_other'] != null) {
            _whatAccessedOtherController.text = answers['what_accessed_other'].toString();
          }
          if (answers['after_access_image_desc'] != null) {
            _afterAccessImageDescController.text = answers['after_access_image_desc'].toString();
          }
          if (answers['before_repair_photo_desc'] != null) {
            _beforeRepairPhotoDescController.text = answers['before_repair_photo_desc'].toString();
          }
          if (answers['works_undertaken'] != null) {
            _worksUndertakenController.text = answers['works_undertaken'].toString();
          }
          if (answers['repair_duration'] != null) {
            _repairDurationController.text = answers['repair_duration'].toString();
          }
          if (answers['materials_used'] != null) {
            _materialsUsedController.text = answers['materials_used'].toString();
          }
          if (answers['material_cost'] != null) {
            _materialCostController.text = answers['material_cost'].toString();
          }
          if (answers['after_repair_image_desc'] != null) {
            _afterRepairImageDescController.text = answers['after_repair_image_desc'].toString();
          }
          if (answers['further_works_desc'] != null) {
            _furtherWorksDescController.text = answers['further_works_desc'].toString();
          }
          if (answers['additional_comments'] != null) {
            _additionalCommentsController.text = answers['additional_comments'].toString();
          }
          if (answers['leak_description'] != null) {
            _leakDescriptionController.text = answers['leak_description'].toString();
          }
          if (answers['brief_image_desc'] != null) {
            _briefImageDescController.text = answers['brief_image_desc'].toString();
          }
          if (answers['further_visit_other'] != null) {
            _furtherVisitOtherController.text = answers['further_visit_other'].toString();
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
            _needAdditionalComments = answers['need_additional_comments'] as String?;
          }
          if (answers['conclusion'] != null) {
            _conclusion = answers['conclusion'] as String?;
          }
          if (answers['further_visit_required'] != null) {
            _furtherVisitRequired = answers['further_visit_required'] as String?;
          }
          if (answers['diagnosis_methods'] is List) {
            _diagnosisMethods.clear();
            _diagnosisMethods.addAll((answers['diagnosis_methods'] as List).map((e) => e.toString()));
          }
          if (answers['survey_date_time'] != null) {
            _surveyDateTime = DateTime.tryParse(answers['survey_date_time'].toString());
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
      Log('Failed to restore draft for Damp Survey form: $e', name: 'DampSurveyFormPage');
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

  static double _easedCollapseProgress(double offset) {
    final raw = (offset / _scrollThreshold).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  void _onScroll() {
    final progress = _easedCollapseProgress(_scrollController.offset);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  bool _isPastDateTime(DateTime value) {
    return value.isBefore(DateTime.now().subtract(const Duration(seconds: 30)));
  }

  String _formatDate(DateTime dt) {
    return '${_weekdays[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
      // Save Draft mode
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
      // Submit mode
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
                            delegate: _TabBarDelegate(
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
                            _scrollTab(_buildHseTab(theme)),
                            _scrollTab(_buildInformationTab(theme)),
                            _scrollTab(_buildCustomerTab(theme)),
                            _scrollTab(_buildVisualTab(theme)),
                            _scrollTab(_buildRepairTab(theme)),
                            _scrollTab(_buildEstimateTab(theme)),
                            _scrollTab(_buildDryingTab(theme)),
                            _scrollTab(_buildAdditionalTab(theme)),
                            _scrollTab(_buildConclusionTab(theme)),
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

  Widget _scrollTab(List<Widget> children) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: children,
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

  List<Widget> _buildHseTab(DashboardTheme theme) {
    return [
      HseRiskSection(
        theme: theme,
        controller: _hse,
        onChanged: () => setState(() {}),
      ),
    ];
  }

  List<Widget> _buildInformationTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Damp Survey Form Name',
        child: _textField(
          theme: theme,
          controller: _formNameController,
          hint: 'Enter form name',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Work Order',
        child: _readOnlyField(theme: theme, value: _workOrderDisplay),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Generated PDF Url',
        child: _textField(
          theme: theme,
          controller: _pdfUrlController,
          hint: 'https://…',
          keyboardType: TextInputType.url,
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Service Appointment',
        child: _searchableDropdown(
          theme: theme,
          value: _selectedAppointment,
          items: _serviceAppointments,
          hint: 'Search Service Appointments',
          searchController: _appointmentSearchController,
          onChanged: (v) => setState(() => _selectedAppointment = v),
        ),
      ),
    ];
  }

  List<Widget> _buildCustomerTab(DashboardTheme theme) {
    final dateLabel = _surveyDateTime == null
        ? 'Select date'
        : _formatDate(_surveyDateTime!);
    final timeLabel = _surveyDateTime == null
        ? 'Select time'
        : _formatTime(_surveyDateTime!);

    return [
      _labeledField(
        theme: theme,
        label: 'Operative Name',
        child: _searchableDropdown(
          theme: theme,
          value: _selectedOperative,
          items: _people,
          hint: 'Search People',
          searchController: _operativeSearchController,
          onChanged: (v) => setState(() => _selectedOperative = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description for image — Front of Property',
        child: _expandableField(
          theme: theme,
          controller: _frontOfPropertyController,
          hint: 'Describe the front-of-property image…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Survey Date / Time',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _pickerButton(
                    theme: theme,
                    icon: LucideIcons.calendar,
                    label: dateLabel,
                    onTap: _pickSurveyDate,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _pickerButton(
                    theme: theme,
                    icon: LucideIcons.clock,
                    label: timeLabel,
                    onTap: _pickSurveyTime,
                  ),
                ),
              ],
            ),
            if (_dateTimeError != null) ...[
              SizedBox(height: 8.h),
              Text(
                _dateTimeError!,
                style: TextStyle(fontSize: 12.sp, color: AppColors.errorText),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildVisualTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Description for visual inspection image',
        child: _expandableField(
          theme: theme,
          controller: _visualImageDescController,
          hint: 'Describe the visual inspection image…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Findings from visual inspection',
        child: _expandableField(
          theme: theme,
          controller: _visualFindingsController,
          hint: 'Record findings…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'How is the weather during survey',
        child: _simpleDropdown(
          theme: theme,
          value: _weather,
          items: _weatherOptions,
          hint: 'Select weather',
          onChanged: (v) => setState(() => _weather = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Weather other details',
        child: _expandableField(
          theme: theme,
          controller: _weatherOtherController,
          hint: 'Additional weather details…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Was the access internal or external',
        child: _simpleDropdown(
          theme: theme,
          value: _accessType,
          items: _accessTypeOptions,
          hint: 'Select access type',
          onChanged: (v) => setState(() => _accessType = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Where was this access made',
        child: _simpleDropdown(
          theme: theme,
          value: _accessLocation,
          items: _accessLocationOptions,
          hint: 'Select location',
          onChanged: (v) => setState(() => _accessLocation = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Access made other',
        child: _textField(
          theme: theme,
          controller: _accessMadeOtherController,
          hint: 'Other access details',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'What was accessed',
        child: _simpleDropdown(
          theme: theme,
          value: _whatAccessed,
          items: _whatAccessedOptions,
          hint: 'Select what was accessed',
          onChanged: (v) => setState(() => _whatAccessed = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'What was accessed other',
        child: _textField(
          theme: theme,
          controller: _whatAccessedOtherController,
          hint: 'Other details',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of image after access has been made',
        child: _expandableField(
          theme: theme,
          controller: _afterAccessImageDescController,
          hint: 'Describe the image after access…',
        ),
      ),
    ];
  }

  List<Widget> _buildRepairTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Did you make the repair',
        child: _simpleDropdown(
          theme: theme,
          value: _didMakeRepair,
          items: _yesNoPartialOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _didMakeRepair = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description for photo — Before repairs done',
        child: _expandableField(
          theme: theme,
          controller: _beforeRepairPhotoDescController,
          hint: 'Describe the before-repair photo…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'What kind of repair was done',
        child: _simpleDropdown(
          theme: theme,
          value: _repairKind,
          items: _repairKindOptions,
          hint: 'Select repair type',
          onChanged: (v) => setState(() => _repairKind = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of works undertaken',
        child: _textField(
          theme: theme,
          controller: _worksUndertakenController,
          hint: 'Describe works undertaken',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'How long it took to make the repairs',
        child: _textField(
          theme: theme,
          controller: _repairDurationController,
          hint: 'e.g. 2 hours',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Materials used during repairs',
        child: _textField(
          theme: theme,
          controller: _materialsUsedController,
          hint: 'List materials used',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Buy any materials to carry out repairs?',
        child: _simpleDropdown(
          theme: theme,
          value: _boughtMaterials,
          items: _yesNoOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _boughtMaterials = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'How much material costed for repairs',
        child: _textField(
          theme: theme,
          controller: _materialCostController,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of image after repairs carried out',
        child: _expandableField(
          theme: theme,
          controller: _afterRepairImageDescController,
          hint: 'Describe the after-repair image…',
        ),
      ),
    ];
  }

  List<Widget> _buildEstimateTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Further work required to restore area',
        child: _simpleDropdown(
          theme: theme,
          value: _furtherWorkRequired,
          items: _furtherWorkOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _furtherWorkRequired = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of further works required',
        child: _expandableField(
          theme: theme,
          controller: _furtherWorksDescController,
          hint: 'Describe further works…',
        ),
      ),
    ];
  }

  List<Widget> _buildDryingTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Does the area require drying',
        child: _simpleDropdown(
          theme: theme,
          value: _dryingRequired,
          items: _dryingRequiredOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _dryingRequired = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Please select the relevant options',
        child: _simpleDropdown(
          theme: theme,
          value: _dryingOption,
          items: _dryingMethodOptions,
          hint: 'Select drying option',
          onChanged: (v) => setState(() => _dryingOption = v),
        ),
      ),
    ];
  }

  List<Widget> _buildAdditionalTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Do you need to add additional comments',
        child: _simpleDropdown(
          theme: theme,
          value: _needAdditionalComments,
          items: _yesNoOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _needAdditionalComments = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Additional feedbacks / comments',
        child: _expandableField(
          theme: theme,
          controller: _additionalCommentsController,
          hint: 'Enter additional comments…',
        ),
      ),
    ];
  }

  List<Widget> _buildConclusionTab(DashboardTheme theme) {
    return [
      _labeledField(
        theme: theme,
        label: 'Following investigation what conclusion?',
        child: _simpleDropdown(
          theme: theme,
          value: _conclusion,
          items: _conclusionOptions,
          hint: 'Select conclusion',
          onChanged: (v) => setState(() => _conclusion = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of the leak',
        child: _expandableField(
          theme: theme,
          controller: _leakDescriptionController,
          hint: 'Describe the leak…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Brief image description',
        child: _textField(
          theme: theme,
          controller: _briefImageDescController,
          hint: 'Brief description',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Why is a further visit required',
        child: _simpleDropdown(
          theme: theme,
          value: _furtherVisitRequired,
          items: _furtherVisitOptions,
          hint: 'Select option',
          onChanged: (v) => setState(() => _furtherVisitRequired = v),
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Further visit required other',
        child: _expandableField(
          theme: theme,
          controller: _furtherVisitOtherController,
          hint: 'Other reasons for further visit…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Investigation leads to a leak be present',
        child: _expandableField(
          theme: theme,
          controller: _leakPresentController,
          hint: 'Describe investigation findings…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Method of diagnosis for next visit',
        child: _multiSelectChips(
          theme: theme,
          options: _diagnosisMethodOptions,
          selected: _diagnosisMethods,
          onToggle: (option) {
            setState(() {
              if (_diagnosisMethods.contains(option)) {
                _diagnosisMethods.remove(option);
              } else {
                _diagnosisMethods.add(option);
              }
            });
          },
        ),
      ),
    ];
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

  Widget _multiSelectChips({
    required DashboardTheme theme,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option, style: TextStyle(fontSize: 12.sp)),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
            selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primaryBlue,
            labelStyle: TextStyle(
              color: selected.contains(option)
                  ? AppColors.primaryBlue
                  : theme.text,
            ),
            side: BorderSide(
              color: selected.contains(option)
                  ? AppColors.primaryBlue
                  : theme.border,
            ),
            backgroundColor: theme.surfaceDeep,
          ),
      ],
    );
  }

  Widget _labeledField({
    required DashboardTheme theme,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(DashboardTheme theme, {String? hint}) {
    return InputDecoration(
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
        borderSide: BorderSide(color: theme.accent, width: 0.5),
      ),
    );
  }

  Widget _textField({
    required DashboardTheme theme,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      decoration: _inputDecoration(theme, hint: hint),
    );
  }

  Widget _expandableField({
    required DashboardTheme theme,
    required TextEditingController controller,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 8,
      style: TextStyle(fontSize: 13.sp, color: theme.text, height: 1.4),
      decoration: _inputDecoration(theme, hint: hint),
    );
  }

  Widget _readOnlyField({
    required DashboardTheme theme,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13.sp,
          color: theme.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _pickerButton({
    required DashboardTheme theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.surfaceDeep,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: theme.textMuted),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13.sp, color: theme.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _simpleDropdown({
    required DashboardTheme theme,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(theme),
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

  Widget _searchableDropdown({
    required DashboardTheme theme,
    required String? value,
    required List<String> items,
    required String hint,
    required TextEditingController searchController,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(theme),
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
      dropdownSearchData: DropdownSearchData(
        searchController: searchController,
        searchInnerWidgetHeight: 50.h,
        searchInnerWidget: Container(
          height: 50.h,
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 4.h),
          child: TextFormField(
            expands: true,
            maxLines: null,
            controller: searchController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 8.h,
              ),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12.sp, color: theme.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          final text = item.value?.toString().toLowerCase() ?? '';
          return text.contains(searchValue.toLowerCase());
        },
      ),
      onMenuStateChange: (isOpen) {
        if (!isOpen) searchController.clear();
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.theme, required this.child});

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
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      theme != oldDelegate.theme || child != oldDelegate.child;
}
