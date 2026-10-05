import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/responsive/responsive_overlays.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/appointment.dart';
import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_cubit.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_state.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_catalog_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_confirmation_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_operative_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_pricing_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_review_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_scope_step.dart';
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

class SavedFixedPriceJob {
  SavedFixedPriceJob({
    required this.index,
    required this.tradeId,
    required this.tradeName,
    required this.categoryId,
    required this.categoryName,
    required this.workTypeId,
    required this.workTypeName,
    required this.scopeOfWork,
    required this.totalCustomerCharges,
    required this.customerConfirmationChoice,
    required this.payload,
  });

  final int index;
  final String tradeId;
  final String tradeName;
  final String categoryId;
  final String categoryName;
  final String workTypeId;
  final String workTypeName;
  final String scopeOfWork;
  final double totalCustomerCharges;
  final String customerConfirmationChoice;
  final FixedPriceSubmitPayload payload;
}

class RaiseMultipleFixedPricePage extends StatefulWidget {
  const RaiseMultipleFixedPricePage({
    super.key,
    required this.jobId,
    this.jobNumber = '',
    this.customerName,
    this.postcode,
    this.contextArgs,
  });

  final String jobId;
  final String jobNumber;
  final String? customerName;
  final String? postcode;
  final FixedPriceJobContext? contextArgs;

  static Future<bool?> open(
    BuildContext context, {
    required String jobId,
    String jobNumber = '',
    String? customerName,
    String? postcode,
    FixedPriceJobContext? contextArgs,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AppDependencies.createFixedPriceCubit()..loadTrades(),
          child: RaiseMultipleFixedPricePage(
            jobId: jobId,
            jobNumber: jobNumber,
            customerName: customerName,
            postcode: postcode,
            contextArgs: contextArgs,
          ),
        ),
      ),
    );
  }

  @override
  State<RaiseMultipleFixedPricePage> createState() =>
      _RaiseMultipleFixedPricePageState();
}

