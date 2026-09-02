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

/// Lightning / LD inspection form — Information, Customer Details, Visual Inspection.
class LdFormPage extends StatefulWidget {
  const LdFormPage({
    super.key,
    this.workOrderId = '',
    this.workOrderLabel = '',
    this.workTypeId = 'ld_form',
    this.saId = '',
  });

  /// Salesforce / source work order id from job details.
  final String workOrderId;

  /// Display label (appointment number) when available.
  final String workOrderLabel;

  /// Form identifier for API endpoint / Firebase schema.
  final String workTypeId;

  /// Service Appointment id.
  final String saId;

  @override
  State<LdFormPage> createState() => _LdFormPageState();
}

class _LdFormPageState extends State<LdFormPage>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Risk & HSE',
    'Information',
    'Customer Details',
    'Compulsory Visual Inspection',
  ];

  final _hse = HseRiskFormController();
  static const _weatherOptions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Windy',
    'Foggy',
    'Other',
  ];

  /// Placeholder lists until search APIs are wired.
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

  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  final _formNameController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _frontOfPropertyController = TextEditingController();
  final _visualImageDescController = TextEditingController();
  final _visualFindingsController = TextEditingController();
  final _weatherOtherController = TextEditingController();
  final _appointmentSearchController = TextEditingController();
  final _operativeSearchController = TextEditingController();

  String? _selectedAppointment;
  String? _selectedOperative;
  String? _selectedWeather;
  DateTime? _surveyDateTime;
  String? _dateTimeError;

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
    _formNameController.text = 'LD Form';
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
          if (answers['service_appointment'] != null) {
            _selectedAppointment = answers['service_appointment'] as String?;
          }
          if (answers['operative'] != null) {
            _selectedOperative = answers['operative'] as String?;
          }
          if (answers['weather'] != null) {
            _selectedWeather = answers['weather'] as String?;
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
      Log('Failed to restore draft for LD form: $e', name: 'LdFormPage');
    }
  }

  Map<String, dynamic> _buildAnswersMap() => {
        'form_name': _formNameController.text.trim(),
        'pdf_url': _pdfUrlController.text.trim(),
        'service_appointment': _selectedAppointment,
        'operative': _selectedOperative,
        'front_of_property': _frontOfPropertyController.text.trim(),
        'weather': _selectedWeather,
        'weather_other': _weatherOtherController.text.trim(),
        'survey_date_time': _surveyDateTime?.toIso8601String(),
        'visual_image_desc': _visualImageDescController.text.trim(),
        'visual_findings': _visualFindingsController.text.trim(),
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
    _frontOfPropertyController.dispose();
    _visualImageDescController.dispose();
    _visualFindingsController.dispose();
    _weatherOtherController.dispose();
    _appointmentSearchController.dispose();
    _operativeSearchController.dispose();
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
    final now = DateTime.now();
    // Allow same minute; reject strictly earlier.
    return value.isBefore(now.subtract(const Duration(seconds: 30)));
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$weekday, ${dt.day} $month ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      existing.hour,
      existing.minute,
    );
    _applySurveyDateTime(combined);
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
      _formNameController.text = 'LD Form';
      _pdfUrlController.clear();
      _frontOfPropertyController.clear();
      _visualImageDescController.clear();
      _visualFindingsController.clear();
      _weatherOtherController.clear();
      _appointmentSearchController.clear();
      _operativeSearchController.clear();
      _selectedAppointment = null;
      _selectedOperative = null;
      _selectedWeather = null;
      _surveyDateTime = null;
      _dateTimeError = null;
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
            'LD Form draft saved — ready for another.',
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
            reportType: 'LD',
            reportSuffix: 'ld_form',
            answers: answers,
            photoSlots: const {},
          );
        } catch (e) {
          Log('Submit form failed: $e', name: 'LdFormPage');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'LD Form submitted successfully.',
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
                            _buildHseTab(theme),
                            _buildInformationTab(theme),
                            _buildCustomerTab(theme),
                            _buildVisualTab(theme),
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
                                'LD Form',
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
            'LD Form',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
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

  Widget _buildHseTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        HseRiskSection(
          theme: theme,
          controller: _hse,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildInformationTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        _labeledField(
          theme: theme,
          label: 'LD Form Name',
          child: _textField(
            theme: theme,
            controller: _formNameController,
            hint: 'Enter LD form name',
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
          label: 'LD Form PDF Url',
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
      ],
    );
  }

  Widget _buildCustomerTab(DashboardTheme theme) {
    final dateLabel = _surveyDateTime == null
        ? 'Select date'
        : _formatDate(_surveyDateTime!);
    final timeLabel = _surveyDateTime == null
        ? 'Select time'
        : _formatTime(_surveyDateTime!);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
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
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.errorText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualTab(DashboardTheme theme) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
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
            hint: 'Record findings from the visual inspection…',
          ),
        ),
        SizedBox(height: 14.h),
        _labeledField(
          theme: theme,
          label: 'How is the weather during survey',
          child: _simpleDropdown(
            theme: theme,
            value: _selectedWeather,
            items: _weatherOptions,
            hint: 'Select weather',
            onChanged: (v) => setState(() => _selectedWeather = v),
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
              child: Text(item),
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
