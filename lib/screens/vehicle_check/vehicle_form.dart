import 'dart:io';

import 'package:chumley_navigator/core/app_constants.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/vcr_submit_payload.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_state.dart';
import 'package:chumley_navigator/screens/vehicle_check/service/vehicle_check_api_service.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/image_compressor.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_capture_slot.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_example_photo_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_step_indicator.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_warning_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VehicleForm extends StatefulWidget {
  const VehicleForm({super.key});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  final _imagePicker = ImagePicker();
  final Map<String, File?> _captures = {};
  final Map<String, bool> _compressingSlots = {};

  int _currentStepIndex = 0;
  bool _initialized = false;
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _referenceId;

  String _dashboardNotes = '';

  VcrStepData get _step => vcrSteps[_currentStepIndex];

  int get _capturedCount =>
      _step.captures.where((slot) => _captures[slot.id] != null).length;

  int get _totalRequiredCaptures =>
      vcrSteps.fold<int>(0, (count, step) => count + step.captures.length);

  int get _totalCapturedCount =>
      _captures.values.where((file) => file != null).length;

  bool get _stepComplete => _capturedCount >= _step.captures.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is VehicleFormArgs) {
        _dashboardNotes = args.dashboardNotes;
      }
      _fetchExamplesForCurrentStep();
    }
  }

  VehicleModel? get _vehicle {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VehicleFormArgs) return args.vehicle;
    if (args is VehicleModel) return args;
    return null;
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

    setState(() => _isSubmitting = true);

    try {
      final notes = _dashboardNotes.trim();
      await AppDependencies.vehicleCheckRepository.submitVcrInspection(
        VcrSubmitPayload(
          vehicleId: vehicle.vehicleId,
          description: notes.isEmpty ? 'Vehicle check completed' : notes,
          internalNotes: notes,
          inspectionResult: 'Completed',
          files: _collectSubmitFiles(),
        ),
      );

      if (!mounted) return;
      final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
      setState(() {
        _submitted = true;
        _referenceId = 'VCR-${stamp.toString().padLeft(5, '0')}';
      });
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
    ImageSource? source = ImageSource.camera;

    if (!AppConstants.isProduction) {
      source = await _showImageSourceSelector();
      if (source == null || !mounted) return;
    }

    final file = await _imagePicker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null || !mounted) return;

    setState(() => _compressingSlots[slotId] = true);

    try {
      final compressed = await ImageCompressor.compressImage(File(file.path));
      if (!mounted) return;
      setState(() {
        _captures[slotId] = compressed ?? File(file.path);
      });
    } finally {
      if (mounted) {
        setState(() => _compressingSlots[slotId] = false);
      }
    }
  }

  Future<ImageSource?> _showImageSourceSelector() {
    final theme = DashboardTheme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.dashCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select image source',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.dashHeading,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              _ImageSourceButton(
                theme: theme,
                icon: LucideIcons.camera,
                label: 'Take photo',
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              SizedBox(height: 10.h),
              _ImageSourceButton(
                theme: theme,
                icon: LucideIcons.image,
                label: 'Choose from gallery',
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.dashMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToStep(int index) {
    if (index < 0 || index >= vcrSteps.length) return;
    setState(() => _currentStepIndex = index);
    _fetchExamplesForCurrentStep();
  }

  void _onBack() {
    if (_currentStepIndex > 0) {
      _goToStep(_currentStepIndex - 1);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _onPrimaryAction() {
    if (_isSubmitting) return;
    final isLastStep = _currentStepIndex >= vcrSteps.length - 1;
    if (isLastStep) {
      _submitInspection();
      return;
    }
    _goToStep(_currentStepIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);
        final hairline = theme.isDark
            ? theme.dashBorderLight
            : const Color(0xFFE2E7F0);

        if (_submitted) {
          return _SubmittedScreen(
            theme: theme,
            referenceId: _referenceId ?? 'VCR-00000',
            photoCount: _totalCapturedCount,
            areaCount: vcrSteps.length,
            onBackHome: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        }

        final step = _step;
        final isLastStep = _currentStepIndex >= vcrSteps.length - 1;
        final vehicle = _vehicle;

        return Scaffold(
          backgroundColor: theme.base,
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: theme.isDark
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF4F9FF),
                        Color(0xFFEDF4FE),
                        Color(0xFFE2ECFA),
                      ],
                      stops: [0, 0.55, 1],
                    ),
              color: theme.isDark ? theme.base : null,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(
                            LucideIcons.chevronLeft,
                            color: theme.dashPrimary,
                            size: 22.sp,
                          ),
                        ),
                        Text(
                          'Vehicle report',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashHeading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      children: [
                        if (vehicle == null) ...[
                          const VcrWarningBanner(message: _noVehiclesMessage),
                          SizedBox(height: 12.h),
                        ],
                        FadeSlideIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VcrStepIndicator(
                                totalSteps: vcrSteps.length,
                                currentStep: _currentStepIndex,
                                onStepTap: _goToStep,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                step.inspectionTitle,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: theme.dashHeading,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Step ${_currentStepIndex + 1} of ${vcrSteps.length}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF8A99B0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (_stepComplete)
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 30),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F8EF),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.circleCheck,
                                    size: 18.sp,
                                    color: const Color(0xFF15803D),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      isLastStep
                                          ? 'All areas captured. Ready to submit.'
                                          : 'All areas captured.',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 12.h),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 50),
                          child: VcrFormCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Example photos',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: theme.dashHeading,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Use these as a guide',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: theme.dashMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                BlocBuilder<VcrExamplesCubit, VcrExamplesState>(
                                  builder: (context, state) {
                                    final stepSections = _stepSections(step);
                                    final isLoading = state
                                            is VcrExamplesLoading &&
                                        _stateMatchesStep(state, stepSections);
                                    final currentExamples = state
                                                is VcrExamplesLoaded &&
                                            _stateMatchesStep(
                                              state,
                                              stepSections,
                                            )
                                        ? _examplesForStep(
                                            step,
                                            state.examplesBySection,
                                          )
                                        : const <VcrExamplePhoto>[];

                                    if (isLoading) {
                                      return SizedBox(
                                        height: 110.h,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.dashPrimary,
                                          ),
                                        ),
                                      );
                                    }

                                    if (currentExamples.isEmpty) {
                                      return Wrap(
                                        spacing: 10.w,
                                        runSpacing: 10.h,
                                        children: [
                                          for (final capture in step.captures)
                                            _ExamplePlaceholder(
                                              theme: theme,
                                              label: capture.label,
                                            ),
                                        ],
                                      );
                                    }

                                    return SizedBox(
                                      height: 130.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            const BouncingScrollPhysics(),
                                        itemCount: currentExamples.length,
                                        separatorBuilder: (_, _) =>
                                            SizedBox(width: 10.w),
                                        itemBuilder: (_, index) {
                                          final example =
                                              currentExamples[index];
                                          return VcrExamplePhotoCard(
                                            imageUrl: example.imageUrl,
                                            label: example.label,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          child: VcrFormCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Your photos',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: theme.dashHeading,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                        10.w,
                                        5.h,
                                        12.w,
                                        5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8E6FC),
                                        borderRadius:
                                            BorderRadius.circular(500.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6.w,
                                            height: 6.w,
                                            decoration: BoxDecoration(
                                              color: theme.dashPrimary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            '$_capturedCount of ${step.captures.length}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              color: theme.dashPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 10.w,
                                  runSpacing: 12.h,
                                  children: [
                                    for (final slot in step.captures)
                                      VcrCaptureSlot(
                                        label: slot.label,
                                        imageFile: _captures[slot.id],
                                        onTap: () => _pickPhoto(slot.id),
                                        isCompressing:
                                            _compressingSlots[slot.id] ??
                                                false,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                    decoration: BoxDecoration(
                      color: theme.isDark
                          ? theme.base.withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.92),
                      border: Border(top: BorderSide(color: hairline)),
                    ),
                    child: Row(
                      children: [
                        PressableScale(
                          onTap: _onBack,
                          child: Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.isDark
                                  ? theme.dashSurfaceTint
                                  : const Color(0xFFE9EDF5),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.dashHeading,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: PressableScale(
                            onTap: _isSubmitting ? null : _onPrimaryAction,
                            scale: 0.98,
                            child: Container(
                              height: 44.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.accentLime,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 18.r,
                                      height: 18.r,
                                      child:
                                          const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0B1F3A),
                                      ),
                                    )
                                  : Text(
                                      isLastStep
                                          ? 'Submit report'
                                          : 'Next step',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: theme.dashHeading,
                                      ),
                                    ),
                            ),
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
      },
    );
  }
}

class _ExamplePlaceholder extends StatelessWidget {
  const _ExamplePlaceholder({
    required this.theme,
    required this.label,
  });

  final DashboardTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFE9EDF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.image,
              size: 20.sp,
              color: const Color(0xFFC9DCF7),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: theme.dashMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedScreen extends StatelessWidget {
  const _SubmittedScreen({
    required this.theme,
    required this.referenceId,
    required this.photoCount,
    required this.areaCount,
    required this.onBackHome,
  });

  final DashboardTheme theme;
  final String referenceId;
  final int photoCount;
  final int areaCount;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.base,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF4F9FF),
                    Color(0xFFEDF4FE),
                    Color(0xFFE2ECFA),
                  ],
                  stops: [0, 0.55, 1],
                ),
          color: theme.isDark ? theme.base : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBackHome,
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: theme.dashHeading,
                        size: 22.sp,
                      ),
                    ),
                    Text(
                      'Vehicle report',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashHeading,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(22.r),
                      decoration: BoxDecoration(
                        color: theme.dashPrimary,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 76.w,
                            height: 76.w,
                            decoration: BoxDecoration(
                              color: AppColors.accentLime,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              LucideIcons.check,
                              size: 36.sp,
                              color: const Color(0xFF0B1F3A),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Van check submitted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'All $areaCount areas checked and $photoCount photos captured.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your reference',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      referenceId,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: referenceId),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('Reference copied'),
                                      ),
                                    );
                                },
                                child: Icon(
                                  LucideIcons.copy,
                                  size: 18.sp,
                                  color: AppColors.accentLime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    VcrFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.dashHeading,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          const _NextStepRow(
                            index: 1,
                            text: 'The fleet team reviews your check',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepRow(
                            index: 2,
                            text:
                                'Any defect raised is booked in with the workshop',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepRow(
                            index: 3,
                            text: 'A copy lands in your notifications',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: PressableScale(
                  onTap: onBackHome,
                  child: Container(
                    width: double.infinity,
                    height: 44.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentLime,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      'Back to home',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashHeading,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepRow extends StatelessWidget {
  const _NextStepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: theme.isDark
                ? theme.dashSurfaceTint
                : const Color(0xFFD8E6FC),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashPrimary,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.dashHeading,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  const _ImageSourceButton({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final DashboardTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.isDark
              ? theme.dashSurfaceTint
              : const Color(0xFFE9EDF5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.dashPrimary, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.dashHeading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
