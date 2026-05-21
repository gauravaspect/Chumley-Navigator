import 'dart:io';

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:chumley_navigator/utils/colors.dart';
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

  /// Empty — matches design warning state.
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectBranding(),
              SizedBox(height: 16.h),
              _buildHeader(),
              SizedBox(height: 16.h),
              const VcrWarningBanner(message: _noVehiclesMessage),
              SizedBox(height: 16.h),
              _buildVehicleDetailsCard(),
              SizedBox(height: 16.h),
              _buildInspectionCard(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const FadeSlideIn(child: VcrPageHeader());
  }

  Widget _buildVehicleDetailsCard() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 50),
      child: VcrFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDarkBlue,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select your allocated vehicle and record inspection details',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textBodyMuted,
              ),
            ),
            SizedBox(height: 20.h),
            _fieldLabel('Van Number'),
            SizedBox(height: 8.h),
            _vanDropdown(),
            SizedBox(height: 16.h),
            _fieldLabel('Dashboard Notes'),
            SizedBox(height: 8.h),
            _notesField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionCard() {
    final step = _step;
    final canGoBack = _currentStepIndex > 0;
    final isLastStep = _currentStepIndex >= vcrSteps.length - 1;

    return FadeSlideIn(
      delay: const Duration(milliseconds: 100),
      child: VcrFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VcrStepIndicator(
              totalSteps: vcrSteps.length,
              currentStep: _currentStepIndex,
              onStepTap: _goToStep,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkBlue,
                  ),
                ),
                Text(
                  '$_capturedCount/${step.captures.length} captured',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBodyMuted,
                  ),
                ),
              ],
            ),
            if (step.examples.isNotEmpty) ...[
              SizedBox(height: 16.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textBodyMuted,
                  ),
                  children: [
                    TextSpan(
                      text: 'Example Photos ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '(Use these as a guide)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 140.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: step.examples.length,
                  separatorBuilder: (_, index) => SizedBox(width: 12.w),
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
            SizedBox(height: 16.h),
            Text(
              'Your Photos',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textBodyMuted,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 140.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: step.captures.length,
                separatorBuilder: (_, index) => SizedBox(width: 14.w),
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
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: _navButton(
                  label: 'Back',
                  enabled: canGoBack,
                  onTap: canGoBack ? _onBack : null,
                  isPrimary: false,
                )),
                SizedBox(width: 9.w),
                Expanded(child: _navButton(
                  label: isLastStep ? 'Submit' : 'Next',
                  enabled: true,
                  onTap: _onNext,
                  isPrimary: true,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textBodyMuted,
      ),
    );
  }

  Widget _vanDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedVan,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        filled: true,
        fillColor: AppColors.white,
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(focused: true),
      ),
      hint: Text(
        'Select van',
        style: TextStyle(fontSize: 13.sp, color: AppColors.textDarkBlue),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textDarkBlue,
          size: 22.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.textPlaceholder),
        ),
      ),
      style: TextStyle(
        fontSize: 13.sp,
        color: AppColors.textDarkBlue,
      ),
      items: _allocatedVans
          .map((van) => DropdownMenuItem(value: van, child: Text(van)))
          .toList(),
      onChanged: _allocatedVans.isEmpty
          ? null
          : (val) => setState(() => _selectedVan = val),
    );
  }

  Widget _notesField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _notesFocused
              ? AppColors.accentBlue
              : AppColors.textPlaceholder,
          width: _notesFocused ? 1 : 0.5,
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        onTap: () => setState(() => _notesFocused = true),
        onTapOutside: (_) => setState(() => _notesFocused = false),
        style: TextStyle(fontSize: 13.sp, color: AppColors.textDarkBlue),
        decoration: InputDecoration(
          hintText: 'Quick notes...',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: AppColors.inputPlaceholder,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: focused ? AppColors.accentBlue : AppColors.textPlaceholder,
        width: focused ? 1 : 1,
      ),
    );
  }

  Widget _navButton({
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
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryBlue
              : (enabled
                  ? AppColors.white
                  : AppColors.buttonDisabledBackground),
          borderRadius: BorderRadius.circular(8.r),
          border: isPrimary
              ? null
              : Border.all(
                  color: enabled
                      ? AppColors.textPlaceholder
                      : Colors.transparent,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: isPrimary
                ? AppColors.highlightYellow
                : (enabled
                    ? AppColors.textDarkBlue
                    : AppColors.inputPlaceholder),
          ),
        ),
      ),
    );
  }
}
