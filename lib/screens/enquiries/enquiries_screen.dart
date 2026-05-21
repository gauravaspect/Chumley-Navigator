import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/primary_cta_button.dart';
import 'package:chumley_navigator/widgets/ui/screen_title_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  final List<String> _enquiryCategory = [
    'job Issue',
    'Payment Query',
    'Equipment Problem',
    'Safety Concern',
    'IT Support',
    'HR Matter',
    'Other',
  ];
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  bool _descriptionFocused = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectBranding(),
              SizedBox(height: 20.h),
              FadeSlideIn(
                child: ElevatedSurface(
                  padding: EdgeInsets.all(20.r),
                  borderRadius: 22.r,
                  borderColor: AppColors.chartFillBlue.withValues(alpha: 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenTitleBlock(
                        title: 'Submit an Enquiry',
                        subtitle: "We're here to help with any issue",
                        titleSize: 18.sp,
                      ),
                      SizedBox(height: 18.h),
                      _issueDropdown(),
                      SizedBox(height: 16.h),
                      Text(
                        'Detailed Description',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _descriptionField(),
                      SizedBox(height: 20.h),
                      PrimaryCtaButton(
                        label: 'Submit Enquiry',
                        icon: Icons.send_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Active Enquiries',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  letterSpacing: -0.2,
                  color: AppColors.textDarkBlue,
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  InputBorder _fieldBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: focused
            ? AppColors.accentBlue.withValues(alpha: 0.65)
            : AppColors.chartFillBlue.withValues(alpha: 0.55),
        width: focused ? 1 : 0.5,
      ),
    );
  }

  Widget _issueDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceLightBlue.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(focused: true),
      ),
      hint: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            'Select a category',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textDarkBlue,
          size: 22.sp,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: 8,
        decoration: BoxDecoration(
          color: ElevatedSurface.tintedFill,
          border: Border.all(
            color: AppColors.borderDefault.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: ElevatedSurface.softShadows(),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 44.h,
      ),
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textDarkBlue,
      ),
      items: _enquiryCategory
          .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  Widget _descriptionField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _descriptionFocused
              ? AppColors.accentBlue.withValues(alpha: 0.55)
              : AppColors.chartFillBlue.withValues(alpha: 0.5),
          width: _descriptionFocused ? 1 : 0.5,
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        onTap: () => setState(() => _descriptionFocused = true),
        onTapOutside: (_) => setState(() => _descriptionFocused = false),
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.45,
          color: AppColors.textDarkBlue,
        ),
        decoration: InputDecoration(
          hintText: 'Describe your issue in detail…',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPlaceholder,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14.r),
        ),
      ),
    );
  }
}
