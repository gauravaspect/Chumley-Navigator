import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommandCentreBackButton extends StatelessWidget {
  const CommandCentreBackButton({
    super.key,
    required this.onTap,
    this.semanticsLabel = 'Back',
  });

  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: PressableScale(
          onTap: onTap,
          scale: 0.92,
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: theme.headerBellBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14.sp,
              color: theme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
