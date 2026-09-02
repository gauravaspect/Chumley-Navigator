import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/screens/forms/damp_survey_form_page.dart';
import 'package:chumley_navigator/screens/forms/form_details.dart';
import 'package:chumley_navigator/screens/forms/ld_form_page.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene_form_page.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {

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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }


  void _openForm(BuildContext context, FormType type) {
    final Widget page;
    switch (type) {
      case FormType.LDForm:
        page = const LdFormPage();
      case FormType.DampSurveyForm:
        page = const DampSurveyFormPage();
      case FormType.VentHygeineForm:
        page = const VentHygieneFormPage();
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: _brandingExpandedHeight + 28,
                    bottom: 180.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Opacity(
                            opacity: (1.0 - progress).clamp(0.0, 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Forms',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: theme.dashTitle,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'Select a work type to start a new form',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 14.h),
                      // LD FORM commented out for now — keeping only HVAC
                      // FadeSlideIn(
                      //   child: _FormListTile(
                      //     icon: LucideIcons.zap,
                      //     title: 'LD FORM',
                      //     subtitle:
                      //     'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
                      //     onTap: () => _openForm(context, FormType.LDForm),
                      //   ),
                      // ),
                      // SizedBox(height: 8.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _FormListTile(
                          icon: LucideIcons.droplets,
                          title: 'Damp Survey Form',
                          subtitle: 'Surface / depth readings · BS 5250:2021',
                          onTap: () => _openForm(context, FormType.DampSurveyForm),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _FormListTile(
                          icon: LucideIcons.wind,
                          title: 'Vent Hygiene Forms',
                          subtitle: 'Vent heat loss calculation · BS 8204:2011',
                          onTap: () => _openForm(context, FormType.VentHygeineForm),
                        ),
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
                          'Forms',
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
            ),
          ),
        );
      },
    );
  }
}

class _FormListTile extends StatelessWidget {
  const _FormListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return PressableScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border, width: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: theme.surfaceDeep,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              child: Icon(
                icon,
                color: theme.isDark
                    ? AppColors.kpiBarHigh
                    : AppColors.primaryBlue,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textMuted,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.textMuted,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
