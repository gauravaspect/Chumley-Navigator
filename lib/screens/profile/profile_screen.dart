import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/storage/prefs.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:chumley_navigator/screens/dashboard/cubit/dashboard_state.dart';
import 'package:chumley_navigator/screens/login/cubit/login_cubit.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/utils/user_display.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/profile/profile_info_row.dart';
import 'package:chumley_navigator/widgets/profile/profile_stat_grid_card.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _GridItem {
  const _GridItem({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static void open(BuildContext context, DashboardCubit cubit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const ProfileScreen()),
      ),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _fallbackUser;

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
    Prefs.getUser().then((user) {
      if (mounted && user != null) {
        setState(() => _fallbackUser = user);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final user = _resolveUser(state);
        return _ProfileContent(
          user: user,
          gridItems: _gridItems(user),
          scrollController: _scrollController,
          brandingCollapsedHeight: _brandingCollapsedHeight,
          brandingExpandedHeight: _brandingExpandedHeight,
          collapseProgress: _collapseProgress,
        );
      },
    );
  }

  UserModel _resolveUser(DashboardState state) {
    return state.userOrNull ?? _fallbackUser ?? const UserModel();
  }

  List<_GridItem> _gridItems(UserModel user) {
    final metrics = user.aspect.metrics;
    final bio = user.bio;

    String metric(String key) {
      final value = metrics[key];
      if (value == null) return '—';
      if (value is num) {
        return value == value.toInt()
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
      }
      return value.toString().trim().isEmpty ? '—' : value.toString();
    }

    final skillsBody = bio.skills.isNotEmpty
        ? bio.skills.length.toString()
        : metric('skills');

    final yearsBody = bio.yearsOfService > 0
        ? '${bio.yearsOfService} years'
        : '—';

    return [
      _GridItem(
        icon: LucideIcons.star,
        title: 'Engineer Satisfaction',
        body: metric('engineer_satisfaction_survey'),
      ),
      _GridItem(icon: LucideIcons.lightbulb, title: 'Skills', body: skillsBody),
      _GridItem(
        icon: LucideIcons.mapPin,
        title: 'Sites Covered',
        body: metric('sites_covered'),
      ),
      _GridItem(
        icon: LucideIcons.badgeCheck,
        title: 'Qualified Wts',
        body: metric('qualified_wts'),
      ),
      _GridItem(
        icon: LucideIcons.user,
        title: 'Manager',
        body: bio.allocatedManager.trim().isEmpty
            ? '—'
            : bio.allocatedManager.trim(),
      ),
      _GridItem(
        icon: LucideIcons.calendar,
        title: 'Years of Service',
        body: yearsBody,
      ),
    ];
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.gridItems,
    required this.scrollController,
    required this.brandingCollapsedHeight,
    required this.brandingExpandedHeight,
    required this.collapseProgress,
  });

  final UserModel user;
  final List<_GridItem> gridItems;
  final ScrollController scrollController;
  final ValueNotifier<double> collapseProgress;
  final double brandingExpandedHeight;
  final double brandingCollapsedHeight;

  String _display(String value, [String fallback = '—']) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
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
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: brandingExpandedHeight + 28,
                    bottom: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: collapseProgress,
                        builder: (context, progress, _) {
                          return Opacity(
                            opacity: (1.0 - progress).clamp(0.0, 1.0),
                            child: Text(
                              'User profile',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: theme.dashTitle,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 14.h),
                      FadeSlideIn(
                        child: _ProfileHeroCard(theme: theme, user: user),
                      ),
                      SizedBox(height: 10.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _SectionLabel(theme: theme, label: 'DETAILS'),
                      ),
                      SizedBox(height: 8.h),
                      ProfileInfoRow(
                        label: 'Trade',
                        value: _display(user.bio.trade),
                      ),
                      ProfileInfoRow(
                        label: 'Position',
                        value: _display(user.position),
                      ),
                      if (user.bio.rateTier.trim().isNotEmpty)
                        ProfileInfoRow(
                          label: 'Rate tier',
                          value: user.bio.rateTier.trim(),
                        ),
                      if (user.bio.description.trim().isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        ProfileInfoRow(
                          label: 'About',
                          value: user.bio.description.trim(),
                        ),
                      ],
                      SizedBox(height: 6.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: _SectionLabel(theme: theme, label: 'STATS'),
                      ),
                      SizedBox(height: 8.h),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          childAspectRatio: 1.08,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gridItems.length,
                        itemBuilder: (context, index) {
                          final data = gridItems[index];
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 35 * index),
                            offsetY: 8,
                            child: ProfileStatGridCard(
                              icon: data.icon,
                              title: data.title,
                              body: data.body,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 6.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: _AddressTile(
                          theme: theme,
                          address: user.bio.address,
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        child: _AppearanceToggle(theme: theme),
                      ),
                      SizedBox(height: 10.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: _LogoutButton(theme: theme),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: collapseProgress,
                  builder: (context, progress, _) {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AspectBranding(
                        progress: progress,
                        expandedHeight: brandingExpandedHeight,
                        collapsedHeight: brandingCollapsedHeight,
                        theme: theme,
                        hasBackButton: true,
                        title: Text(
                          'User profile',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: theme.dashTitle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8.h,
                  left: 16.w,
                  child: CommandCentreBackButton(
                    onTap: () => Navigator.of(context).pop(),
                    semanticsLabel: 'Back to home',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.theme, required this.label});

  final DashboardTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: theme.textMuted,
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.theme, required this.user});

  final DashboardTheme theme;
  final UserModel user;

  String _subtitle() {
    if (user.position.trim().isNotEmpty) return user.position.trim();
    if (user.bio.trade.trim().isNotEmpty) return user.bio.trade.trim();
    return 'Engineer';
  }

  String _ratingLabel() {
    if (user.overallRating <= 0) return 'Overall rating: —';
    return 'Overall rating: ${user.overallRating.toStringAsFixed(1)}';
  }

  Widget _initialsAvatar() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        userInitials(user),
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _avatar() {
    final photoUrl = user.photoUrl.trim();
    if (photoUrl.isEmpty) return _initialsAvatar();

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 80.w,
        height: 80.w,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _initialsAvatar();
        },
        errorBuilder: (context, error, stackTrace) => _initialsAvatar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: theme.cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            width: 88.w,
            height: 88.w,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _avatar(),
                Positioned(
                  right: 0,
                  top: 0,
                  child: PressableScale(
                    onTap: () {},
                    scale: 0.9,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: theme.surfaceDeep,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.border, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.edit_outlined,
                        color: theme.textMuted,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            user.name.trim().isEmpty ? 'Engineer' : user.name.trim(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _subtitle(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _ratingLabel(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.isDark
                  ? AppColors.kpiBarHigh
                  : AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceToggle extends StatelessWidget {
  const _AppearanceToggle({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeScope.of(context);

    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        final isDark = themeNotifier.isDark;

        return Container(
          margin: EdgeInsets.only(top: 6.h, bottom: 6.h),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.textMuted,
              size: 22.sp,
            ),
            title: Text(
              'Dark mode',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: theme.text,
              ),
            ),
            subtitle: Text(
              isDark ? 'Command centre theme' : 'Light theme',
              style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
            ),
            value: isDark,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primaryBlue,
            inactiveTrackColor: theme.progressTrack,
            onChanged: themeNotifier.setDark,
          ),
        );
      },
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.theme, required this.address});

  final DashboardTheme theme;
  final String address;

  @override
  Widget build(BuildContext context) {
    final displayAddress = address.trim().isEmpty
        ? 'No address on file'
        : address.trim();

    return Semantics(
      label: 'Residential Post Code',
      button: true,
      child: PressableScale(
        onTap: () {},
        scale: 0.99,
        child: Container(
          padding: EdgeInsets.all(12.r),
          margin: EdgeInsets.only(bottom: 6.h),
          decoration: BoxDecoration(
            color: theme.surfaceDeep,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: theme.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_on_outlined,
                  color: theme.isDark
                      ? AppColors.kpiBarHigh
                      : AppColors.primaryBlue,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Residential Post Code',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      displayAddress,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: theme.text,
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
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Log out',
      button: true,
      child: PressableScale(
        onTap: () async {
          await context.read<LoginCubit>().logout();
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
        scale: 0.98,
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: AppColors.streakOrange, width: 0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18.sp,
                color: AppColors.streakOrange,
              ),
              SizedBox(width: 6.w),
              Text(
                'Log out',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.streakOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
