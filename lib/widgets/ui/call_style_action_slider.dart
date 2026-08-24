import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CallStyleActionSlider extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onConfirm;

  const CallStyleActionSlider({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.icon,
    required this.isEnabled,
    required this.onConfirm,
  });

  @override
  State<CallStyleActionSlider> createState() => _CallStyleActionSliderState();
}

class _CallStyleActionSliderState extends State<CallStyleActionSlider>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _springAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CallStyleActionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = 40.h;
    final sliderHeight = 48.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDragDistance = constraints.maxWidth - thumbSize - 8.w;

        return Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.45,
          child: Container(
            height: sliderHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.backgroundColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(sliderHeight / 2),
              border: Border.all(
                color: widget.backgroundColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Shimmering instruction text
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: widget.backgroundColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 14.sp,
                        color: widget.backgroundColor.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),

                // Draggable thumb
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final currentOffset = _animationController.isAnimating
                        ? _springAnimation.value
                        : _dragOffset;

                    return Positioned(
                      left: 4.w + currentOffset,
                      child: GestureDetector(
                        onHorizontalDragUpdate: widget.isEnabled
                            ? (details) {
                                setState(() {
                                  _dragOffset = (_dragOffset + details.delta.dx)
                                      .clamp(0.0, maxDragDistance);
                                });
                              }
                            : null,
                        onHorizontalDragEnd: widget.isEnabled
                            ? (details) {
                                if (_dragOffset >= maxDragDistance * 0.75) {
                                  widget.onConfirm();
                                  setState(() {
                                    _dragOffset = 0.0;
                                  });
                                } else {
                                  _springAnimation = Tween<double>(
                                    begin: _dragOffset,
                                    end: 0.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: Curves.easeOutBack,
                                    ),
                                  );
                                  _animationController.forward(from: 0.0);
                                }
                              }
                            : null,
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: widget.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.backgroundColor.withValues(alpha: 0.4),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 18.sp,
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
