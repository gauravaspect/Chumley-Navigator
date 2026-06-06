import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AbsenceFormCard extends StatelessWidget {
  const AbsenceFormCard({
    super.key,
    required this.child,
    this.padding,
    this.showShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final decoration = theme.dashCardDecoration(radius: 20, softBorder: true);

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.r),
      decoration: showShadow
          ? decoration
          : decoration.copyWith(boxShadow: const []),
      child: child,
    );
  }
}
