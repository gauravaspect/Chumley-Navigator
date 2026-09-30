import 'dart:io';

import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EnquiryStatus { inReview, resolved }

class EnquiryItem {
  const EnquiryItem({
    required this.id,
    required this.subtitle,
    required this.status,

    /// How many of the 4 steps are complete (1–4).
    required this.completedSteps,
  });

  final String id;
  final String subtitle;
  final EnquiryStatus status;
  final int completedSteps;
}

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  static const _categories = [
    'Job Issue',
    'Payment Query',
    'Equipment Problem',
    'Safety Concern',
    'IT Support',
    'HR Matter',
    'Other',
  ];

  static const _stepLabels = ['Submitted', 'Assigned', 'Reviewing', 'Resolved'];

  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;
  final _imagePicker = ImagePicker();
  final List<XFile> _attachments = [];

  /// Prototype sample enquiries.
  final List<EnquiryItem> _enquiries = [
    const EnquiryItem(
      id: 'ENQ-29384',
      subtitle: 'Est. resolution in 2–4 hours',
      status: EnquiryStatus.inReview,
      completedSteps: 3,
    ),
    const EnquiryItem(
      id: 'ENQ-08917',
      subtitle: 'Resolved today at 14:20',
      status: EnquiryStatus.resolved,
      completedSteps: 4,
    ),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _attachments.add(file));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not add photo. Try again.')),
        );
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _submit() {
    final category = _selectedCategory;
    final description = _descriptionController.text.trim();
    if (category == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Select an issue category.')),
        );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Add a detailed description.')),
        );
      return;
    }

    final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
    final id = 'ENQ-${stamp.toString().padLeft(5, '0')}';

    setState(() {
      _enquiries.insert(
        0,
        EnquiryItem(
          id: id,
          subtitle: 'Est. resolution in 2–4 hours',
          status: EnquiryStatus.inReview,
          completedSteps: 1,
        ),
      );
      _selectedCategory = null;
      _descriptionController.clear();
      _attachments.clear();
      _descriptionFocused = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Enquiry #$id submitted.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
                children: [
                  Text(
                    'Enquiries',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: theme.dashHeading,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Report an issue or track an enquiry',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.dashMuted,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  FadeSlideIn(
                    child: _SubmitEnquiryCard(
                      theme: theme,
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (v) =>
                          setState(() => _selectedCategory = v),
                      descriptionController: _descriptionController,
                      descriptionFocused: _descriptionFocused,
                      onDescriptionFocus: (focused) =>
                          setState(() => _descriptionFocused = focused),
                      attachments: _attachments,
                      onBrowse: () => _pickImage(ImageSource.gallery),
                      onTakePhoto: () => _pickImage(ImageSource.camera),
                      onRemoveAttachment: _removeAttachment,
                      onSubmit: _submit,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Active enquiries',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: theme.dashHeading,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_enquiries.isEmpty)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 40),
                      child: _EmptyEnquiriesCard(theme: theme),
                    )
                  else
                    for (var i = 0; i < _enquiries.length; i++) ...[
                      if (i > 0) SizedBox(height: 10.h),
                      FadeSlideIn(
                        delay: Duration(milliseconds: 40 + (i * 40)),
                        child: _EnquiryCard(
                          theme: theme,
                          item: _enquiries[i],
                          stepLabels: _stepLabels,
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubmitEnquiryCard extends StatelessWidget {
  const _SubmitEnquiryCard({
    required this.theme,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.descriptionController,
    required this.descriptionFocused,
    required this.onDescriptionFocus,
    required this.attachments,
    required this.onBrowse,
    required this.onTakePhoto,
    required this.onRemoveAttachment,
    required this.onSubmit,
  });

  final DashboardTheme theme;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController descriptionController;
  final bool descriptionFocused;
  final ValueChanged<bool> onDescriptionFocus;
  final List<XFile> attachments;
  final VoidCallback onBrowse;
  final VoidCallback onTakePhoto;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final fieldFill = theme.isDark
        ? theme.dashSurfaceTint
        : const Color(0xFFE9EDF5);
    final hairline = theme.isDark
        ? theme.dashBorderLight
        : const Color(0xFFE2E7F0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: theme.dashCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit an enquiry',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: theme.dashHeading,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Issue category',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: theme.dashSubtitle,
            ),
          ),
          SizedBox(height: 7.h),
          DropdownButtonFormField2<String>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 4.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.dashPrimary, width: 1.25),
              ),
            ),
            hint: Text(
              'Select',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: theme.dashHeading,
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                LucideIcons.chevronDown,
                color: const Color(0xFF8A99B0),
                size: 18.sp,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: theme.dashCardBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: hairline),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              height: 42.h,
            ),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: theme.dashHeading,
            ),
            items: categories
                .map(
                  (cat) =>
                      DropdownMenuItem<String>(value: cat, child: Text(cat)),
                )
                .toList(),
            onChanged: onCategoryChanged,
          ),
          SizedBox(height: 16.h),
          Text(
            'Detailed description',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: theme.dashSubtitle,
            ),
          ),
          SizedBox(height: 7.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: descriptionFocused ? theme.dashPrimary : hairline,
                width: descriptionFocused ? 1.25 : 1,
              ),
            ),
            child: TextField(
              controller: descriptionController,
              maxLines: 4,
              onTap: () => onDescriptionFocus(true),
              onTapOutside: (_) => onDescriptionFocus(false),
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.45,
                color: theme.dashHeading,
              ),
              decoration: InputDecoration(
                hintText: 'Describe exactly what happened…',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF8A99B0),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 54.h),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _PhotoUploadZone(
            theme: theme,
            attachments: attachments,
            onBrowse: onBrowse,
            onTakePhoto: onTakePhoto,
            onRemove: onRemoveAttachment,
          ),
          SizedBox(height: 16.h),
          PressableScale(
            onTap: onSubmit,
            scale: 0.98,
            child: Container(
              width: double.infinity,
              height: 44.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentLime,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                'Submit enquiry',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDarkBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadZone extends StatelessWidget {
  const _PhotoUploadZone({
    required this.theme,
    required this.attachments,
    required this.onBrowse,
    required this.onTakePhoto,
    required this.onRemove,
  });

  final DashboardTheme theme;
  final List<XFile> attachments;
  final VoidCallback onBrowse;
  final VoidCallback onTakePhoto;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final dashed = theme.isDark
        ? theme.dashBorderLight
        : const Color(0xFFD3DBE8);
    final fill = theme.isDark ? theme.dashSurfaceTint : const Color(0xFFE9EDF5);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dashed, width: 1.25),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.image, size: 22.sp, color: theme.dashPrimary),
          SizedBox(height: 9.h),
          Text(
            'Add photos to speed things up (optional)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.dashTitle,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'You can upload JPG, PNG or PDF up to 10MB each.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: theme.dashMuted,
            ),
          ),
          if (attachments.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 64.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final file = attachments[index];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.file(
                          File(file.path),
                          width: 64.w,
                          height: 64.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 64.w,
                            height: 64.h,
                            color: theme.dashCardBg,
                            alignment: Alignment.center,
                            child: Icon(
                              LucideIcons.file,
                              size: 18.sp,
                              color: theme.dashMuted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => onRemove(index),
                          child: Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: theme.dashPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.x,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PressableScale(
                onTap: onBrowse,
                child: Container(
                  height: 36.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.dashPrimary,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Text(
                    'Browse files',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              PressableScale(
                onTap: onTakePhoto,
                child: Container(
                  height: 36.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accentLime,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Text(
                    'Take a photo',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({
    required this.theme,
    required this.item,
    required this.stepLabels,
  });

  final DashboardTheme theme;
  final EnquiryItem item;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    final isResolved = item.status == EnquiryStatus.resolved;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: theme.dashCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enquiry #${item.id}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.dashHeading,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A99B0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _StatusChip(resolved: isResolved),
            ],
          ),
          SizedBox(height: 14.h),
          _EnquiryProgress(
            theme: theme,
            labels: stepLabels,
            completedSteps: item.completedSteps.clamp(0, 4),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.resolved});

  final bool resolved;

  @override
  Widget build(BuildContext context) {
    final bg = resolved ? const Color(0xFFE9F8EF) : const Color(0xFFD8E6FC);
    final fg = resolved ? const Color(0xFF15803D) : AppColors.primaryBlue;

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 5.h, 12.w, 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(500.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            resolved ? 'Resolved' : 'In review',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnquiryProgress extends StatelessWidget {
  const _EnquiryProgress({
    required this.theme,
    required this.labels,
    required this.completedSteps,
  });

  final DashboardTheme theme;
  final List<String> labels;
  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    final navy = theme.dashPrimary;
    final tint = theme.isDark ? theme.dashSurfaceTint : const Color(0xFFD8E6FC);
    final doneLabel = theme.dashSubtitle;
    final pendingLabel = const Color(0xFF8A99B0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 18.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == 0
                              ? Colors.transparent
                              : (i < completedSteps ? navy : tint),
                        ),
                      ),
                      if (i < completedSteps)
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: navy,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.check,
                            size: 11.sp,
                            color: Colors.white,
                          ),
                        )
                      else
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: tint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == labels.length - 1
                              ? Colors.transparent
                              : (i + 1 < completedSteps ? navy : tint),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                    color: i < completedSteps ? doneLabel : pendingLabel,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyEnquiriesCard extends StatelessWidget {
  const _EmptyEnquiriesCard({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
      decoration: theme.dashCardDecoration(radius: 20),
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 28.sp, color: theme.dashMuted),
          SizedBox(height: 10.h),
          Text(
            'No active enquiries',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.dashHeading,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Submitted enquiries will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: theme.dashMuted),
          ),
        ],
      ),
    );
  }
}
