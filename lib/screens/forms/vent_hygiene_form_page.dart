import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/screens/forms/widgets/hse_risk_section.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vent Hygiene form — Information tab with costs, sub-operatives, and certificate.
class VentHygieneFormPage extends StatefulWidget {
  const VentHygieneFormPage({
    super.key,
    this.workOrderId = '',
    this.workOrderLabel = '',
  });

  final String workOrderId;
  final String workOrderLabel;

  @override
  State<VentHygieneFormPage> createState() => _VentHygieneFormPageState();
}

class _SubOperativeControllers {
  _SubOperativeControllers()
      : name = TextEditingController(),
        travelHours = TextEditingController(),
        totalCost = TextEditingController();

  final TextEditingController name;
  final TextEditingController travelHours;
  final TextEditingController totalCost;

  void dispose() {
    name.dispose();
    travelHours.dispose();
    totalCost.dispose();
  }

  void clear() {
    name.clear();
    travelHours.clear();
    totalCost.clear();
  }
}

class _VentHygieneFormPageState extends State<VentHygieneFormPage> {
  static const _currencyOptions = ['GBP', 'EUR', 'USD'];
  static const _subOperativeCounts = ['None', '1', '2', '3', '4', '5', '6', '7'];

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

  final _scrollController = ScrollController();
  final _collapseProgress = ValueNotifier(0.0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  final _travelHoursController = TextEditingController();
  final _leadEngineerCostController = TextEditingController();
  final _hoursWorkedController = TextEditingController();
  final _scopeOfWorkController = TextEditingController();
  final _certificateDescController = TextEditingController();
  final _preCleanPdfUrlController = TextEditingController();
  final _appointmentSearchController = TextEditingController();
  final _operativeSearchController = TextEditingController();

  String? _currency = 'GBP';
  String? _selectedAppointment;
  String? _selectedOperative;
  String _subOperativeCount = 'None';
  DateTime? _lastServiceClean;
  DateTime? _dateTime;
  String? _dateTimeError;

  final _hse = HseRiskFormController();
  final List<_SubOperativeControllers> _subOperatives = [];

  String get _workOrderDisplay {
    if (widget.workOrderLabel.trim().isNotEmpty) {
      return widget.workOrderLabel.trim();
    }
    if (widget.workOrderId.trim().isNotEmpty) {
      return widget.workOrderId.trim();
    }
    return '—';
  }

  int get _subOperativeCountValue {
    if (_subOperativeCount == 'None') return 0;
    return int.tryParse(_subOperativeCount) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _travelHoursController.dispose();
    _leadEngineerCostController.dispose();
    _hoursWorkedController.dispose();
    _scopeOfWorkController.dispose();
    _certificateDescController.dispose();
    _preCleanPdfUrlController.dispose();
    _appointmentSearchController.dispose();
    _operativeSearchController.dispose();
    _hse.dispose();
    for (final c in _subOperatives) {
      c.dispose();
    }
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
    return value.isBefore(now.subtract(const Duration(seconds: 30)));
  }

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

  void _syncSubOperativeControllers(int count) {
    while (_subOperatives.length < count) {
      _subOperatives.add(_SubOperativeControllers());
    }
    while (_subOperatives.length > count) {
      _subOperatives.removeLast().dispose();
    }
  }

  Future<void> _pickLastServiceClean() async {
    final theme = DashboardTheme.of(context);
    final now = DateTime.now();
    var draft = _lastServiceClean ?? now;

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
                title: 'Last service clean',
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
                    maximumDate: now,
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
    setState(() => _lastServiceClean = picked);
  }

  Future<void> _pickDate() async {
    final theme = DashboardTheme.of(context);
    final now = DateTime.now();
    var draft = _dateTime ?? now;
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
                title: 'Date',
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
    final existing = _dateTime ?? now;
    _applyDateTime(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        existing.hour,
        existing.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final theme = DashboardTheme.of(context);
    final now = DateTime.now();
    final baseDate = _dateTime ?? now;
    var draft = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      (_dateTime ?? now).hour,
      (_dateTime ?? now).minute,
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
                title: 'Time',
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
    _applyDateTime(picked);
  }

  void _applyDateTime(DateTime value) {
    setState(() {
      if (_isPastDateTime(value)) {
        _dateTimeError = 'Date/time cannot be in the past.';
        _dateTime = value;
      } else {
        _dateTimeError = null;
        _dateTime = value;
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
    if (_dateTime != null && _isPastDateTime(_dateTime!)) {
      setState(() {
        _dateTimeError = 'Date/time cannot be in the past.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please choose a date/time that is not in the past.',
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
      _currency = 'GBP';
      _selectedAppointment = null;
      _selectedOperative = null;
      _subOperativeCount = 'None';
      _lastServiceClean = null;
      _dateTime = null;
      _dateTimeError = null;
      _travelHoursController.clear();
      _leadEngineerCostController.clear();
      _hoursWorkedController.clear();
      _scopeOfWorkController.clear();
      _certificateDescController.clear();
      _preCleanPdfUrlController.clear();
      _appointmentSearchController.clear();
      _operativeSearchController.clear();
      _hse.clear();
      _syncSubOperativeControllers(0);
    });
  }

  void _onCancel() => Navigator.of(context).maybePop(false);

  void _onSave({required bool andNew}) {
    if (!_validateForSave()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          andNew
              ? 'Vent Hygiene form saved — ready for another.'
              : 'Vent Hygiene form saved.',
          style: TextStyle(fontSize: 14.sp),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    if (andNew) {
      _resetForm();
    } else {
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
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: _brandingExpandedHeight + 12,
                          bottom: 24.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Vent Hygiene Forms',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.dashTitle,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Vent heat loss calculation · BS 8204:2011',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.textMuted,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: theme.border,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Risk & HSE',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            HseRiskSection(
                              theme: theme,
                              controller: _hse,
                              onChanged: () => setState(() {}),
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: theme.border,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Information',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ..._buildInformationFields(theme),
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
                                'Vent Hygiene',
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

  List<Widget> _buildInformationFields(DashboardTheme theme) {
    final dateLabel =
        _dateTime == null ? 'Select date' : _formatDate(_dateTime!);
    final timeLabel =
        _dateTime == null ? 'Select time' : _formatTime(_dateTime!);
    final lastCleanLabel = _lastServiceClean == null
        ? 'Select date'
        : _formatDate(_lastServiceClean!);

    return [
      _labeledField(
        theme: theme,
        label: 'Currency',
        child: _simpleDropdown(
          theme: theme,
          value: _currency,
          items: _currencyOptions,
          hint: 'Select currency',
          onChanged: (v) => setState(() => _currency = v),
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
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Last Service Clean',
        child: _pickerButton(
          theme: theme,
          icon: LucideIcons.calendar,
          label: lastCleanLabel,
          onTap: _pickLastServiceClean,
        ),
      ),
      SizedBox(height: 14.h),
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
        label: 'Time Travel to site (Hours)',
        child: _numberField(
          theme: theme,
          controller: _travelHoursController,
          hint: 'e.g. 1.5',
          allowDecimal: true,
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Date / Time',
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
                    onTap: _pickDate,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _pickerButton(
                    theme: theme,
                    icon: LucideIcons.clock,
                    label: timeLabel,
                    onTap: _pickTime,
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
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Total Cost of Lead Engineer',
        child: _numberField(
          theme: theme,
          controller: _leadEngineerCostController,
          hint: '0.00',
          allowDecimal: true,
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'How many hours did you work',
        child: _numberField(
          theme: theme,
          controller: _hoursWorkedController,
          hint: 'e.g. 4',
          allowDecimal: true,
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Scope of Work',
        child: _expandableField(
          theme: theme,
          controller: _scopeOfWorkController,
          hint: 'Describe the scope of work…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'How many sub operatives are there?',
        child: _simpleDropdown(
          theme: theme,
          value: _subOperativeCount,
          items: _subOperativeCounts,
          hint: 'Select count',
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _subOperativeCount = v;
              _syncSubOperativeControllers(_subOperativeCountValue);
            });
          },
        ),
      ),
      if (_subOperatives.isNotEmpty) ...[
        SizedBox(height: 14.h),
        for (var i = 0; i < _subOperatives.length; i++) ...[
          _buildSubOperativeCard(theme, i),
          if (i < _subOperatives.length - 1) SizedBox(height: 10.h),
        ],
      ],
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Description of certificate',
        child: _expandableField(
          theme: theme,
          controller: _certificateDescController,
          hint: 'Describe the certificate…',
        ),
      ),
      SizedBox(height: 14.h),
      _labeledField(
        theme: theme,
        label: 'Pre-Clean Images PDF URL',
        child: _textField(
          theme: theme,
          controller: _preCleanPdfUrlController,
          hint: 'https://…',
          keyboardType: TextInputType.url,
        ),
      ),
    ];
  }

  Widget _buildSubOperativeCard(DashboardTheme theme, int index) {
    final c = _subOperatives[index];
    final n = index + 1;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sub-operative $n',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashTitle,
            ),
          ),
          SizedBox(height: 10.h),
          _labeledField(
            theme: theme,
            label: 'Sub-operative $n',
            child: _textField(
              theme: theme,
              controller: c.name,
              hint: 'Name',
            ),
          ),
          SizedBox(height: 10.h),
          _labeledField(
            theme: theme,
            label: 'Time Travel to Site (Hours)',
            child: _numberField(
              theme: theme,
              controller: c.travelHours,
              hint: 'e.g. 1.5',
              allowDecimal: true,
            ),
          ),
          SizedBox(height: 10.h),
          _labeledField(
            theme: theme,
            label: 'Total Cost of Operative',
            child: _numberField(
              theme: theme,
              controller: c.totalCost,
              hint: '0.00',
              allowDecimal: true,
            ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 13.sp, color: theme.text),
      decoration: _inputDecoration(theme, hint: hint),
    );
  }

  Widget _numberField({
    required DashboardTheme theme,
    required TextEditingController controller,
    String? hint,
    bool allowDecimal = false,
  }) {
    return _textField(
      theme: theme,
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
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
