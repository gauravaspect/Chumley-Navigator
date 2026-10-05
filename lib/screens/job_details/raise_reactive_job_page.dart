import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_cubit.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_state.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_catalog_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_submission_dialog.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:chumley_navigator/widgets/ui/outlined_cta_button.dart';
import 'package:chumley_navigator/widgets/ui/primary_cta_button.dart';
import 'package:chumley_navigator/widgets/ui/screen_title_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum CustomerChoice {
  accept(
    'accept',
    'Accept',
    'Customer agreed to the attendance and standard rates',
  ),
  pending(
    'pending',
    'Pending - may accept at later date',
    'Customer needs to review or decide at a later date',
  ),
  reject('reject', 'Reject', 'Customer declined attendance');

  const CustomerChoice(this.key, this.label, this.description);
  final String key;
  final String label;
  final String description;
}

class RaiseReactiveJobPage extends StatefulWidget {
  const RaiseReactiveJobPage({
    super.key,
    required this.jobId,
    this.jobNumber = '',
    this.customerName,
    this.postcode,
  });

  final String jobId;
  final String jobNumber;
  final String? customerName;
  final String? postcode;

  static Future<bool?> open(
    BuildContext context, {
    required String jobId,
    String jobNumber = '',
    String? customerName,
    String? postcode,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AppDependencies.createFixedPriceCubit()..loadTrades(),
          child: RaiseReactiveJobPage(
            jobId: jobId,
            jobNumber: jobNumber,
            customerName: customerName,
            postcode: postcode,
          ),
        ),
      ),
    );
  }

  @override
  State<RaiseReactiveJobPage> createState() => _RaiseReactiveJobPageState();
}

class _RaiseReactiveJobPageState extends State<RaiseReactiveJobPage> {
  int _currentStep = 0; // 0: Catalog, 1: Job Details, 2: Rates & Confirmation
  final _scrollController = ScrollController();

  // Step 1: Catalog
  String? _selectedTrade;
  String? _selectedCategory;
  String? _selectedWorkType;
  final _tradeSearchController = TextEditingController();
  final _categorySearchController = TextEditingController();
  final _workTypeSearchController = TextEditingController();

  // Step 2: Job Details
  final _jobTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accessNotesController = TextEditingController();
  final _jobTitleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _accessNotesFocusNode = FocusNode();
  bool _jobTitleFocused = false;
  bool _descriptionFocused = false;
  bool _accessNotesFocused = false;

