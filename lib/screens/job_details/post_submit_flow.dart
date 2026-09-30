import 'package:chumley_navigator/screens/job_details/post_submit/follow_on_screen.dart';
import 'package:chumley_navigator/screens/job_details/post_submit/job_closed_screen.dart';
import 'package:chumley_navigator/screens/job_details/post_submit/job_completed_screen.dart';
import 'package:chumley_navigator/screens/job_details/post_submit/visit_complete_screen.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';

export 'package:chumley_navigator/screens/job_details/post_submit/follow_on_screen.dart';
export 'package:chumley_navigator/screens/job_details/post_submit/job_closed_screen.dart';
export 'package:chumley_navigator/screens/job_details/post_submit/job_completed_screen.dart';
export 'package:chumley_navigator/screens/job_details/post_submit/status_progress_timeline.dart';
export 'package:chumley_navigator/screens/job_details/post_submit/visit_complete_screen.dart';

enum PostSubmitPhase { jobCompleted, followOn, jobClosed, visitComplete }

/// Post-submit flow after form "Submit report":
/// Job completed → Follow-on → Job closed → Visit complete.
class PostSubmitFlow extends StatelessWidget {
  const PostSubmitFlow({
    super.key,
    required this.phase,
    required this.jobNumber,
    required this.customerName,
    required this.jobType,
    required this.workTypeLabel,
    required this.description,
    required this.onPhaseChanged,
    required this.onBackToHome,
    this.onCloseJob,
    this.onVisitComplete,
    this.onRaiseEstimate,
    this.onRaiseReactive,
    this.onRaiseMultipleFixedPrice,
    this.onReferAndEarn,
  });

  final PostSubmitPhase phase;
  final String jobNumber;
  final String customerName;
  final String jobType;
  final String workTypeLabel;
  final String description;
  final ValueChanged<PostSubmitPhase> onPhaseChanged;
  final VoidCallback onBackToHome;
  final VoidCallback? onCloseJob;
  final VoidCallback? onVisitComplete;
  final VoidCallback? onRaiseEstimate;
  final VoidCallback? onRaiseReactive;
  final VoidCallback? onRaiseMultipleFixedPrice;
  final VoidCallback? onReferAndEarn;

  static const _bgTop = Color(0xFFF4F9FF);
  static const _bgMid = Color(0xFFEDF4FE);
  static const _bgBottom = Color(0xFFE2ECFA);

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.isDark ? theme.base : null,
        gradient: theme.isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgMid, _bgBottom],
                stops: [0.0, 0.55, 1.0],
              ),
      ),
      child: switch (phase) {
        PostSubmitPhase.jobCompleted => JobCompletedScreen(
          jobNumber: jobNumber,
          jobType: jobType,
          workTypeLabel: workTypeLabel,
          customerName: customerName,
          description: description,
          onCloseJob:
              onCloseJob ?? () => onPhaseChanged(PostSubmitPhase.followOn),
        ),
        PostSubmitPhase.followOn => FollowOnScreen(
          jobNumber: jobNumber,
          customerName: customerName,
          workTypeLabel: workTypeLabel,
          onNoEnquiry: () => onPhaseChanged(PostSubmitPhase.jobClosed),
          onRaiseEstimate: onRaiseEstimate,
          onRaiseReactive: onRaiseReactive,
          onRaiseMultipleFixedPrice: onRaiseMultipleFixedPrice,
          onReferAndEarn: onReferAndEarn,
        ),
        PostSubmitPhase.jobClosed => JobClosedScreen(
          jobNumber: jobNumber,
          jobType: jobType,
          workTypeLabel: workTypeLabel,
          customerName: customerName,
          description: description,
          onVisitComplete:
              onVisitComplete ??
              () => onPhaseChanged(PostSubmitPhase.visitComplete),
        ),
        PostSubmitPhase.visitComplete => VisitCompleteScreen(
          jobNumber: jobNumber,
          onBackToHome: onBackToHome,
        ),
      },
    );
  }
}
