import 'package:chumley_navigator/screens/job/visit_form_widgets.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VisitWizardScaffold extends StatelessWidget {
  const VisitWizardScaffold({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.title,
    required this.child,
    required this.onSaveDraft,
    required this.onNext,
    this.onCancel,
    this.onStepTapped,
    this.jobNumber,
    this.subtitle,
    this.isLast = false,
    this.busy = false,
  });

  final int stepIndex;
  final int stepCount;
  final String title;
  final String? subtitle;
  final String? jobNumber;
  final Widget child;
  final VoidCallback onSaveDraft;
  final VoidCallback onNext;
  final VoidCallback? onCancel;
  final ValueChanged<int>? onStepTapped;
  final bool isLast;
  final bool busy;

  /// Step 1 (index 0): Cancel (exit). Later steps: Back (previous step).
  String get _cancelBackLabel => stepIndex == 0 ? 'Cancel' : 'Back';

  @override
  Widget build(BuildContext context) {
    final nextLabel = isLast ? 'Submit report' : 'Next';

    void handleCancel() {
      if (onCancel != null) {
        onCancel!();
        return;
      }
      Navigator.of(context).pop();
    }

    return Scaffold(
      backgroundColor: NavigatorTokens.surfaceChrome,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NavigatorTokens.pageGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                jobNumber: jobNumber,
                stepIndex: stepIndex,
                stepCount: stepCount,
                title: title,
                onBack: handleCancel,
                onStepTapped: onStepTapped,
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: Text(
                    subtitle!,
                    style: NavigatorTokens.captionStyle(13.sp),
                  ),
                ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  children: [child],
                ),
              ),
              _ActionBar(
                busy: busy,
                cancelLabel: _cancelBackLabel,
                nextLabel: nextLabel,
                onCancel: handleCancel,
                onSaveDraft: onSaveDraft,
                onNext: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.jobNumber,
    required this.stepIndex,
    required this.stepCount,
    required this.title,
    required this.onBack,
    this.onStepTapped,
  });

  final String? jobNumber;
  final int stepIndex;
  final int stepCount;
  final String title;
  final VoidCallback onBack;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NavigatorTokens.surfaceChrome,
        border: Border(
          bottom: BorderSide(color: NavigatorTokens.borderHairline),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  LucideIcons.chevronLeft,
                  color: NavigatorTokens.textPrimary,
                  size: 22.sp,
                ),
              ),
              Expanded(
                child: Text(
                  jobNumber ?? 'Visit form',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: NavigatorTokens.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 48.w),
            ],
          ),
          SizedBox(height: 6.h),
          VisitStepPills(
            stepIndex: stepIndex,
            stepCount: stepCount,
            onStepTapped: onStepTapped,
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: NavigatorTokens.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Step ${stepIndex + 1} of $stepCount',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: NavigatorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.cancelLabel,
    required this.nextLabel,
    required this.onCancel,
    required this.onSaveDraft,
    required this.onNext,
  });

  final bool busy;
  final String cancelLabel;
  final String nextLabel;
  final VoidCallback onCancel;
  final VoidCallback onSaveDraft;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: NavigatorTokens.surfaceCard,
        border: const Border(
          top: BorderSide(color: NavigatorTokens.borderHairline),
        ),
        boxShadow: NavigatorTokens.actionBarShadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: cancelLabel,
                  onPressed: busy ? null : onCancel,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GhostButton(
                  label: 'Save draft',
                  onPressed: busy ? null : onSaveDraft,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _PrimaryButton(
            label: nextLabel,
            busy: busy,
            onPressed: busy ? null : onNext,
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NavigatorTokens.brandNavySoft,
      borderRadius: NavigatorTokens.buttonRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: NavigatorTokens.buttonRadius,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: NavigatorTokens.buttonRadius,
            color: onPressed == null
                ? NavigatorTokens.brandNavySoft.withValues(alpha: 0.5)
                : NavigatorTokens.brandNavySoft,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: NavigatorTokens.brandNavy,
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: NavigatorTokens.buttonRadius,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: NavigatorTokens.buttonRadius,
            border: Border.all(color: NavigatorTokens.borderStrong),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: NavigatorTokens.brandNavy,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NavigatorTokens.brandNavy,
      borderRadius: NavigatorTokens.buttonRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: NavigatorTokens.buttonRadius,
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: NavigatorTokens.buttonRadius,
            color: onPressed == null
                ? NavigatorTokens.brandNavyDeep.withValues(alpha: 0.5)
                : NavigatorTokens.brandNavy,
          ),
          child: busy
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: NavigatorTokens.textInverse,
                  ),
                )
              : Text(label, style: NavigatorTokens.buttonLabelStyle(15.sp)),
        ),
      ),
    );
  }
}