class _RaiseMultipleFixedPricePageState
    extends State<RaiseMultipleFixedPricePage> {
  int _currentStep =
      0; // 0: Catalog, 1: Scope, 2: Pricing, 3: Operative, 4: Confirmation, 5: Review
  final List<SavedFixedPriceJob> _batchedJobs = [];

  // Step 1: Trade selection
  String? _selectedTrade;
  String? _selectedCategory;
  String? _selectedWorkType;

  final _tradeSearchController = TextEditingController();
  final _categorySearchController = TextEditingController();
  final _workTypeSearchController = TextEditingController();

  // Step 2: Work Type Info & Scope
  final _scopeOfWorkController = TextEditingController();
  final _additionalScope2Controller = TextEditingController();
  final _additionalScope3Controller = TextEditingController();

  final _scopeOfWorkFocusNode = FocusNode();
  final _additionalScope2FocusNode = FocusNode();
  final _additionalScope3FocusNode = FocusNode();

  bool _scopeOfWorkFocused = false;
  bool _additionalScope2Focused = false;
  bool _additionalScope3Focused = false;

  // Step 3: Pricing Information
  bool? _collectionFeeApplicable;
  String? _selectedListPriceService;
  final _materialCostOperativeController = TextEditingController();
  final _descriptionMaterialsOperativeController = TextEditingController();
  bool _chargeDrainagePatches = false;
  final _materialCostAspectController = TextEditingController();
  final _descriptionMaterialsAspectController = TextEditingController();
  bool? _ulezChargeApplicable;

  final _materialCostOperativeFocusNode = FocusNode();
  final _descriptionMaterialsOperativeFocusNode = FocusNode();
  final _materialCostAspectFocusNode = FocusNode();
  final _descriptionMaterialsAspectFocusNode = FocusNode();

  bool _materialCostOperativeFocused = false;
  bool _descriptionMaterialsOperativeFocused = false;
  bool _materialCostAspectFocused = false;
  bool _descriptionMaterialsAspectFocused = false;

  // Step 5: Operative Summary
  String? _selectedLabourRate;
  final _durationHoursController = TextEditingController();
  final _durationHoursFocusNode = FocusNode();
  bool _durationHoursFocused = false;

  // Step 7: Customer Confirmation
  String? _customerConfirmationChoice;

  // Scroll controllers
  final _scrollController = ScrollController();
  final _scopeScrollController = ScrollController();

  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _listPriceServices = [
    {
      'label': 'Standard Labour Service - £80.00',
      'value': 'standard',
      'price': 80.00,
    },
    {
      'label': 'Emergency Callout Service - £150.00',
      'value': 'emergency',
      'price': 150.00,
    },
    {
      'label': 'Diagnostic Investigation - £95.00',
      'value': 'diagnostic',
      'price': 95.00,
    },
    {'label': 'Custom Quote / None - £0.00', 'value': 'none', 'price': 0.00},
  ];

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

    _scopeOfWorkFocusNode.addListener(() {
      setState(() => _scopeOfWorkFocused = _scopeOfWorkFocusNode.hasFocus);
    });
    _additionalScope2FocusNode.addListener(() {
      setState(
        () => _additionalScope2Focused = _additionalScope2FocusNode.hasFocus,
      );
    });
    _additionalScope3FocusNode.addListener(() {
      setState(
        () => _additionalScope3Focused = _additionalScope3FocusNode.hasFocus,
      );
    });
    _materialCostOperativeFocusNode.addListener(() {
      setState(
        () => _materialCostOperativeFocused =
            _materialCostOperativeFocusNode.hasFocus,
      );
    });
    _descriptionMaterialsOperativeFocusNode.addListener(() {
      setState(
        () => _descriptionMaterialsOperativeFocused =
            _descriptionMaterialsOperativeFocusNode.hasFocus,
      );
    });
    _materialCostAspectFocusNode.addListener(() {
      setState(
        () =>
            _materialCostAspectFocused = _materialCostAspectFocusNode.hasFocus,
      );
    });
    _descriptionMaterialsAspectFocusNode.addListener(() {
      setState(
        () => _descriptionMaterialsAspectFocused =
            _descriptionMaterialsAspectFocusNode.hasFocus,
      );
    });
    _durationHoursFocusNode.addListener(() {
      setState(() => _durationHoursFocused = _durationHoursFocusNode.hasFocus);
    });

    _scopeOfWorkController.addListener(() => setState(() {}));
    _materialCostOperativeController.addListener(() => setState(() {}));
    _materialCostAspectController.addListener(() => setState(() {}));
    _durationHoursController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tradeSearchController.dispose();
    _categorySearchController.dispose();
    _workTypeSearchController.dispose();
    _scopeOfWorkController.dispose();
    _additionalScope2Controller.dispose();
    _additionalScope3Controller.dispose();
    _materialCostOperativeController.dispose();
    _descriptionMaterialsOperativeController.dispose();
    _materialCostAspectController.dispose();
    _descriptionMaterialsAspectController.dispose();
    _durationHoursController.dispose();

    _scopeOfWorkFocusNode.dispose();
    _additionalScope2FocusNode.dispose();
    _additionalScope3FocusNode.dispose();
    _materialCostOperativeFocusNode.dispose();
    _descriptionMaterialsOperativeFocusNode.dispose();
    _materialCostAspectFocusNode.dispose();
    _descriptionMaterialsAspectFocusNode.dispose();
    _durationHoursFocusNode.dispose();

    _scrollController.dispose();
    _scopeScrollController.dispose();
    super.dispose();
  }

  String _getTradeName(String? id) {
    if (id == null) return '';
    if (!mounted) return '';
    try {
      final trades = context.read<FixedPriceCubit>().state.trades;
      final match = trades.firstWhere(
        (t) => t.id == id,
        orElse: () => const FixedPriceModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return '';
    }
  }

  String _getCategoryName(String? id) {
    if (id == null) return '';
    if (!mounted) return '';
    try {
      final categories = context.read<FixedPriceCubit>().state.categories;
      final match = categories.firstWhere(
        (c) => c.id == id,
        orElse: () => const FixedPriceCategoryModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return '';
    }
  }

  String _getWorkTypeName(String? id) {
    if (id == null) return '';
    if (!mounted) return '';
    try {
      final workTypes = context.read<FixedPriceCubit>().state.workTypes;
      final match = workTypes.firstWhere(
        (w) => w.id == id,
        orElse: () => const FixedPriceWorkTypeModel(id: '', name: ''),
      );
      return match.name;
    } catch (_) {
      return '';
    }
  }

  String _generateMockScopeOfWork(
    String trade,
    String category,
    String workType,
  ) {
    return 'Assessment and Identification\n'
        'The process begins with a thorough inspection of the property to locate issues related to $workType in the category $category ($trade).\n\n'
        'Containment\n'
        'To prevent the spread of dust, debris, or water damage, containment measures will be put in place.\n\n'
        'Removal & Repair\n'
        'Faulty components, blocks, or damaged pipes will be removed or repaired in accordance with safety standards.\n\n'
        'Cleaning & Sanitizing\n'
        'Cleaning and sanitizing the work area post-repair.\n\n'
        'Treatment & Verification\n'
        'The repaired system or install will be tested to ensure functionality.\n\n'
        'Ventilation and Moisture Control\n'
        'Ensuring proper ventilation and moisture control is in place where necessary.';
  }

  int _currentStepDisplay() {
    switch (_currentStep) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 5;
      case 4:
        return 7;
      case 5:
        return 8;
      default:
        return 1;
    }
  }

  FixedPriceJobContext _resolveJobContext() {
    if (widget.contextArgs != null) return widget.contextArgs!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is FixedPriceJobContext) return args;
    if (args is Appointment) return FixedPriceJobContext.fromAppointment(args);

    final sid = widget.jobId.isNotEmpty
        ? widget.jobId
        : '0WO_BATCH_${DateTime.now().millisecondsSinceEpoch}';
    return FixedPriceJobContext(
      sourceWorkOrderId: sid,
      workOrderLabel: widget.jobNumber.isNotEmpty ? widget.jobNumber : sid,
      siteId: 'SITE_${widget.postcode ?? "LOCAL"}',
      accountId: 'ACC_${widget.customerName ?? "DEFAULT"}',
      contactId: 'CNT_CUSTOMER',
      customerEmail: 'customer@aspect.co.uk',
      earliestRequestedDate: DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  bool _isValidMaterialCost(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return true;
    final value = double.tryParse(text);
    return value != null && value >= 0;
  }

  double _parsedMaterialCost(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  String? _materialCostError(TextEditingController controller) {
    if (_isValidMaterialCost(controller)) return null;
    return 'Enter a valid amount (0 or greater).';
  }

  double? get _durationHours {
    final value = double.tryParse(_durationHoursController.text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _selectedTrade != null &&
            _selectedCategory != null &&
            _selectedWorkType != null;
      case 1:
        final text = _scopeOfWorkController.text;
        return text.trim().isNotEmpty && text.split('\n').length >= 5;
      case 2:
        return _collectionFeeApplicable != null &&
            _selectedListPriceService != null &&
            _ulezChargeApplicable != null &&
            _isValidMaterialCost(_materialCostOperativeController) &&
            _isValidMaterialCost(_materialCostAspectController);
      case 3:
        return _selectedLabourRate != null && _durationHours != null;
      case 4:
        return _customerConfirmationChoice != null;
      case 5:
        return true;
      default:
        return true;
    }
  }

  double get _listPriceServiceCost {
    final match = _listPriceServices.firstWhere(
      (s) => s['value'] == _selectedListPriceService,
      orElse: () => {'price': 0.00},
    );
    return (match['price'] as num).toDouble();
  }

  double get _materialsCharge {
    final opMat = _parsedMaterialCost(_materialCostOperativeController);
    final aspMat = _parsedMaterialCost(_materialCostAspectController);
    return opMat + aspMat;
  }

  double get _attendanceFee {
    if (_selectedLabourRate == null) return 0.00;
    return FixedPriceSubmitPayload.labourCharge(
      labourRateLevel: _selectedLabourRate!,
      durationHours: _durationHours,
    );
  }

  double get _ulezCharge {
    return _ulezChargeApplicable == true ? 12.50 : 0.00;
  }

  double get _collectionFee {
    return _collectionFeeApplicable == true ? 20.00 : 0.00;
  }

  double get _drainagePatchesFee {
    return _chargeDrainagePatches ? 45.00 : 0.00;
  }

  double get _totalCustomerCharges {
    return _listPriceServiceCost +
        _materialsCharge +
        _attendanceFee +
        _ulezCharge +
        _collectionFee +
        _drainagePatchesFee;
  }

  FixedPriceSubmitPayload _buildSubmitPayload(FixedPriceJobContext jobContext) {
    return FixedPriceSubmitPayload.fromWizard(
      workOrderId: jobContext.workOrderLabel.isNotEmpty
          ? jobContext.workOrderLabel
          : jobContext.sourceWorkOrderId,
      sourceWorkOrderId: jobContext.sourceWorkOrderId,
      customerEmail: jobContext.customerEmail,
      earliestRequestedDate: jobContext.earliestRequestedDate,
      tradeId: _selectedTrade ?? '',
      categoryId: _selectedCategory ?? '',
      workTypeId: _selectedWorkType ?? '',
      scopeOfWork: _scopeOfWorkController.text.trim(),
      additionalScope2: _additionalScope2Controller.text.trim(),
      additionalScope3: _additionalScope3Controller.text.trim(),
      collectionFeeApplicable: _collectionFeeApplicable ?? false,
      listPriceServiceCode: _selectedListPriceService ?? 'none',
      operativeMaterialsCost: _parsedMaterialCost(
        _materialCostOperativeController,
      ),
      operativeMaterialsDescription: _descriptionMaterialsOperativeController
          .text
          .trim(),
      chargeDrainagePatches: _chargeDrainagePatches,
      aspectMaterialsCost: _parsedMaterialCost(_materialCostAspectController),
      aspectMaterialsDescription: _descriptionMaterialsAspectController.text
          .trim(),
      ulezChargeApplicable: _ulezChargeApplicable ?? false,
      labourRateLevel: _selectedLabourRate ?? 'Level 1',
      customerConfirmationChoice: _customerConfirmationChoice ?? 'Accept',
      durationHours: _durationHours,
    );
  }

  SavedFixedPriceJob _buildSavedJobObject(FixedPriceJobContext jobContext) {
    return SavedFixedPriceJob(
      index: _batchedJobs.length + 1,
      tradeId: _selectedTrade ?? '',
      tradeName: _getTradeName(_selectedTrade),
      categoryId: _selectedCategory ?? '',
      categoryName: _getCategoryName(_selectedCategory),
      workTypeId: _selectedWorkType ?? '',
      workTypeName: _getWorkTypeName(_selectedWorkType),
      scopeOfWork: _scopeOfWorkController.text.trim(),
      totalCustomerCharges: _totalCustomerCharges,
      customerConfirmationChoice: _customerConfirmationChoice ?? 'Accept',
      payload: _buildSubmitPayload(jobContext),
    );
  }

  void _resetFormForNextJob() {
    setState(() {
      _currentStep = 0;
      _selectedTrade = null;
      _selectedCategory = null;
      _selectedWorkType = null;
      _tradeSearchController.clear();
      _categorySearchController.clear();
      _workTypeSearchController.clear();
      _scopeOfWorkController.clear();
      _additionalScope2Controller.clear();
      _additionalScope3Controller.clear();
      _collectionFeeApplicable = null;
      _selectedListPriceService = null;
      _materialCostOperativeController.clear();
      _descriptionMaterialsOperativeController.clear();
      _chargeDrainagePatches = false;
      _materialCostAspectController.clear();
      _descriptionMaterialsAspectController.clear();
      _ulezChargeApplicable = null;
      _selectedLabourRate = null;
      _durationHoursController.clear();
      _customerConfirmationChoice = null;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showAddAnotherOrSubmitDialog(FixedPriceJobContext jobContext) {
    final theme = DashboardTheme.of(context);
    final currentSavedJob = _buildSavedJobObject(jobContext);
    final totalBatchedCount = _batchedJobs.length + 1;

    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: theme.border, width: 0.8),
          ),
          title: Row(
            children: [
              Icon(
                LucideIcons.circleCheck,
                color: const Color(0xFF22C55E),
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Job #$totalBatchedCount Ready',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fixed Price job "${currentSavedJob.workTypeName}" (£${currentSavedJob.totalCustomerCharges.toStringAsFixed(2)}) has been assembled.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.textMuted,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: theme.surfaceDeep,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: theme.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    _buildDialogSummaryRow(
                      theme,
                      'Trade',
                      currentSavedJob.tradeName,
                    ),
                    _buildDialogSummaryRow(
                      theme,
                      'Work Type',
                      currentSavedJob.workTypeName,
                    ),
                    _buildDialogSummaryRow(
                      theme,
                      'Total Charges',
                      '£${currentSavedJob.totalCustomerCharges.toStringAsFixed(2)}',
                    ),
                    _buildDialogSummaryRow(
                      theme,
                      'Choice',
                      currentSavedJob.customerConfirmationChoice,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Would you like to add another Fixed Price job to this batch or submit now?',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedCtaButton(
              label: '+ Add Another Job',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _batchedJobs.add(currentSavedJob);
                });
                _resetFormForNextJob();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added Job #${_batchedJobs.length} to batch. Starting Job #${_batchedJobs.length + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFF22C55E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            PrimaryCtaButton(
              label: 'Submit All ($totalBatchedCount Jobs)',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _batchedJobs.add(currentSavedJob);
                });
                _submitAllBatchedJobs(jobContext);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogSummaryRow(
    DashboardTheme theme,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5.sp, color: theme.textMuted),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAllBatchedJobs(FixedPriceJobContext jobContext) async {
    if (_batchedJobs.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final refId =
        'MFP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    double grandTotalNet = 0;
    final List<Map<String, dynamic>> lineItems = [];

    try {
      final cubit = context.read<FixedPriceCubit>();
      final salesforceContext = jobContext.toSalesforceContext();

      for (int i = 0; i < _batchedJobs.length; i++) {
        final job = _batchedJobs[i];
        grandTotalNet += job.totalCustomerCharges;

        lineItems.add({
          'title': job.workTypeName,
          'description': job.scopeOfWork,
          'trade': job.tradeName,
          'total_net': job.totalCustomerCharges,
          'choice': job.customerConfirmationChoice,
        });

        // Submit to API
        await cubit.submitWorkOrder(
          payload: job.payload,
          context: salesforceContext,
        );

        // Also push enquiry record to Firestore
        await PillarClient.raiseEnquiry(
          category: 'MULTIPLE_FIXED_PRICE',
          description: job.scopeOfWork,
          details: {
            'job_id': jobContext.sourceWorkOrderId,
            'job_number': jobContext.workOrderLabel,
            'batch_reference': refId,
            'batch_index': i + 1,
            'batch_total': _batchedJobs.length,
            'trade_name': job.tradeName,
            'category_name': job.categoryName,
            'work_type_name': job.workTypeName,
            'total_customer_charges': job.totalCustomerCharges,
            'customer_choice': job.customerConfirmationChoice,
          },
        );
      }

      // Commit consolidated estimate to PillarClient
      await PillarClient.submitFpEstimate(
        jobId: jobContext.sourceWorkOrderId,
        lineItems: lineItems,
        totalNet: grandTotalNet,
        totalGross: grandTotalNet * 1.20,
        notes:
            'Multiple Fixed Price Batch ($refId): ${_batchedJobs.length} jobs submitted.',
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final theme = DashboardTheme.of(context);
      await JobSubmissionDialog.show(
        context,
        theme: theme,
        title: '${_batchedJobs.length} Fixed Price Jobs Submitted',
        subtitle:
            'All ${_batchedJobs.length} Fixed Price agreements have been successfully submitted.',
        referenceId: refId,
        details: {
          'Total Jobs': '${_batchedJobs.length} work orders',
          'Grand Total (Net)': '£${grandTotalNet.toStringAsFixed(2)}',
          'Grand Total (Gross)':
              '£${(grandTotalNet * 1.20).toStringAsFixed(2)}',
          'Jobs': _batchedJobs.map((j) => j.workTypeName).join(', '),
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
            content: Text('Failed to submit batch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStepContent(
    DashboardTheme theme,
    FixedPriceJobContext jobContext,
  ) {
    final state = context.watch<FixedPriceCubit>().state;
    final trades = state.trades;
    final categories = state.categories;
    final workTypes = state.workTypes;

    switch (_currentStep) {
      case 0:
        return FixedPriceCatalogStep(
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
          onRetry: () =>
              context.read<FixedPriceCubit>().loadTrades(forceRefresh: true),
          onTradeChanged: (val) {
            setState(() {
              _selectedTrade = val;
              _selectedCategory = null;
              _selectedWorkType = null;
            });
            if (val != null) {
              context.read<FixedPriceCubit>().loadCategories(val);
            }
          },
          onCategoryChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _selectedWorkType = null;
            });
            if (val != null) {
              context.read<FixedPriceCubit>().loadWorkTypes(val);
            }
          },
          onWorkTypeChanged: (val) {
            setState(() {
              _selectedWorkType = val;
              if (val != null &&
                  _selectedTrade != null &&
                  _selectedCategory != null) {
                final tradeName = _getTradeName(_selectedTrade);
                final catName = _getCategoryName(_selectedCategory);
                final wtName = _getWorkTypeName(val);
                _scopeOfWorkController.text = _generateMockScopeOfWork(
                  tradeName,
                  catName,
                  wtName,
                );
              }
            });
          },
          tradeSearchController: _tradeSearchController,
          categorySearchController: _categorySearchController,
          workTypeSearchController: _workTypeSearchController,
          getTradeName: _getTradeName,
          getCategoryName: _getCategoryName,
          getWorkTypeName: _getWorkTypeName,
        );
      case 1:
        return FixedPriceScopeStep(
          theme: theme,
          selectedTradeName: _getTradeName(_selectedTrade),
          selectedCategoryName: _getCategoryName(_selectedCategory),
          selectedWorkTypeName: _getWorkTypeName(_selectedWorkType),
          scopeOfWorkController: _scopeOfWorkController,
          scopeOfWorkFocusNode: _scopeOfWorkFocusNode,
          scopeOfWorkFocused: _scopeOfWorkFocused,
          additionalScope2Controller: _additionalScope2Controller,
          additionalScope2FocusNode: _additionalScope2FocusNode,
          additionalScope2Focused: _additionalScope2Focused,
          additionalScope3Controller: _additionalScope3Controller,
          additionalScope3FocusNode: _additionalScope3FocusNode,
          additionalScope3Focused: _additionalScope3Focused,
        );
      case 2:
        return FixedPricePricingStep(
          theme: theme,
          collectionFeeApplicable: _collectionFeeApplicable,
          onCollectionFeeApplicableChanged: (val) =>
              setState(() => _collectionFeeApplicable = val),
          selectedListPriceService: _selectedListPriceService,
          onListPriceServiceChanged: (val) =>
              setState(() => _selectedListPriceService = val),
          listPriceServices: _listPriceServices,
          materialCostOperativeController: _materialCostOperativeController,
          materialCostOperativeFocusNode: _materialCostOperativeFocusNode,
          materialCostOperativeFocused: _materialCostOperativeFocused,
          descriptionMaterialsOperativeController:
              _descriptionMaterialsOperativeController,
          descriptionMaterialsOperativeFocusNode:
              _descriptionMaterialsOperativeFocusNode,
          descriptionMaterialsOperativeFocused:
              _descriptionMaterialsOperativeFocused,
          chargeDrainagePatches: _chargeDrainagePatches,
          onChargeDrainagePatchesChanged: (val) =>
              setState(() => _chargeDrainagePatches = val),
          materialCostAspectController: _materialCostAspectController,
          materialCostAspectFocusNode: _materialCostAspectFocusNode,
          materialCostAspectFocused: _materialCostAspectFocused,
          descriptionMaterialsAspectController:
              _descriptionMaterialsAspectController,
          descriptionMaterialsAspectFocusNode:
              _descriptionMaterialsAspectFocusNode,
          descriptionMaterialsAspectFocused: _descriptionMaterialsAspectFocused,
          ulezChargeApplicable: _ulezChargeApplicable,
          onUlezChargeApplicableChanged: (val) =>
              setState(() => _ulezChargeApplicable = val),
          materialCostError: _materialCostError,
        );
      case 3:
        return FixedPriceOperativeStep(
          theme: theme,
          durationHoursController: _durationHoursController,
          durationHoursFocusNode: _durationHoursFocusNode,
          durationHoursFocused: _durationHoursFocused,
          durationHours: _durationHours,
          selectedLabourRate: _selectedLabourRate,
          onLabourRateChanged: (val) =>
              setState(() => _selectedLabourRate = val),
          listPriceServiceCost: _listPriceServiceCost,
          materialsCharge: _materialsCharge,
          attendanceFee: _attendanceFee,
          ulezCharge: _ulezCharge,
          collectionFee: _collectionFee,
          chargeDrainagePatches: _chargeDrainagePatches,
          drainagePatchesFee: _drainagePatchesFee,
          totalCustomerCharges: _totalCustomerCharges,
        );
      case 4:
        return FixedPriceConfirmationStep(
          theme: theme,
          scopeOfWorkText: _scopeOfWorkController.text,
          scopeScrollController: _scopeScrollController,
          totalCustomerCharges: _totalCustomerCharges,
          customerConfirmationChoice: _customerConfirmationChoice,
          onCustomerConfirmationChoiceChanged: (val) =>
              setState(() => _customerConfirmationChoice = val),
        );
      case 5:
        return FixedPriceReviewStep(
          theme: theme,
          jobContext: jobContext,
          totalCustomerCharges: _totalCustomerCharges,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBatchJobStrip(DashboardTheme theme) {
    if (_batchedJobs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.dashPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dashPrimary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.layers, size: 14.sp, color: theme.dashPrimary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Configured Jobs in Batch (${_batchedJobs.length})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.dashPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ..._batchedJobs.asMap().entries.map((entry) {
            final idx = entry.key;
            final job = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: theme.dashPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${job.workTypeName} (£${job.totalCustomerCharges.toStringAsFixed(2)})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                        Text(
                          '${job.tradeName} • ${job.customerConfirmationChoice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 14.sp,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _batchedJobs.removeAt(idx);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    DashboardTheme theme,
    FixedPriceJobContext jobContext,
  ) {
    final isFirstScreen = _currentStep == 0;
    final isLastScreen = _currentStep == 5;
    final isValid = _isStepValid() && !_isSubmitting;

    return Row(
      children: [
        Expanded(
          child: OutlinedCtaButton(
            label: isFirstScreen ? 'Cancel' : 'Back',
            onTap: () {
              if (isFirstScreen) {
                Navigator.of(context).pop();
              } else if (_currentStep == 3) {
                setState(() => _currentStep = 2);
              } else if (_currentStep == 4) {
                setState(() => _currentStep = 3);
              } else if (_currentStep == 5) {
                setState(() => _currentStep = 4);
              } else {
                setState(() => _currentStep--);
              }
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryCtaButton(
            label: isLastScreen ? 'Finish & Options' : 'Next',
            backgroundColor: isValid
                ? AppColors.primaryBlue
                : (theme.isDark
                      ? AppColors.darkBorder
                      : AppColors.buttonDisabledBackground),
            onTap: isValid
                ? () {
                    if (isLastScreen) {
                      _showAddAnotherOrSubmitDialog(jobContext);
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
    final jobContext = _resolveJobContext();
    final currentJobNumber = _batchedJobs.length + 1;

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
                    'MULTIPLE FIXED PRICE JOBS',
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
                        _buildBatchJobStrip(theme),
                        ScreenTitleBlock(
                          title: 'Fixed Price Job #$currentJobNumber',
                          subtitle: 'Step ${_currentStepDisplay()} of 8',
                        ),
                        SizedBox(height: 20.h),
                        _buildStepContent(theme, jobContext),
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
                  child: _buildBottomButtons(theme, jobContext),
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
                  } else if (_currentStep == 3) {
                    setState(() => _currentStep = 2);
                  } else if (_currentStep == 4) {
                    setState(() => _currentStep = 3);
                  } else if (_currentStep == 5) {
                    setState(() => _currentStep = 4);
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