  // Step 3: Customer Choice
  CustomerChoice? _selectedCustomerChoice;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<FixedPriceCubit>();
        if (cubit.state.trades.isEmpty) {
          cubit.loadTrades();
        }
      }
    });
    _jobTitleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
    _jobTitleFocusNode.addListener(() {
      setState(() => _jobTitleFocused = _jobTitleFocusNode.hasFocus);
    });
    _descriptionFocusNode.addListener(() {
      setState(() => _descriptionFocused = _descriptionFocusNode.hasFocus);
    });
    _accessNotesFocusNode.addListener(() {
      setState(() => _accessNotesFocused = _accessNotesFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tradeSearchController.dispose();
    _categorySearchController.dispose();
    _workTypeSearchController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _accessNotesController.dispose();
    _jobTitleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _accessNotesFocusNode.dispose();
    super.dispose();
  }

  String _getTradeName(String? id) {
    if (id == null) return '';
    try {
      final trades = context.read<FixedPriceCubit>().state.trades;
      final match = trades.firstWhere(
        (t) => t.id == id,
        orElse: () => const FixedPriceModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return id;
    }
  }

  String _getCategoryName(String? id) {
    if (id == null) return '';
    try {
      final categories = context.read<FixedPriceCubit>().state.categories;
      final match = categories.firstWhere(
        (c) => c.id == id,
        orElse: () => const FixedPriceCategoryModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return id;
    }
  }

  String _getWorkTypeName(String? id) {
    if (id == null) return '';
    try {
      final workTypes = context.read<FixedPriceCubit>().state.workTypes;
      final match = workTypes.firstWhere(
        (w) => w.id == id,
        orElse: () => const FixedPriceWorkTypeModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return id;
    }
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _selectedTrade != null &&
            _selectedTrade!.isNotEmpty &&
            _selectedCategory != null &&
            _selectedCategory!.isNotEmpty &&
            _selectedWorkType != null &&
            _selectedWorkType!.isNotEmpty;
      case 1:
        return _jobTitleController.text.trim().isNotEmpty &&
            _descriptionController.text.trim().isNotEmpty;
      case 2:
        return _selectedCustomerChoice != null;
      default:
        return false;
    }
  }

  String _hourlyRateExVat() {
    final trade = _getTradeName(_selectedTrade).toLowerCase();
    if (trade.contains('gas') || trade.contains('heating')) {
      return '£95.00 / hr';
    } else if (trade.contains('drain') || trade.contains('roof')) {
      return '£90.00 / hr';
    } else if (trade.contains('electr')) {
      return '£92.00 / hr';
    }
    return '£85.00 / hr';
  }

  Future<void> _handleSubmit() async {
    if (!_isStepValid() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final tradeName = _getTradeName(_selectedTrade);
    final categoryName = _getCategoryName(_selectedCategory);
    final workTypeName = _getWorkTypeName(_selectedWorkType);
    final hourlyRate = _hourlyRateExVat();
    final refId =
        'RJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    try {
      await PillarClient.raiseEnquiry(
        category: 'REACTIVE_ATTENDANCE',
        description: _descriptionController.text.trim(),
        details: {
          'job_id': widget.jobId,
          'job_number': widget.jobNumber,
          'job_title': _jobTitleController.text.trim(),
          'trade_id': _selectedTrade,
          'trade_name': tradeName,
          'category_id': _selectedCategory,
          'group': categoryName,
          'work_type_id': _selectedWorkType,
          'sub_category': workTypeName,
          'access_notes': _accessNotesController.text.trim(),
          'hourly_rate_ex_vat': hourlyRate,
          'customer_choice': _selectedCustomerChoice?.key ?? 'accept',
          'reference_id': refId,
        },
        jobId: widget.jobId,
        customerName: widget.customerName,
        postcode: widget.postcode,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final theme = DashboardTheme.of(context);
      await JobSubmissionDialog.show(
        context,
        theme: theme,
        title: 'Reactive Job Raised',
        subtitle:
            'The reactive work order has been created and logged with the office.',
        referenceId: refId,
        details: {
          'Job Title': _jobTitleController.text.trim(),
          'Trade': tradeName,
          'Category': categoryName,
          'Rate (ex. VAT)': hourlyRate,
          'Customer Choice': _selectedCustomerChoice?.label ?? 'Accepted',
        },
        buttonLabel: 'Back to Job',
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to raise reactive job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStep2JobDetails(DashboardTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Job Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Title *',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _jobTitleFocused ? theme.accent : theme.border,
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _jobTitleController,
                focusNode: _jobTitleFocusNode,
                style: TextStyle(fontSize: 13.sp, color: theme.text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. Urgent boiler leak attendance',
                  hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Full description
        FixedPriceUiHelpers.buildMultilineTextField(
          label: 'Full description of work to be completed',
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          isFocused: _descriptionFocused,
          hintText:
              'Describe the symptoms, issues, and specific tasks to carry out...',
          theme: theme,
          isRequired: true,
        ),
        SizedBox(height: 16.h),

        // Access / notes for engineer
        FixedPriceUiHelpers.buildMultilineTextField(
          label: 'Access / notes for engineer',
          controller: _accessNotesController,
          focusNode: _accessNotesFocusNode,
          isFocused: _accessNotesFocused,
          hintText: 'Key safe codes, gate access, parking, or contact info...',
          theme: theme,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildStep3SummaryAndConfirmation(DashboardTheme theme) {
    final tradeName = _getTradeName(_selectedTrade);
    final groupName = _getCategoryName(_selectedCategory);
    final subCategoryName = _getWorkTypeName(_selectedWorkType);
    final hourlyRate = _hourlyRateExVat();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary Information Card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: theme.border, width: 0.75),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 16.sp,
                    color: theme.dashPrimary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Reactive Attendance Summary',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildSummaryRow(theme, 'Trade', tradeName),
              _buildSummaryRow(theme, 'Group', groupName),
              _buildSummaryRow(theme, 'Sub-category', subCategoryName),
              _buildSummaryRow(
                theme,
                'Job Title',
                _jobTitleController.text.trim(),
              ),
              Divider(color: theme.border, height: 20.h, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hourly Rates',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                        Text(
                          'Excluding VAT',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dashPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: theme.dashPrimary.withValues(alpha: 0.35),
                        width: 0.75,
                      ),
                    ),
                    child: Text(
                      hourlyRate,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Customer Choice Confirmation
        Text(
          'Please confirm customer choice *',
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: theme.text,
          ),
        ),
        SizedBox(height: 10.h),
        ...CustomerChoice.values.map((choice) {
          final isSelected = _selectedCustomerChoice == choice;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
              onTap: () => setState(() => _selectedCustomerChoice = choice),
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.dashPrimary.withValues(alpha: 0.08)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? theme.dashPrimary : theme.border,
                    width: isSelected ? 1.2 : 0.6,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? theme.dashPrimary : theme.textMuted,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            choice.label,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected ? theme.text : theme.textMuted,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            choice.description,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryRow(DashboardTheme theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(DashboardTheme theme) {
    final isFirstScreen = _currentStep == 0;
    final isLastScreen = _currentStep == 2;
    final isValid = _isStepValid() && !_isSubmitting;

    return Row(
      children: [
        Expanded(
          child: OutlinedCtaButton(
            label: isFirstScreen ? 'Cancel' : 'Back',
            onTap: () {
              if (isFirstScreen) {
                Navigator.of(context).pop();
              } else {
                setState(() => _currentStep--);
              }
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryCtaButton(
            label: isLastScreen
                ? (_isSubmitting ? 'Submitting...' : 'Submit Reactive Job')
                : 'Next',
            backgroundColor: isValid
                ? AppColors.primaryBlue
                : (theme.isDark
                      ? AppColors.darkBorder
                      : AppColors.buttonDisabledBackground),
            onTap: isValid
                ? () {
                    if (isLastScreen) {
                      _handleSubmit();
                    } else {
                      setState(() => _currentStep++);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final state = context.watch<FixedPriceCubit>().state;
    final trades = state.trades;
    final categories = state.categories;
    final workTypes = state.workTypes;

    return Scaffold(
      backgroundColor: theme.base,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AspectBranding(
                  progress: 1.0,
                  expandedHeight: 54.h,
                  collapsedHeight: 54.h,
                  theme: theme,
                  hasBackButton: true,
                  title: Text(
                    'RAISE REACTIVE JOB',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: theme.dashTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ScreenTitleBlock(
                          title: 'Raise a Reactive Job',
                          subtitle: 'Step ${_currentStep + 1} of 3',
                        ),
                        SizedBox(height: 20.h),
                        if (_currentStep == 0)
                          FixedPriceCatalogStep(
                            theme: theme,
                            selectedTrade: _selectedTrade,
                            selectedCategory: _selectedCategory,
                            selectedWorkType: _selectedWorkType,
                            trades: trades,
                            categories: categories,
                            workTypes: workTypes,
                            loadingCategories: state.loadingCategories,
                            loadingWorkTypes: state.loadingWorkTypes,
                            isLoading: state is FixedPriceLoading,
                            isError: state is FixedPriceError,
                            onRetry: () => context
                                .read<FixedPriceCubit>()
                                .loadTrades(forceRefresh: true),
                            onTradeChanged: (val) {
                              setState(() {
                                _selectedTrade = val;
                                _selectedCategory = null;
                                _selectedWorkType = null;
                              });
                              if (val != null) {
                                context.read<FixedPriceCubit>().loadCategories(
                                  val,
                                );
                              }
                            },
                            onCategoryChanged: (val) {
                              setState(() {
                                _selectedCategory = val;
                                _selectedWorkType = null;
                              });
                              if (val != null) {
                                context.read<FixedPriceCubit>().loadWorkTypes(
                                  val,
                                );
                              }
                            },
                            onWorkTypeChanged: (val) {
                              setState(() => _selectedWorkType = val);
                            },
                            tradeSearchController: _tradeSearchController,
                            categorySearchController: _categorySearchController,
                            workTypeSearchController: _workTypeSearchController,
                            getTradeName: _getTradeName,
                            getCategoryName: _getCategoryName,
                            getWorkTypeName: _getWorkTypeName,
                          )
                        else if (_currentStep == 1)
                          _buildStep2JobDetails(theme)
                        else if (_currentStep == 2)
                          _buildStep3SummaryAndConfirmation(theme),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    border: Border(
                      top: BorderSide(color: theme.border, width: 0.5),
                    ),
                  ),
                  child: _buildBottomButtons(theme),
                ),
              ],
            ),
            if (_isSubmitting)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            Positioned(
              top: 12.h,
              left: 16.w,
              child: CommandCentreBackButton(
                onTap: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _currentStep--);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
