import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

class EnquiriesScreen extends StatefulWidget {
  EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  final List<String> _enquiryCategory = [
    "job Issue",
    "Payment Query",
    "Equipment Problem",
    "Safety Concern",
    "IT Support",
    "HR Matter",
    "Other",
  ];
  String? _selectedCategory;
  final _descriptionController = TextEditingController();

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
          child: Column(
            children: [
              AspectBranding(),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.chartFillBlue,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submit an Enquiry",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppColors.textDarkBlue,
                      ),
                    ),
                    Text(
                      "We\'re here to help with any issue",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _issueDropdown(),
                    SizedBox(height: 12.h),
                    Text(
                      "Detailed Description",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    _descriptionField(),
                    SizedBox(height: 12.h),
                    _submitButton(() {}),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Active Enquiries",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp,
                    color: AppColors.textDarkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Issue dropdown ─────────────────────────────────────────────────


  Widget _issueDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedCategory,
      isExpanded: true,

      // ── Field border (outer) ─────────────────────────────────
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.chartFillBlue, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.chartFillBlue, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.chartFillBlue, width: 0.5),
        ),
      ),

      hint: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            'Select a category',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),

      // ── Dropdown arrow icon ──────────────────────────────────
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textDarkBlue,
          size: 20.sp,
        ),
      ),

      // ── Popup menu styling ───────────────────────────────────
      dropdownStyleData: DropdownStyleData(
        elevation: 2,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.chartFillBlue, width: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),

      // ── Each menu item padding ───────────────────────────────
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 42.h,
      ),

      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textDarkBlue,
      ),

      items: _enquiryCategory
          .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
          .toList(),

      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  // ── Description text field ─────────────────────────────────────────────────
  Widget _descriptionField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.chartFillBlue, width: 0.8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        style: TextStyle(fontSize: 13.sp, color: AppColors.textDarkBlue),
        decoration: InputDecoration(
          hintText: 'Describe your issue in detail…',
          hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
    );
  }

  Widget _submitButton(GestureTapCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Submit Enquiry',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: AppColors.highlightYellow,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.note_add_outlined,
              size: 20.sp,
              color: AppColors.highlightYellow,
            ),
          ],
        ),
      ),
    );
  }
}
