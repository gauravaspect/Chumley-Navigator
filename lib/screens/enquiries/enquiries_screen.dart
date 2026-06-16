import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  void dispose() {
    _descriptionController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
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
                    top: _brandingExpandedHeight + 28,
                    bottom: 112.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Opacity(
                            opacity: (1.0 - progress).clamp(0.0, 1.0),
                            child: Text(
                              'Enquiries',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: theme.textBody,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 14.h),
                      FadeSlideIn(
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: theme.cardDecoration(radius: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUBMIT ENQUIRY',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: theme.textBody,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "We're here to help with any issue",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: theme.textMuted,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _issueDropdown(theme),
                              SizedBox(height: 12.h),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textMuted,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              _descriptionField(theme),
                              SizedBox(height: 14.h),
                              _SubmitButton(theme: theme),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'ACTIVE ENQUIRIES',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _EmptyEnquiriesCard(theme: theme),
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
                        title: Text(
                          'Enquiries',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: theme.textBody,
                          ),
                        ),
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

  InputBorder _fieldBorder(DashboardTheme theme, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: focused ? theme.accent : theme.border,
        width: 0.5,
      ),
    );
  }

  Widget _issueDropdown(DashboardTheme theme) {
    return DropdownButtonFormField2<String>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.surfaceDeep,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        border: _fieldBorder(theme),
        enabledBorder: _fieldBorder(theme),
        focusedBorder: _fieldBorder(theme, focused: true),
      ),
      hint: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.textMuted,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            'Select a category',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.textMuted,
            ),
          ),
        ],
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
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        height: 40.h,
      ),
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: theme.text,
      ),
      items: _enquiryCategory
          .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  Widget _descriptionField(DashboardTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _descriptionFocused ? theme.accent : theme.border,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        onTap: () => setState(() => _descriptionFocused = true),
        onTapOutside: (_) => setState(() => _descriptionFocused = false),
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: theme.text,
        ),
        decoration: InputDecoration(
          hintText: 'Describe your issue in detail…',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: theme.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Submit enquiry',
      button: true,
      child: PressableScale(
        onTap: () {},
        scale: 0.98,
        child: Container(
          width: double.infinity,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Submit enquiry',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.send_rounded,
                size: 16.sp,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyEnquiriesCard extends StatelessWidget {
  const _EmptyEnquiriesCard({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: theme.surfaceDeep,
        border: Border.all(color: theme.border, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 28.sp,
            color: theme.textMuted,
          ),
          SizedBox(height: 8.h),
          Text(
            'No active enquiries',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Submitted enquiries will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
