import 'package:chumley_navigator/models/fixed_price_model.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceCatalogStep extends StatelessWidget {
  const FixedPriceCatalogStep({
    super.key,
    required this.theme,
    required this.selectedTrade,
    required this.selectedCategory,
    required this.selectedWorkType,
    required this.trades,
    required this.categories,
    required this.workTypes,
    required this.loadingCategories,
    required this.loadingWorkTypes,
    required this.isLoading,
    required this.isError,
    required this.onRetry,
    required this.onTradeChanged,
    required this.onCategoryChanged,
    required this.onWorkTypeChanged,
    required this.tradeSearchController,
    required this.categorySearchController,
    required this.workTypeSearchController,
    required this.getTradeName,
    required this.getCategoryName,
    required this.getWorkTypeName,
  });

  final DashboardTheme theme;
  final String? selectedTrade;
  final String? selectedCategory;
  final String? selectedWorkType;
  final List<FixedPriceModel> trades;
  final List<FixedPriceCategoryModel> categories;
  final List<FixedPriceWorkTypeModel> workTypes;
  final bool loadingCategories;
  final bool loadingWorkTypes;
  final bool isLoading;
  final bool isError;
  final VoidCallback onRetry;
  final ValueChanged<String?> onTradeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onWorkTypeChanged;
  final TextEditingController tradeSearchController;
  final TextEditingController categorySearchController;
  final TextEditingController workTypeSearchController;
  final String Function(String?) getTradeName;
  final String Function(String?) getCategoryName;
  final String Function(String?) getWorkTypeName;

  Widget _buildShimmerDropdown(String label) {
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

  @override
  Widget build(BuildContext context) {
    if (isLoading && trades.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildShimmerDropdown('Please Select Trade *'),
          SizedBox(height: 12.h),
          _buildShimmerDropdown('Please Select Category *'),
          SizedBox(height: 12.h),
          _buildShimmerDropdown('Please Select Work Type *'),
        ],
      );
    }

    if (isError && trades.isEmpty) {
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
                onPressed: onRetry,
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
        FixedPriceUiHelpers.buildDropdownField(
          label: 'Please Select Trade *',
          value: selectedTrade,
          items: tradeIds,
          hintText: 'Select Trade',
          onChanged: onTradeChanged,
          theme: theme,
          itemLabelBuilder: (id) => getTradeName(id),
          searchController: tradeSearchController,
        ),
        SizedBox(height: 12.h),
        if (loadingCategories && categories.isEmpty)
          _buildShimmerDropdown('Please Select Category *')
        else
          FixedPriceUiHelpers.buildDropdownField(
            label: 'Please Select Category *',
            value: selectedCategory,
            items: categories.map((c) => c.id).toList(),
            hintText: selectedTrade == null
                ? 'Select Trade first'
                : 'Select Category',
            onChanged: selectedTrade == null ? null : onCategoryChanged,
            theme: theme,
            itemLabelBuilder: (id) => getCategoryName(id),
            searchController: categorySearchController,
          ),
        SizedBox(height: 12.h),
        if (loadingWorkTypes && workTypes.isEmpty)
          _buildShimmerDropdown('Please Select Work Type *')
        else
          FixedPriceUiHelpers.buildDropdownField(
            label: 'Please Select Work Type *',
            value: selectedWorkType,
            items: workTypes.map((w) => w.id).toList(),
            hintText: selectedCategory == null
                ? 'Select Category first'
                : 'Select Work Type',
            onChanged: selectedCategory == null ? null : onWorkTypeChanged,
            theme: theme,
            itemLabelBuilder: (id) => getWorkTypeName(id),
            searchController: workTypeSearchController,
          ),
      ],
    );
  }
}
