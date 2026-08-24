import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../components/common/aspect_branding.dart';
import '../../utils/dashboard_theme.dart';
import '../../utils/colors.dart';
import '../../widgets/ui/command_centre_back_button.dart';
import '../../widgets/ui/elevated_surface.dart';
import '../../widgets/ui/primary_cta_button.dart';
import '../../widgets/ui/outlined_cta_button.dart';
import '../../widgets/ui/screen_title_block.dart';
import '../../models/user_model.dart';
import '../../models/fixed_price_job_context.dart';
import '../../models/fixed_price_submit_payload.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/fixed_price_model.dart';
import 'cubit/fixed_price_cubit.dart';
import 'cubit/fixed_price_state.dart';
import 'service/pillar_client.dart';
import '../../shimmers/shimmer_box.dart';

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
    // Setup focus listeners to animate borders properly
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
      operativeMaterialsCost:
          _parsedMaterialCost(_materialCostOperativeController),
      operativeMaterialsDescription:
          _descriptionMaterialsOperativeController.text.trim(),
      chargeDrainagePatches: _chargeDrainagePatches,
      aspectMaterialsCost: _parsedMaterialCost(_materialCostAspectController),
      aspectMaterialsDescription:
          _descriptionMaterialsAspectController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first)),
      );
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
            }
          ],
          totalNet: _totalCustomerCharges,
          totalGross: _totalCustomerCharges * 1.20,
          notes: payload.scopeOfWork,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _customerConfirmationChoice == 'Reject'
                ? 'Fixed price estimate rejected and submitted.'
                : 'Fixed Price Agreement created & submitted to Firestore spine.',
          ),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
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
    showDialog<void>(
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
    showDialog<void>(
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
  Widget _buildStepContent(DashboardTheme theme, FixedPriceJobContext? jobContext) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(theme);
      case 1:
        return _buildStep2(theme);
      case 2:
        return _buildStep3(theme);
      case 3:
        return _buildStep5(theme);
      case 4:
        return _buildStep7(theme);
      case 5:
        return _buildStep8(theme, jobContext);
      default:
        return _buildStep1(theme);
    }
  }

  Widget _buildShimmerDropdown(DashboardTheme theme, String label) {
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
        ThemedShimmerBox(theme: theme, height: 48.h, radius: 10),
      ],
    );
  }

  Widget _buildStep1(DashboardTheme theme) {
    final fixedPriceState = context.watch<FixedPriceCubit>().state;
    final trades = fixedPriceState.trades;
    final categories = fixedPriceState.categories;
    final loadingCategories = fixedPriceState.loadingCategories;
    final workTypes = fixedPriceState.workTypes;
    final loadingWorkTypes = fixedPriceState.loadingWorkTypes;

    if (fixedPriceState is FixedPriceLoading && trades.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildShimmerDropdown(theme, 'Please Select Trade *'),
          SizedBox(height: 12.h),
          _buildShimmerDropdown(theme, 'Please Select Category *'),
          SizedBox(height: 12.h),
          _buildShimmerDropdown(theme, 'Please Select Work Type *'),
        ],
      );
    }

    if (fixedPriceState is FixedPriceError && trades.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            children: [
              Text(
                'Failed to load trades.',
                style: TextStyle(color: theme.text, fontSize: 13.sp),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => context.read<FixedPriceCubit>().loadTrades(
                  forceRefresh: true,
                ),
                child: Text('Retry', style: TextStyle(color: theme.accent)),
              ),
            ],
          ),
        ),
      );
    }

    final tradeIds = trades.map((t) => t.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdownField(
          label: 'Please Select Trade *',
          value: _selectedTrade,
          items: tradeIds,
          hintText: 'Select Trade',
          onChanged: (val) {
            setState(() {
              _selectedTrade = val;
              _selectedCategory = null;
              _selectedWorkType = null;
            });
            if (val != null) {
              context.read<FixedPriceCubit>().loadCategories(val);
            }
          },
          theme: theme,
          itemLabelBuilder: _getTradeName,
          searchController: _tradeSearchController,
        ),
        SizedBox(height: 12.h),
        if (loadingCategories && categories.isEmpty)
          _buildShimmerDropdown(theme, 'Please Select Category *')
        else
          _buildDropdownField(
            label: 'Please Select Category *',
            value: _selectedCategory,
            items: categories.map((c) => c.id).toList(),
            hintText: _selectedTrade == null
                ? 'Select Trade first'
                : 'Select Category',
            onChanged: _selectedTrade == null
                ? null
                : (val) {
                    setState(() {
                      _selectedCategory = val;
                      _selectedWorkType = null;
                    });
                    if (val != null) {
                      context.read<FixedPriceCubit>().loadWorkTypes(val);
                    }
                  },
            theme: theme,
            itemLabelBuilder: (id) {
              final match = categories.firstWhere(
                (c) => c.id == id,
                orElse: () => const FixedPriceCategoryModel(id: '', name: ''),
              );
              return match.name;
            },
            searchController: _categorySearchController,
          ),
        SizedBox(height: 12.h),
        if (loadingWorkTypes && workTypes.isEmpty)
          _buildShimmerDropdown(theme, 'Please Select Work Type *')
        else
          _buildDropdownField(
            label: 'Please Select Work Type *',
            value: _selectedWorkType,
            items: workTypes.map((w) => w.id).toList(),
            hintText: _selectedCategory == null
                ? 'Select Category first'
                : 'Select Work Type',
            onChanged: _selectedCategory == null
                ? null
                : (val) {
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
            theme: theme,
            itemLabelBuilder: _getWorkTypeName,
            searchController: _workTypeSearchController,
          ),
      ],
    );
  }

  Widget _buildStep2(DashboardTheme theme) {
    final hasScopeError =
        _scopeOfWorkController.text.trim().isNotEmpty &&
        _scopeOfWorkController.text.split('\n').length < 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Work Type',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Trade:',
                _selectedTrade != null ? _getTradeName(_selectedTrade) : '',
                theme,
              ),
              _buildInfoRow(
                'Group:',
                _selectedCategory != null
                    ? _getCategoryName(_selectedCategory)
                    : '',
                theme,
              ),
              _buildInfoRow(
                'Work Type:',
                _selectedWorkType != null
                    ? _getWorkTypeName(_selectedWorkType)
                    : '',
                theme,
              ),
              Divider(color: theme.border, height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Approval Limit',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    '£50,000',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.streakOrange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Your estimate may be priced over this value and accepted by the customer. If it is not accepted via the app it will automatically be sent to the Trade Manager before becoming available to the customer.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _buildMultilineTextField(
          label: 'Scope of Work',
          controller: _scopeOfWorkController,
          focusNode: _scopeOfWorkFocusNode,
          isFocused: _scopeOfWorkFocused,
          hintText: 'Enter scope of work...',
          theme: theme,
          isRequired: true,
          errorText: hasScopeError
              ? 'Scope of work must be at least 5 lines.'
              : null,
        ),
        SizedBox(height: 12.h),
        _buildMultilineTextField(
          label: 'Additional Scope of Work 2',
          controller: _additionalScope2Controller,
          focusNode: _additionalScope2FocusNode,
          isFocused: _additionalScope2Focused,
          hintText: 'Enter additional scope of work (optional)...',
          theme: theme,
        ),
        SizedBox(height: 12.h),
        _buildMultilineTextField(
          label: 'Additional Scope of Work 3',
          controller: _additionalScope3Controller,
          focusNode: _additionalScope3FocusNode,
          isFocused: _additionalScope3Focused,
          hintText: 'Enter additional scope of work (optional)...',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStep3(DashboardTheme theme) {
    final listPriceLabels = _listPriceServices
        .map((s) => s['label'] as String)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing & Materials',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 16.h),
              _buildRadioButtonSection<bool>(
                label: 'Collection Fee Applicable *',
                selectedValue: _collectionFeeApplicable,
                options: [
                  {'label': 'Yes', 'value': true},
                  {'label': 'No', 'value': false},
                ],
                onChanged: (val) =>
                    setState(() => _collectionFeeApplicable = val),
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              _buildDropdownField(
                label: 'List Price Services *',
                value: _selectedListPriceService != null
                    ? _listPriceServices.firstWhere(
                        (s) => s['value'] == _selectedListPriceService,
                      )['label']
                    : null,
                items: listPriceLabels,
                hintText: 'Select List Price Service',
                onChanged: (val) {
                  setState(() {
                    if (val != null) {
                      _selectedListPriceService = _listPriceServices.firstWhere(
                        (s) => s['label'] == val,
                      )['value'];
                    } else {
                      _selectedListPriceService = null;
                    }
                  });
                },
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              _buildCurrencyField(
                label: 'Material Cost for Operative',
                controller: _materialCostOperativeController,
                focusNode: _materialCostOperativeFocusNode,
                isFocused: _materialCostOperativeFocused,
                theme: theme,
                errorText: _materialCostError(_materialCostOperativeController),
              ),
              SizedBox(height: 12.h),
              _buildMultilineTextField(
                label: 'Description of Materials supplied by Operative',
                controller: _descriptionMaterialsOperativeController,
                focusNode: _descriptionMaterialsOperativeFocusNode,
                isFocused: _descriptionMaterialsOperativeFocused,
                hintText: 'Describe materials...',
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              _buildToggleSwitch(
                label: 'Charge Drainage Patches',
                value: _chargeDrainagePatches,
                onChanged: (val) =>
                    setState(() => _chargeDrainagePatches = val),
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              _buildCurrencyField(
                label: 'Material Cost for Aspect',
                controller: _materialCostAspectController,
                focusNode: _materialCostAspectFocusNode,
                isFocused: _materialCostAspectFocused,
                theme: theme,
                errorText: _materialCostError(_materialCostAspectController),
              ),
              SizedBox(height: 12.h),
              _buildMultilineTextField(
                label: 'Description of Materials supplied by Aspect',
                controller: _descriptionMaterialsAspectController,
                focusNode: _descriptionMaterialsAspectFocusNode,
                isFocused: _descriptionMaterialsAspectFocused,
                hintText: 'Describe materials...',
                theme: theme,
              ),
              Divider(color: theme.border, height: 24.h),
              _buildRadioButtonSection<bool>(
                label: 'ULEZ Charge Applicable *',
                selectedValue: _ulezChargeApplicable,
                options: [
                  {'label': 'Yes (£12.50)', 'value': true},
                  {'label': 'No', 'value': false},
                ],
                onChanged: (val) => setState(() => _ulezChargeApplicable = val),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep5(DashboardTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operative Summary',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildSummaryIndicatorRow('This site is in Zone A', theme),
              _buildSummaryIndicatorRow(
                '10% Zonal Discount has been applied to the Trade Rate Card.',
                theme,
              ),
              _buildSummaryIndicatorRow('Discount based on Dog: 0%', theme),
              _buildSummaryIndicatorRow('Job Duration Discount: 0%', theme),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Duration',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDecimalField(
                label: 'Duration (hours) *',
                controller: _durationHoursController,
                focusNode: _durationHoursFocusNode,
                isFocused: _durationHoursFocused,
                hintText: 'e.g. 2.83',
                theme: theme,
                errorText: _durationHours == null &&
                        _durationHoursController.text.trim().isNotEmpty
                    ? 'Enter a valid duration greater than 0.'
                    : _durationHours == null &&
                            _durationHoursController.text.trim().isEmpty
                        ? 'Duration is required.'
                        : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Labour Rate',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildRadioButtonSection<String>(
                label: 'Select One *',
                selectedValue: _selectedLabourRate,
                options: [
                  {
                    'label': 'Rate 1 (£80.00/hr)',
                    'value': 'Rate 1',
                    'subtitle': 'Standard daytime rate',
                  },
                  {
                    'label': 'Rate 2 (£90.00/hr)',
                    'value': 'Rate 2',
                    'subtitle': 'Evening/Saturday rate',
                  },
                  {
                    'label': 'Rate 3 (£100.00/hr)',
                    'value': 'Rate 3',
                    'subtitle': 'Night/Sunday rate',
                  },
                ],
                onChanged: (val) => setState(() => _selectedLabourRate = val),
                theme: theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Charges',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildChargeRow(
                'List Price Services',
                _listPriceServiceCost,
                theme,
              ),
              _buildChargeRow('Materials Charge', _materialsCharge, theme),
              _buildChargeRow('Labour', _attendanceFee, theme),
              _buildChargeRow('ULEZ Charge', _ulezCharge, theme),
              _buildChargeRow('Collection Fee', _collectionFee, theme),
              if (_chargeDrainagePatches)
                _buildChargeRow(
                  'Drainage Patches Charge',
                  _drainagePatchesFee,
                  theme,
                ),
              Divider(color: theme.border, height: 16.h),
              _buildChargeRow(
                'Total Customer Charges',
                _totalCustomerCharges,
                theme,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep7(DashboardTheme theme) {
    final subtotal = _totalCustomerCharges;
    final vat = subtotal * 0.20;
    final total = subtotal + vat;
    final deposit = total * 0.50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Scope of Work',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 160.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Scrollbar(
            controller: _scopeScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scopeScrollController,
              padding: EdgeInsets.all(12.r),
              physics: const BouncingScrollPhysics(),
              child: Text(
                _scopeOfWorkController.text,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: theme.text,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing Summary',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildPricingSummaryItem(
                'Subtotal',
                '£${subtotal.toStringAsFixed(2)}',
                theme,
              ),
              _buildPricingSummaryItem(
                'VAT',
                '£${vat.toStringAsFixed(2)}',
                theme,
              ),
              Divider(color: theme.border, height: 16.h),
              _buildPricingSummaryItem(
                'Total incl. VAT',
                '£${total.toStringAsFixed(2)}',
                theme,
                isTotal: true,
              ),
              Divider(color: theme.border, height: 16.h),
              _buildPricingSummaryItem(
                'Deposit Required',
                '£${deposit.toStringAsFixed(2)}',
                theme,
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please confirm Customer's choice",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildRadioButtonSection<String>(
                label: 'Choice *',
                selectedValue: _customerConfirmationChoice,
                options: [
                  {
                    'label': 'Send Estimate to Customer',
                    'value': 'Send Estimate to Customer',
                  },
                  {'label': 'Reject', 'value': 'Reject'},
                ],
                onChanged: (val) =>
                    setState(() => _customerConfirmationChoice = val),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep8(DashboardTheme theme, FixedPriceJobContext? jobContext) {
    final scheduledStart = jobContext?.earliestRequestedDate;
    final dateStr = scheduledStart != null && scheduledStart.isNotEmpty
        ? scheduledStart
        : '—';
    final workOrderId = jobContext?.workOrderLabel.isNotEmpty == true
        ? jobContext!.workOrderLabel
        : jobContext?.sourceWorkOrderId ?? '—';
    final customerEmail =
        jobContext?.customerEmail.isNotEmpty == true
            ? jobContext!.customerEmail
            : '—';

    final deposit = (_totalCustomerCharges * 1.2) * 0.50;
    final missingJobContext = jobContext == null;
    final jobContextErrors = jobContext?.validate() ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Job Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 16.h),
        if (missingJobContext || jobContextErrors.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
            ),
            child: Text(
              missingJobContext
                  ? 'This agreement must be opened from a job appointment before it can be submitted.'
                  : jobContextErrors.first,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade700,
                height: 1.4,
              ),
            ),
          ),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Information',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDetailRow('Contact Email', customerEmail, theme),
              _buildDetailRow(
                'Earliest Work Order Requested Date',
                dateStr,
                theme,
              ),
              _buildDetailRow('Job Type', 'Fixed Price (Single)', theme),
              _buildDetailRow('Status', 'Pending Confirmation', theme),
              _buildDetailRow('Work Order ID', workOrderId, theme),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimate Details',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDetailRow(
                'Generate Deposit Invoice',
                deposit > 0 ? 'Yes' : 'No',
                theme,
              ),
              _buildDetailRow('Work Commencing Immediately', 'Yes', theme),
              _buildDetailRow(
                'Date Time Last Estimate Sent',
                '29/06/2026 11:20',
                theme,
              ),
              _buildDetailRow('Payment Link Sent to Customer', 'Yes', theme),
            ],
          ),
        ),
      ],
    );
  }

  // Common UI form widgets helpers
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required ValueChanged<String?>? onChanged,
    required DashboardTheme theme,
    String Function(String)? itemLabelBuilder,
    TextEditingController? searchController,
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
        DropdownButtonFormField2<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.surfaceDeep,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.border, width: 0.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: theme.border.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.accent, width: 0.5),
            ),
          ),
          hint: Text(
            hintText,
            style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
          ),
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
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 44.h,
          ),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: theme.text,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    itemLabelBuilder != null ? itemLabelBuilder(item) : item,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownSearchData: searchController != null
              ? DropdownSearchData(
                  searchController: searchController,
                  searchInnerWidgetHeight: 50.h,
                  searchInnerWidget: Container(
                    height: 50.h,
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 4.h,
                      left: 8.w,
                      right: 8.w,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: searchController,
                      style: TextStyle(fontSize: 13.sp, color: theme.text),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                        filled: true,
                        fillColor: theme.surfaceDeep,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.textMuted,
                          size: 18.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: theme.border, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: theme.border, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: theme.accent, width: 0.5),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    final itemLabel = itemLabelBuilder != null
                        ? itemLabelBuilder(item.value ?? '')
                        : (item.value ?? '');
                    return itemLabel
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                )
              : null,
          onMenuStateChange: searchController != null
              ? (isOpen) {
                  if (!isOpen) {
                    searchController.clear();
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildMultilineTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hintText,
    required DashboardTheme theme,
    bool isRequired = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : (isFocused ? theme.accent : theme.border),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            minLines: isRequired ? 5 : 3,
            onChanged: (text) {
              setState(() {});
            },
            style: TextStyle(fontSize: 13.sp, height: 1.45, color: theme.text),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 13.sp, color: theme.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.r),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 11.sp),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required DashboardTheme theme,
    String? errorText,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : (isFocused ? theme.accent : theme.border),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                '£',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.text,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  style: TextStyle(fontSize: 13.sp, color: theme.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: theme.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 11.sp),
          ),
        ],
      ],
    );
  }

  Widget _buildDecimalField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hintText,
    required DashboardTheme theme,
    String? errorText,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : (isFocused ? theme.accent : theme.border),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 13.sp, color: theme.text),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: theme.textMuted),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 11.sp),
          ),
        ],
      ],
    );
  }

  Widget _buildRadioButtonSection<T>({
    required String label,
    required T? selectedValue,
    required List<Map<String, dynamic>> options,
    required ValueChanged<T> onChanged,
    required DashboardTheme theme,
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
        ...options.map(
          (opt) => _buildRadioOption<T>(
            value: opt['value'] as T,
            groupValue: selectedValue,
            label: opt['label'] as String,
            subtitle: opt['subtitle'] as String?,
            onChanged: onChanged,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>({
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T> onChanged,
    required DashboardTheme theme,
    String? subtitle,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? theme.dashPrimary : theme.textMuted,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: theme.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required DashboardTheme theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.text,
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 38.w,
            height: 20.h,
            decoration: value
                ? BoxDecoration(
                    color: theme.dashPrimary,
                    borderRadius: BorderRadius.circular(999.r),
                  )
                : BoxDecoration(
                    color: theme.dashChipBg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16.w,
                height: 16.w,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 2.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeRow(
    String label,
    double amount,
    DashboardTheme theme, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? theme.text : theme.textMuted,
            ),
          ),
          Text(
            '£${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 15.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: isTotal ? theme.dashPrimary : theme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryIndicatorRow(String text, DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.dashPrimary,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.text,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummaryItem(
    String label,
    String value,
    DashboardTheme theme, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? theme.text : theme.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: isTotal ? theme.dashPrimary : theme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation button block builder
  Widget _buildBottomButtons(
    DashboardTheme theme,
    FixedPriceJobContext? jobContext,
    bool isSubmitting,
  ) {
    final isFirstScreen = _currentStep == 0;
    final isLastScreen = _currentStep == 5;
    final isValid = _isStepValid() && !isSubmitting;

    return Row(
      children: [
        Expanded(
          child: OutlinedCtaButton(
            label: 'Back',
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
                      // Scroll back to top on step transition
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
