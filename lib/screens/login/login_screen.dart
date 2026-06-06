import 'package:chumley_navigator/screens/login/cubit/login_cubit.dart';
import 'package:chumley_navigator/screens/login/cubit/login_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is LoginError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return ListenableBuilder(
          listenable: ThemeScope.of(context),
          builder: (context, _) {
            final theme = DashboardTheme.of(context);
            final isDark = theme.isDark;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: isDark
                    ? Brightness.dark
                    : Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: isDark
                    ? AppColors.darkBase
                    : const Color(0xFFF7F6F3),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 360.w),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 24.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.surface,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: isDark
                                        ? theme.border
                                        : const Color(0xFFE3D8D8),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _ChumleyAspectLockup(isDark: isDark),
                                    SizedBox(height: 18.h),
                                    _LoginChip(
                                      isDark: isDark,
                                      icon: Icons.business_outlined,
                                      label: 'Office Suite',
                                    ),
                                    SizedBox(height: 14.h),
                                    Text(
                                      'Chumley Navigator for Office',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                        color: isDark
                                            ? theme.text
                                            : AppColors.brandRedDeep,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Sign in to securely access your organisation dashboard',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.45,
                                        color: theme.textMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 26.h),
                                    _MicrosoftSignInButton(
                                      isLoading: isLoading,
                                      onTap: () =>
                                          context.read<LoginCubit>().login(),
                                    ),
                                    SizedBox(height: 20.h),
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: isDark
                                          ? theme.border
                                          : const Color(0xFFEADDDD),
                                    ),
                                    SizedBox(height: 14.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.support_agent_outlined,
                                          size: 16.sp,
                                          color: theme.textMuted,
                                        ),
                                        SizedBox(width: 6.w),
                                        Flexible(
                                          child: Text(
                                            'Need help? +44 1908 024199',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: theme.textMuted,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LoginChip extends StatelessWidget {
  const _LoginChip({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  final bool isDark;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        color: isDark
            ? AppColors.brandRed.withValues(alpha: 0.15)
            : const Color(0xFFFFF4F4),
        border: Border.all(
          color: isDark
              ? AppColors.brandRed.withValues(alpha: 0.35)
              : const Color(0xFFEBCFCF),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.brandRed),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.brandRedSoft : AppColors.brandRedDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MicrosoftSignInButton extends StatelessWidget {
  const _MicrosoftSignInButton({required this.onTap, required this.isLoading});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: isLoading ? null : onTap,
      enabled: !isLoading,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.brandRed,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const _MicrosoftLogo(),
            SizedBox(width: 8.w),
            Text(
              isLoading ? 'Signing in...' : 'Continue with Microsoft',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                letterSpacing: 0.1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicrosoftLogo extends StatelessWidget {
  const _MicrosoftLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16.w,
      height: 16.w,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 2.w,
        children: const [
          _LogoSquare(color: Color(0xFFF25022)),
          _LogoSquare(color: Color(0xFF7FBA00)),
          _LogoSquare(color: Color(0xFF00A4EF)),
          _LogoSquare(color: Color(0xFFFFB900)),
        ],
      ),
    );
  }
}

class _LogoSquare extends StatelessWidget {
  const _LogoSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 7.w, height: 7.w, color: color);
  }
}

class _ChumleyAspectLockup extends StatelessWidget {
  const _ChumleyAspectLockup({required this.isDark});

  final bool isDark;

  Color get _logoBoxBg => isDark
      ? AppColors.brandRed.withValues(alpha: 0.12)
      : const Color(0xFFFFF4F4);

  Color get _logoBoxBorder => isDark
      ? AppColors.brandRed.withValues(alpha: 0.3)
      : const Color(0xFFEBCFCF);

  Color get _separatorColor =>
      isDark ? AppColors.darkTextMuted : const Color(0xFFFFDADA);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 32.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: _logoBoxBg,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _logoBoxBorder, width: 0.5),
          ),
          child: Image.asset(
            'assets/images/ChumleyLogo.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            'X',
            style: TextStyle(
              fontSize: 34.sp,
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: -0.6,
              color: _separatorColor,
            ),
          ),
        ),
        Container(
          width: 42.w,
          height: 42.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: _logoBoxBg,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _logoBoxBorder, width: 0.5),
          ),
          child: Image.asset(
            'assets/images/aspectLogoIcon.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
