import 'package:chumley_navigator/pillar/visit_controller.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum RaiseLeadKind { ppm, pm, reactive, refer }

class RaiseLeadPage extends StatefulWidget {
  const RaiseLeadPage({
    super.key,
    required this.kind,
    required this.controller,
  });

  final RaiseLeadKind kind;
  final VisitController controller;

  static Future<bool?> open(
    BuildContext context, {
    required RaiseLeadKind kind,
    required VisitController controller,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RaiseLeadPage(kind: kind, controller: controller),
      ),
    );
  }

  @override
  State<RaiseLeadPage> createState() => _RaiseLeadPageState();
}

class _RaiseLeadPageState extends State<RaiseLeadPage> {
  final _message = TextEditingController();
  final _buddy = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    _buddy.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.kind) {
      case RaiseLeadKind.ppm:
        return 'PPM lead';
      case RaiseLeadKind.pm:
        return 'PM project lead';
      case RaiseLeadKind.reactive:
        return 'Hourly attendance';
      case RaiseLeadKind.refer:
        return 'Refer and earn';
    }
  }

  Future<void> _submit() async {
    final message = _message.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Describe the issue before sending.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      switch (widget.kind) {
        case RaiseLeadKind.ppm:
          await widget.controller.raiseEnquiry(
            category: 'PPM_INTEREST',
            subject: 'PPM interest',
            message: message,
          );
        case RaiseLeadKind.pm:
          await widget.controller.raiseEnquiry(
            category: 'PM_INTEREST',
            subject: 'PM project interest',
            message: message,
          );
        case RaiseLeadKind.reactive:
          await widget.controller.raiseEnquiry(
            category: 'EMERGENCY',
            subject: 'Reactive attendance',
            message: message,
          );
        case RaiseLeadKind.refer:
          await widget.controller.raiseReferral(
            buddyName: _buddy.text.trim().isEmpty ? 'Referral' : _buddy.text.trim(),
            description: message,
            scope: message,
            totalPrice: 0,
          );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  CommandCentreBackButton(
                    onTap: () => Navigator.of(context).maybePop(false),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1F3A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  if (widget.kind == RaiseLeadKind.refer) ...[
                    Text(
                      'Buddy / referred customer',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A6B85),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _buddy,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  Text(
                    widget.kind == RaiseLeadKind.reactive
                        ? 'Issue description'
                        : 'Notes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5A6B85),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _message,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'What should the office see?',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF23D),
                    foregroundColor: const Color(0xFF0B1F3A),
                  ),
                  child: Text(_submitting ? 'Sending…' : 'Send to office'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
