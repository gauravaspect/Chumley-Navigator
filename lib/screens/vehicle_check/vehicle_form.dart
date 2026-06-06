import 'dart:io';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class VehicleForm extends StatefulWidget {
  const VehicleForm({super.key});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Map<String, File?> _captures = {};

  int _currentStepIndex = 0;
  String? _selectedVan;
  bool _notesFocused = false;

  final List<String> _allocatedVans = const [];

  VcrStepData get _step => vcrSteps[_currentStepIndex];

  int get _capturedCount =>
      _step.captures.where((slot) => _captures[slot.id] != null).length;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
  }

  void _onBack() {
    if (_currentStepIndex > 0) _goToStep(_currentStepIndex - 1);
  }

  void _onNext() {
    if (_currentStepIndex < vcrSteps.length - 1) {
      _goToStep(_currentStepIndex + 1);
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AspectBranding(),
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
                  const VcrWarningBanner(message: _noVehiclesMessage),
                  SizedBox(height: 12.h),
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
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetailsCard(DashboardTheme theme) {
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
          Text(
            'Van number',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          _vanDropdown(theme),
          SizedBox(height: 12.h),
          Text(
            'Dashboard notes',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          _notesField(theme),
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
          if (step.examples.isNotEmpty) ...[
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: step.examples.length,
                separatorBuilder: (_, index) => SizedBox(width: 10.w),
                itemBuilder: (_, index) {
                  final example = step.examples[index];
                  return VcrExamplePhotoCard(
                    imageUrl: example.imageUrl,
                    label: example.label,
                  );
                },
              ),
            ),
          ],
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
                  label: isLastStep ? 'Submit' : 'Next',
                  enabled: true,
                  onTap: _onNext,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vanDropdown(DashboardTheme theme) {
    return DropdownButtonFormField2<String>(
      value: _selectedVan,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        filled: true,
        fillColor: theme.surfaceDeep,
        border: _inputBorder(theme),
        enabledBorder: _inputBorder(theme),
        focusedBorder: _inputBorder(theme, focused: true),
      ),
      hint: Text(
        'Select van',
        style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
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
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.border, width: 0.5),
        ),
      ),
      style: TextStyle(fontSize: 11.sp, color: theme.text),
      items: _allocatedVans
          .map((van) => DropdownMenuItem(value: van, child: Text(van)))
          .toList(),
      onChanged: _allocatedVans.isEmpty
          ? null
          : (val) => setState(() => _selectedVan = val),
    );
  }

  Widget _notesField(DashboardTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _notesFocused ? theme.accent : theme.border,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        onTap: () => setState(() => _notesFocused = true),
        onTapOutside: (_) => setState(() => _notesFocused = false),
        style: TextStyle(fontSize: 11.sp, color: theme.text),
        decoration: InputDecoration(
          hintText: 'Quick notes...',
          hintStyle: TextStyle(fontSize: 11.sp, color: theme.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(DashboardTheme theme, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: focused ? theme.accent : theme.border,
        width: 0.5,
      ),
    );
  }

  Widget _navButton({
    required DashboardTheme theme,
    required String label,
    required bool enabled,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.brandRed
              : (enabled ? theme.surfaceDeep : theme.progressTrack),
          borderRadius: BorderRadius.circular(10.r),
          border: isPrimary
              ? null
              : Border.all(
                  color: enabled ? theme.border : Colors.transparent,
                  width: 0.5,
                ),
        ),
        child: Text(
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
