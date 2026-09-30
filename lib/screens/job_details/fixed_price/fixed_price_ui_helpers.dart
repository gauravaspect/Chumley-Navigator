import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceUiHelpers {
  static Widget buildDropdownField({
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
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: theme.textMuted,
                        ),
                        filled: true,
                        fillColor: theme.surfaceDeep,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.textMuted,
                          size: 18.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: theme.border,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: theme.border,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: theme.accent,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    final itemLabel = itemLabelBuilder != null
                        ? itemLabelBuilder(item.value ?? '')
                        : (item.value ?? '');
                    return itemLabel.toLowerCase().contains(
                      searchValue.toLowerCase(),
                    );
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

  static Widget buildMultilineTextField({
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

  static Widget buildCurrencyField({
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

  static Widget buildDecimalField({
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

  static Widget buildRadioButtonSection<T>({
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
          (opt) => buildRadioOption<T>(
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

  static Widget buildRadioOption<T>({
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

  static Widget buildToggleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required DashboardTheme theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
        ),
        SizedBox(width: 8.w),
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

  static Widget buildInfoRow(String label, String value, DashboardTheme theme) {
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

  static Widget buildSummaryIndicatorRow(String text, DashboardTheme theme) {
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

  static Widget buildChargeRow(
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14.sp : 13.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? theme.text : theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: 8.w),
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

  static Widget buildPricingSummaryItem(
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14.sp : 13.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? theme.text : theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: 8.w),
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

  static Widget buildDetailRow(
    String label,
    String value,
    DashboardTheme theme,
  ) {
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
}
