import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class XPFloatLabel extends StatefulWidget {
  final int amount;
  final VoidCallback onDone;

  const XPFloatLabel({
    super.key,
    required this.amount,
    required this.onDone,
  });

  @override
  State<XPFloatLabel> createState() => _XPFloatLabelState();
}

class _XPFloatLabelState extends State<XPFloatLabel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.06),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.3),
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Text(
                  "+${widget.amount} XP",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kpiBarHigh,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
