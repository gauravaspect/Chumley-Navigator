import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/responsive/responsive_content.dart';
import 'package:chumley_navigator/core/responsive/responsive_overlays.dart';
import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/models/fixed_price_submit_payload.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_cubit.dart';
import 'package:chumley_navigator/screens/job_details/cubit/fixed_price_state.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_catalog_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_confirmation_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_operative_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_pricing_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_review_step.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_scope_step.dart';
import 'package:chumley_navigator/screens/job_details/service/fixed_price_api_service.dart';
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

class FixedPricePage extends StatefulWidget {
  const FixedPricePage({super.key});

  @override
  State<FixedPricePage> createState() => _FixedPricePageState();
}

class _FixedPricePageState extends State<FixedPricePage> {
  int _currentStep =
      0; // 0: Step 1, 1: Step 2, 2: Step 3, 3: Step 5, 4: Step 7, 5: Step 8

  // Step 1: Trade selection
  String? _selectedTrade;
  String? _selectedCategory;
  String? _selectedWorkType;

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

  // Search controllers for searchable dropdowns
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

  // Mock list price services dropdown items
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

  // Generate Scope of Work dynamically based on selections
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

  // Display step numbers
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

  FixedPriceJobContext? _resolveJobContext() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is FixedPriceJobContext) return args;
    if (args is Appointment) return FixedPriceJobContext.fromAppointment(args);
    return null;
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

  // Validation checkers for Next buttons
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
        return _resolveJobContext() != null;
      default:
        return true;
    }
  }

  FixedPriceSubmitPayload _buildSubmitPayload(FixedPriceJobContext jobContext) {
    return FixedPriceSubmitPayload.fromWizard(
      workOrderId: jobContext.workOrderLabel.isNotEmpty
          ? jobContext.workOrderLabel
          : jobContext.sourceWorkOrderId,
      sourceWorkOrderId: jobContext.sourceWorkOrderId,
      customerEmail: jobContext.customerEmail,
      earliestRequestedDate: jobContext.earliestRequestedDate,
      tradeId: _selectedTrade!,
      categoryId: _selectedCategory!,
      workTypeId: _selectedWorkType!,
      scopeOfWork: _scopeOfWorkController.text.trim(),
      additionalScope2: _additionalScope2Controller.text.trim(),
      additionalScope3: _additionalScope3Controller.text.trim(),
      collectionFeeApplicable: _collectionFeeApplicable!,
      listPriceServiceCode: _selectedListPriceService!,
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
      ulezChargeApplicable: _ulezChargeApplicable!,
      labourRateLevel: _selectedLabourRate!,
      customerConfirmationChoice: _customerConfirmationChoice!,
      durationHours: _durationHours,
    );
  }

  Future<void> _handleFinish(FixedPriceJobContext? jobContext) async {
    if (jobContext == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open this flow from a job appointment to submit the agreement.',
          ),
        ),
      );
      return;
    }

    final payload = _buildSubmitPayload(jobContext);
    final salesforceContext = jobContext.toSalesforceContext();
    final errors = [
      ...jobContext.validate(),
      ...payload.validate(salesforceContext: salesforceContext),
    ];

    debugPrint(
      'FixedPrice submit context: '
      'source=${jobContext.sourceWorkOrderId}, '
      'site=${jobContext.siteId}, '
      'account=${jobContext.accountId}, '
      'contact=${jobContext.contactId}',
    );

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errors.first)));
      return;
    }

    try {
      await context.read<FixedPriceCubit>().submitWorkOrder(
        payload: payload,
        context: salesforceContext,
      );

      // Also commit to Firestore demo_fp_submissions/fp-{jobId}
      final targetJobId = jobContext.sourceWorkOrderId.isNotEmpty
          ? jobContext.sourceWorkOrderId
          : payload.workOrderId;

      if (targetJobId.isNotEmpty) {
        await PillarClient.submitFpEstimate(
          jobId: targetJobId,
          lineItems: [
            {
              'title': payload.workTypeId,
              'description': payload.scopeOfWork,
              'service_price': _listPriceServiceCost,
              'materials_cost': _materialsCharge,
              'total_net': _totalCustomerCharges,
            },
          ],
          totalNet: _totalCustomerCharges,
          totalGross: _totalCustomerCharges * 1.20,
          notes: payload.scopeOfWork,
        );
      }

      if (!mounted) return;

      final theme = DashboardTheme.of(context);
      final isRejected = _customerConfirmationChoice == 'Reject';
      final refId =
          'FP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final totalNet = _totalCustomerCharges;
      final totalGross = totalNet * 1.20;

      await JobSubmissionDialog.show(
        context,
        theme: theme,
        title: isRejected
            ? 'Fixed Price Estimate Rejected'
            : 'Fixed Price Job Raised',
        subtitle: isRejected
            ? 'The fixed price estimate was rejected and submitted.'
            : 'The fixed price agreement has been created successfully.',
        referenceId: refId,
        details: {
          'Work Order': jobContext.workOrderLabel.isNotEmpty
              ? jobContext.workOrderLabel
              : jobContext.sourceWorkOrderId,
          'Trade': _getTradeName(_selectedTrade),
          'Work Type': _getWorkTypeName(_selectedWorkType),
          'Total (Net)': '£${totalNet.toStringAsFixed(2)}',
          'Total (Gross)': '£${totalGross.toStringAsFixed(2)}',
          'Customer Choice': _customerConfirmationChoice ?? '',
        },
        buttonLabel: 'Back to Job',
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is FixedPriceApiException
          ? error.message
          : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // Calculation helpers
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

  // Modal dialog triggers
  void _showConfirmEstimateDialog() {
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = DashboardTheme.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Confirm Estimate',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            'The fixed price is lower than the calculated labour and material costs. Are you sure you want to continue?',
            style: TextStyle(color: theme.text, fontSize: 13.sp, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentStep = 3; // Proceed to Step 5
                });
              },
              child: Text(
                'Proceed',
                style: TextStyle(
                  color: theme.isDark
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmLabourRateDialog() {
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = DashboardTheme.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Confirm Labour Rate',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your selected labour charge is £${_attendanceFee.toStringAsFixed(2)}'
                '${_durationHours != null && _selectedLabourRate != null ? ' (${_durationHours!.toStringAsFixed(2)} hrs × £${FixedPriceSubmitPayload.hourlyRateForLevel(_selectedLabourRate!).toStringAsFixed(2)})' : ''}.',
                style: TextStyle(color: theme.text, fontSize: 13.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Subtotal: £${_totalCustomerCharges.toStringAsFixed(2)}.',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Do you want to continue?',
                style: TextStyle(color: theme.text, fontSize: 13.sp),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Back',
                style: TextStyle(
                  color: theme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentStep = 4; // Proceed to Step 7
                });
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: theme.isDark
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Builder functions for wizard steps
  Widget _buildStepContent(
    DashboardTheme theme,
    FixedPriceJobContext? jobContext,
  ) {
    switch (_currentStep) {
      case 0:
        final fixedPriceState = context.watch<FixedPriceCubit>().state;
        return FixedPriceCatalogStep(
          theme: theme,
          selectedTrade: _selectedTrade,
          selectedCategory: _selectedCategory,
          selectedWorkType: _selectedWorkType,
          trades: fixedPriceState.trades,
          categories: fixedPriceState.categories,
          workTypes: fixedPriceState.workTypes,
          loadingCategories: fixedPriceState.loadingCategories,
          loadingWorkTypes: fixedPriceState.loadingWorkTypes,
          isLoading: fixedPriceState is FixedPriceLoading,
          isError: fixedPriceState is FixedPriceError,
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
              if (val != null) {
                _scopeOfWorkController.text = _generateMockScopeOfWork(
                  _getTradeName(_selectedTrade),
                  _getCategoryName(_selectedCategory),
                  _getWorkTypeName(val),
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
          selectedTradeName: _selectedTrade != null
              ? _getTradeName(_selectedTrade)
              : '',
          selectedCategoryName: _selectedCategory != null
              ? _getCategoryName(_selectedCategory)
              : '',
          selectedWorkTypeName: _selectedWorkType != null
              ? _getWorkTypeName(_selectedWorkType)
              : '',
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

  Future<bool> _confirmDiscardProgress() async {
    final theme = DashboardTheme.of(context);
    final result = await showAppDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: theme.border, width: 0.8),
          ),
          title: Text(
            'Discard progress?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          content: Text(
            'Are you sure you want to discard all the progress? All progress will be discarded.',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.textMuted,
              height: 1.35,
            ),
          ),
          actions: [
            OutlinedCtaButton(
              label: 'Keep editing',
              onTap: () => Navigator.of(ctx).pop(false),
            ),
            SizedBox(height: 8.h),
            PrimaryCtaButton(
              label: 'Discard',
              backgroundColor: Colors.red,
              onTap: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _handleExitRequest({required bool isSubmitting}) async {
    if (isSubmitting) return;
    final shouldDiscard = await _confirmDiscardProgress();
    if (shouldDiscard && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleWizardBack({required bool isSubmitting}) {
    if (_currentStep == 0) {
      _handleExitRequest(isSubmitting: isSubmitting);
    } else if (_currentStep == 3) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 4) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 5) {
      setState(() => _currentStep = 4);
    } else {
      setState(() => _currentStep--);
    }
  }

  // Navigation button block builder
  Widget _buildBottomButtons(
    DashboardTheme theme,
    FixedPriceJobContext? jobContext,
    bool isSubmitting,
  ) {
    final isLastScreen = _currentStep == 5;
    final isValid = _isStepValid() && !isSubmitting;

    return Row(
      children: [
        Expanded(
          child: OutlinedCtaButton(
            label: _currentStep == 0 ? 'Cancel' : 'Back',
            onTap: () => _handleWizardBack(isSubmitting: isSubmitting),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryCtaButton(
            label: isLastScreen
                ? (isSubmitting ? 'Submitting...' : 'Finish')
                : 'Next',
            backgroundColor: isValid
                ? AppColors.primaryBlue
                : theme.isDark
                ? AppColors.darkBorder
                : AppColors.buttonDisabledBackground,
            onTap: isValid
                ? () {
                    if (_currentStep == 2) {
                      _showConfirmEstimateDialog();
                    } else if (_currentStep == 3) {
                      _showConfirmLabourRateDialog();
                    } else if (isLastScreen) {
                      _handleFinish(jobContext);
                    } else {
                      setState(() => _currentStep++);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
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
    final isSubmitting = context.watch<FixedPriceCubit>().state.isSubmitting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || isSubmitting) return;
        if (_currentStep == 0) {
          _handleExitRequest(isSubmitting: isSubmitting);
        } else {
          _handleWizardBack(isSubmitting: isSubmitting);
        }
      },
      child: Scaffold(
      backgroundColor: theme.base,
      body: SafeArea(
        child: ResponsiveContent.form(
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
                      'CREATE AGREEMENT',
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
                            title: 'Create Onsite Agreement (Single)',
                            subtitle: 'Step ${_currentStepDisplay()}',
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
                    child: _buildBottomButtons(theme, jobContext, isSubmitting),
                  ),
                ],
              ),
              if (isSubmitting)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              Positioned(
                top: 12.h,
                left: 16.w,
                child: CommandCentreBackButton(
                  onTap: () => _handleWizardBack(isSubmitting: isSubmitting),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
