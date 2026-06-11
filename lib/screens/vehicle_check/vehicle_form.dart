import 'dart:io';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/vcr_submit_payload.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vehicle_check_api_service.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_capture_slot.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_example_photo_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_page_header.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_step_indicator.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_warning_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class VehicleForm extends StatefulWidget {
  const VehicleForm({super.key});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  static const _inspectionResults = [
    'Completed',
    'No Issues',
    'Minor Issues Noticed',
    'Major Issues Found',
  ];

  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Map<String, File?> _captures = {};

  int _currentStepIndex = 0;
  bool _notesFocused = false;
  bool _descriptionFocused = false;
  bool _initialized = false;
  bool _isSubmitting = false;
  String _inspectionResult = _inspectionResults.first;

  VcrStepData get _step => vcrSteps[_currentStepIndex];

  int get _capturedCount =>
      _step.captures.where((slot) => _captures[slot.id] != null).length;

  final _scrollController = ScrollController();

  /// 0.0 = expanded, 1.0 = collapsed — updated every scroll frame.
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

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


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _fetchExamplesForCurrentStep();
    }
  }

  void _fetchExamplesForCurrentStep() {
    final sections = _step.captures.map((capture) => capture.id).toList();
    context.read<VcrExamplesCubit>().fetchExamplesForSections(sections);
  }

  List<String> _stepSections(VcrStepData step) =>
      step.captures.map((capture) => capture.id).toList(growable: false);

  bool _stateMatchesStep(VcrExamplesState state, List<String> stepSections) {
    return switch (state) {
      VcrExamplesLoading(:final sections) => listEquals(sections, stepSections),
      VcrExamplesLoaded(:final sections) => listEquals(sections, stepSections),
      VcrExamplesError(:final sections) => listEquals(sections, stepSections),
      _ => false,
    };
  }

  List<VcrExamplePhoto> _examplesForStep(
    VcrStepData step,
    Map<String, List<VcrExamplePhoto>> examplesBySection,
  ) {
    final photos = <VcrExamplePhoto>[];
    for (final capture in step.captures) {
      for (final photo in examplesBySection[capture.id] ?? const []) {
        if (photo.imageUrl.isEmpty) continue;
        photos.add(
          VcrExamplePhoto(
            label: photo.label.trim().isEmpty ? capture.label : photo.label,
            imageUrl: photo.imageUrl,
          ),
        );
      }
    }
    return photos;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  VehicleModel? get _vehicle =>
      ModalRoute.of(context)?.settings.arguments as VehicleModel?;

  int get _totalRequiredCaptures =>
      vcrSteps.fold<int>(0, (count, step) => count + step.captures.length);

  int get _totalCapturedCount =>
      _captures.values.where((file) => file != null).length;

  List<VcrSubmitFile> _collectSubmitFiles() {
    final files = <VcrSubmitFile>[];
    for (final step in vcrSteps) {
      for (final capture in step.captures) {
        final file = _captures[capture.id];
        if (file != null) {
          files.add(VcrSubmitFile(slotId: capture.id, file: file));
        }
      }
    }
    return files;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitInspection() async {
    final vehicle = _vehicle;
    if (vehicle == null || vehicle.vehicleId.trim().isEmpty) {
      _showMessage('Select a vehicle before submitting the inspection.');
      return;
    }

    if (_totalCapturedCount < _totalRequiredCaptures) {
      _showMessage(
        'Please capture all $_totalRequiredCaptures required photos before submitting.',
      );
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showMessage('Add a short description before submitting.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await AppDependencies.vehicleCheckRepository.submitVcrInspection(
        VcrSubmitPayload(
          vehicleId: vehicle.vehicleId,
          description: description,
          internalNotes: _notesController.text.trim(),
          inspectionResult: _inspectionResult,
          files: _collectSubmitFiles(),
        ),
      );

      if (!mounted) return;
      _showMessage('Vehicle inspection submitted successfully.');
      Navigator.of(context).pop();
    } on VehicleCheckApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to submit vehicle inspection. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickPhoto(String slotId) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null || !mounted) return;
    setState(() => _captures[slotId] = File(file.path));
  }

  void _goToStep(int index) {
    if (index < 0 || index >= vcrSteps.length) return;
    setState(() => _currentStepIndex = index);
    _fetchExamplesForCurrentStep();
  }

  void _onBack() {
    if (_currentStepIndex > 0) _goToStep(_currentStepIndex - 1);
  }

  void _onNext() {
    if (_currentStepIndex < vcrSteps.length - 1) {
      _goToStep(_currentStepIndex + 1);
    }
  }

  void _onPrimaryAction(bool isLastStep) {
    if (_isSubmitting) return;
    if (isLastStep) {
      _submitInspection();
      return;
    }
    _onNext();
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 16.h,
                    bottom: 2.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 14.h),
                      Text(
                        'Vehicle details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      const FadeSlideIn(child: VcrPageHeader()),
                      SizedBox(height: 12.h),
                      if (ModalRoute.of(context)?.settings.arguments == null) ...[
                        const VcrWarningBanner(message: _noVehiclesMessage),
                        SizedBox(height: 12.h),
                      ],
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _buildVehicleDetailsCard(theme),
                      ),
                      SizedBox(height: 10.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: _buildInspectionCard(theme),
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
                      ),
                    );
                  },
                ),
              ],
            )
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetailsCard(DashboardTheme theme) {
    final vehicle = _vehicle;

    return VcrFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VEHICLE DETAILS',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Select your allocated vehicle and record inspection details',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 12.h),
          if (vehicle != null) ...[
            _VehicleDetailRow(
              theme: theme,
              label: 'Registration',
              value: vehicle.regNo,
            ),
            if (vehicle.vanNumber.trim().isNotEmpty)
              _VehicleDetailRow(
                theme: theme,
                label: 'Van number',
                value: vehicle.vanNumber,
              ),
            if (vehicle.vehicleName.trim().isNotEmpty)
              _VehicleDetailRow(
                theme: theme,
                label: 'Vehicle name',
                value: vehicle.vehicleName,
              ),
          ],
          SizedBox(height: 12.h),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          _textAreaField(
            theme: theme,
            controller: _descriptionController,
            hintText: 'Overall vehicle condition summary',
            isFocused: _descriptionFocused,
            onFocusChanged: (focused) =>
                setState(() => _descriptionFocused = focused),
          ),
          SizedBox(height: 12.h),
          Text(
            'Internal notes',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          _textAreaField(
            theme: theme,
            controller: _notesController,
            hintText: 'Optional notes for the office team',
            isFocused: _notesFocused,
            onFocusChanged: (focused) =>
                setState(() => _notesFocused = focused),
          ),
          SizedBox(height: 12.h),
          Text(
            'Inspection result',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          _inspectionResultField(theme),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(DashboardTheme theme) {
    final step = _step;
    final canGoBack = _currentStepIndex > 0;
    final isLastStep = _currentStepIndex >= vcrSteps.length - 1;

    return VcrFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VcrStepIndicator(
            totalSteps: vcrSteps.length,
            currentStep: _currentStepIndex,
            onStepTap: _goToStep,
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.text,
                ),
              ),
              Text(
                '$_capturedCount/${step.captures.length} captured',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          BlocBuilder<VcrExamplesCubit, VcrExamplesState>(
            builder: (context, state) {
              final stepSections = _stepSections(step);
              final isLoading =
                  state is VcrExamplesLoading &&
                  _stateMatchesStep(state, stepSections);
              final currentExamples = state is VcrExamplesLoaded &&
                      _stateMatchesStep(state, stepSections)
                  ? _examplesForStep(step, state.examplesBySection)
                  : const <VcrExamplePhoto>[];

              if (!isLoading && currentExamples.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    'Example photos (use as a guide)',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 130.h,
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.dashPrimary,
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: currentExamples.length,
                            separatorBuilder: (_, index) =>
                                SizedBox(width: 10.w),
                            itemBuilder: (_, index) {
                              final example = currentExamples[index];
                              return VcrExamplePhotoCard(
                                imageUrl: example.imageUrl,
                                label: example.label,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          Text(
            'Your photos',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 130.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: step.captures.length,
              separatorBuilder: (_, index) => SizedBox(width: 12.w),
              itemBuilder: (_, index) {
                final slot = step.captures[index];
                return VcrCaptureSlot(
                  label: slot.label,
                  imageFile: _captures[slot.id],
                  onTap: () => _pickPhoto(slot.id),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _navButton(
                  theme: theme,
                  label: 'Back',
                  enabled: canGoBack,
                  onTap: canGoBack ? _onBack : null,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _navButton(
                  theme: theme,
                  label: isLastStep
                      ? (_isSubmitting ? 'Submitting...' : 'Submit')
                      : 'Next',
                  enabled: !_isSubmitting,
                  onTap: () => _onPrimaryAction(isLastStep),
                  isPrimary: true,
                  showProgress: isLastStep && _isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textAreaField({
    required DashboardTheme theme,
    required TextEditingController controller,
    required String hintText,
    required bool isFocused,
    required ValueChanged<bool> onFocusChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isFocused ? theme.accent : theme.border,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        onTap: () => onFocusChanged(true),
        onTapOutside: (_) => onFocusChanged(false),
        style: TextStyle(fontSize: 11.sp, color: theme.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 11.sp, color: theme.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
    );
  }

  Widget _inspectionResultField(DashboardTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _inspectionResult,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.textMuted,
            size: 20.sp,
          ),
          style: TextStyle(fontSize: 11.sp, color: theme.text),
          items: _inspectionResults
              .map(
                (result) => DropdownMenuItem(
                  value: result,
                  child: Text(result),
                ),
              )
              .toList(),
          onChanged: _isSubmitting
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() => _inspectionResult = value);
                },
        ),
      ),
    );
  }

  Widget _navButton({
    required DashboardTheme theme,
    required String label,
    required bool enabled,
    required VoidCallback? onTap,
    required bool isPrimary,
    bool showProgress = false,
  }) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40.h,
        alignment: Alignment.center,
        decoration: isPrimary
            ? BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(10.r),
              )
            : BoxDecoration(
                color: enabled ? theme.surfaceDeep : theme.progressTrack,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: enabled ? theme.border : Colors.transparent,
                  width: 0.5,
                ),
              ),
        child: showProgress
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? AppColors.white
                      : (enabled ? theme.text : theme.textMuted),
                ),
              ),
      ),
    );
  }
}

class _VehicleDetailRow extends StatelessWidget {
  const _VehicleDetailRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  final DashboardTheme theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: theme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              trimmed,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

