import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/models/ppm_jobs_models.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart' as journey;
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/cp12_visit_wizard.dart';
import 'package:chumley_navigator/screens/job/follow_on_page.dart';
import 'package:chumley_navigator/screens/job/ld_visit_wizard.dart';
import 'package:chumley_navigator/screens/job/work_order_page.dart';
import 'package:chumley_navigator/screens/job/works_visit_wizard.dart';
import 'package:flutter/material.dart';

class JobVisitRouter {
  static Future<void> openAppointment(
    BuildContext context,
    Appointment appointment,
  ) {
    return openJob(context, VisitJob.fromAppointment(appointment));
  }

  static Future<void> openPpmTask(BuildContext context, PpmJobTask task) {
    return openJob(context, VisitJob.fromPpmTask(task));
  }

  /// Push the kind-specific on-site visit wizard (5 / 12 / 5 steps).
  /// Returns when the wizard route is popped.
  static Future<void> pushVisitWizard(
    BuildContext context,
    VisitJob job, {
    int initialStep = 0,
    VoidCallback? onSubmitted,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (wizardContext) => _wizardPage(
          job,
          initialStep,
          () {
            onSubmitted?.call();
            if (wizardContext.mounted) {
              Navigator.of(wizardContext).pop();
            }
          },
        ),
      ),
    );
  }

  static Widget _wizardPage(
    VisitJob job,
    int step,
    VoidCallback onSubmitted,
  ) {
    return switch (job.kind) {
      FormKind.bath => WorksVisitWizard(
          job: job,
          initialStep: step,
          onSubmitted: onSubmitted,
        ),
      FormKind.gas => Cp12VisitWizard(
          job: job,
          initialStep: step,
          onSubmitted: onSubmitted,
        ),
      FormKind.leak => LdVisitWizard(
          job: job,
          initialStep: step,
          onSubmitted: onSubmitted,
        ),
    };
  }

  static Future<void> openJob(BuildContext context, VisitJob job) async {
    final drafts = FormDraftStore();
    final status = await drafts.loadStatus(job.id) ?? job.status;
    final furthest = await drafts.loadFurthestStep(job.id);
    final resolved = job.copyWith(status: status);
    final target = journey.openJob(
      status: status,
      kind: resolved.kind,
      furthestStep: furthest,
    );
    if (!context.mounted) return;
    if (target.phase == journey.ResumePhase.form) {
      await _pushWizard(
        context,
        resolved,
        target.formStep,
        onSubmitted: () => _afterSignOff(context, resolved),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _WorkOrderHost(job: resolved, phase: target.phase),
      ),
    );
  }

  static Future<void> _pushWizard(
    BuildContext context,
    VisitJob job,
    int step, {
    VoidCallback? onSubmitted,
  }) {
    return pushVisitWizard(
      context,
      job,
      initialStep: step,
      onSubmitted: onSubmitted,
    );
  }

  static Future<void> _afterSignOff(BuildContext context, VisitJob job) async {
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _WorkOrderHost(
          job: job.copyWith(status: 'COMPLETE'),
          phase: journey.ResumePhase.complete,
        ),
      ),
    );
  }
}

class _WorkOrderHost extends StatefulWidget {
  const _WorkOrderHost({required this.job, required this.phase});

  final VisitJob job;
  final journey.ResumePhase phase;

  @override
  State<_WorkOrderHost> createState() => _WorkOrderHostState();
}

class _WorkOrderHostState extends State<_WorkOrderHost> {
  late journey.ResumePhase _phase;
  late VisitJob _job;
  String? _error;
  final _jobs = JobsRepository();

  @override
  void initState() {
    super.initState();
    _phase = widget.phase;
    _job = widget.job;
  }

  Future<void> _startJourney() async {
    try {
      final detail = await _jobs.fetchAppointment(_job.saId);
      String? next = SaStatus.pickAllowed(
        detail.allowedNextStatuses,
        SaStatus.inTransit,
      );
      next ??=
          detail.allowedNextStatuses.isNotEmpty
              ? detail.allowedNextStatuses.first
              : null;
      if (next == null) {
        setState(() => _error = 'No status transition available.');
        return;
      }
      final result = await _jobs.setStatus(saId: _job.saId, status: next);
      if (!mounted) return;
      setState(() {
        _phase = journey.resumePhase(result.status);
        _job = _job.copyWith(status: result.status);
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _arriveOnSite() async {
    if (!mounted) return;
    await JobVisitRouter.pushVisitWizard(context, _job, initialStep: 0);
    if (!mounted) return;
    final status = await FormDraftStore().loadStatus(_job.id) ?? _job.status;
    setState(() {
      _job = _job.copyWith(status: status);
      _phase = journey.resumePhase(status);
    });
  }

  Future<void> _continueForm() async {
    final step = await FormDraftStore().loadFurthestStep(_job.id);
    if (!mounted) return;
    await JobVisitRouter.pushVisitWizard(context, _job, initialStep: step);
  }

  void _followOn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowOnPage(job: _job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WorkOrderPage(
      job: _job,
      kind: _job.kind,
      phase: _phase,
      statusWriteError: _error,
      onStartJourney: _startJourney,
      onArriveOnSite: _arriveOnSite,
      onContinueForm: _continueForm,
      onOpenFollowOn: _followOn,
    );
  }
}
