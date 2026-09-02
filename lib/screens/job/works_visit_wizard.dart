import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/job_photo_slot.dart';
import 'package:chumley_navigator/screens/job/visit_form_widgets.dart';
import 'package:chumley_navigator/screens/job/visit_wizard_scaffold.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorksVisitWizard extends StatefulWidget {
  const WorksVisitWizard({
    super.key,
    required this.job,
    this.initialStep = 0,
    this.onSubmitted,
  });

  final VisitJob job;
  final int initialStep;
  final VoidCallback? onSubmitted;

  static const titles = [
    'Risk assessment',
    'Before & after',
    'Parts used',
    'Job notes',
    'Review',
  ];

  static const subtitles = [
    'Confirm on-site risk assessment before works begin.',
    'Capture before and after photos for each line item.',
    'Record parts and materials used on site.',
    'Add job notes for the customer report.',
    'Review and submit the works visit report.',
  ];

  @override
  State<WorksVisitWizard> createState() => _WorksVisitWizardState();
}

class _WorksVisitWizardState extends State<WorksVisitWizard> {
  final _store = FormDraftStore();
  final _jobs = JobsRepository();
  late int _step;
  Map<String, dynamic> _answers = {};
  Map<String, String> _photos = {};
  List<Map<String, dynamic>> _lines = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, JobJourney.bath.form.length - 1);
    _hydrate();
  }

  Future<void> _hydrate() async {
    final draft = await _jobs.fetchFormDraft(
      saId: widget.job.saId,
      workTypeId: 'works',
    );
    if (draft != null) {
      _answers = Map<String, dynamic>.from(draft.answers);
      _photos = Map<String, String>.from(draft.photoSlots);
      if (draft.step > _step) {
        _step = draft.step.clamp(0, JobJourney.bath.form.length - 1);
      }
    } else {
      _answers = await _store.loadAnswers(widget.job.id);
      _photos = await _store.loadPhotos(widget.job.id);
    }
    _lines = await _loadLines();
    if (mounted) setState(() {});
    await _jobs.ensureOnSiteAtFormEntry(
      saId: widget.job.saId,
      formStepIndex: _step,
    );
    await _persist();
  }

  Future<List<Map<String, dynamic>>> _loadLines() async {
    if (!PillarClient.enableFirestoreWrites) {
      return _demoLines();
    }
    try {
      if (widget.job.fpSubmissionId != null &&
          widget.job.fpSubmissionId!.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection(PillarClient.colFpLineItems)
            .where('submission_id', isEqualTo: widget.job.fpSubmissionId)
            .get();
        return snap.docs.map((d) => d.data()).toList();
      }
      if (widget.job.pmProjectId != null && widget.job.pmProjectId!.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection(PillarClient.colPmTasks)
            .where('pm_project_id', isEqualTo: widget.job.pmProjectId)
            .get();
        return snap.docs.map((d) => d.data()).toList();
      }
    } catch (_) {}
    return _demoLines();
  }

  List<Map<String, dynamic>> _demoLines() {
    return [
      {
        'id': 'task_1',
        'title': 'Remove bath panel & isolate waste pipe',
        'trade': 'Plumbing',
      },
      {
        'id': 'task_2',
        'title': 'Fit replacement compression trap and waste run',
        'trade': 'Plumbing',
      },
      {
        'id': 'task_3',
        'title': 'Test flow & seal inspection hatch',
        'trade': 'Finishing',
      },
    ];
  }

  Future<void> _persist() async {
    await _jobs.saveFormDraft(
      saId: widget.job.saId,
      workTypeId: 'works',
      answers: _answers,
      photoSlots: _photos,
      step: _step,
    );
  }

  Future<void> _saveDraft() async {
    await _persist();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _next() async {
    if (_step < JobJourney.bath.form.length - 1) {
      setState(() => _step++);
      await _persist();
      return;
    }
    setState(() => _busy = true);
    try {
      await _jobs.submitForm(
        saId: widget.job.saId,
        workTypeId: 'works',
        reportType: 'pm_stage',
        reportSuffix: 'pm',
        answers: _answers,
        photoSlots: _photos,
        pmProjectId: widget.job.pmProjectId,
      );
      if (!mounted) return;
      widget.onSubmitted?.call();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _cancelOrBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step--);
    _persist();
  }

  void _goToStep(int targetStep) {
    if (targetStep < 0 ||
        targetStep >= JobJourney.bath.form.length ||
        targetStep == _step) {
      return;
    }
    setState(() => _step = targetStep);
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.job.kind == FormKind.bath);
    return VisitWizardScaffold(
      stepIndex: _step,
      stepCount: JobJourney.bath.form.length,
      title: WorksVisitWizard.titles[_step],
      subtitle: WorksVisitWizard.subtitles[_step],
      jobNumber: widget.job.jobNumber,
      isLast: _step == JobJourney.bath.form.length - 1,
      busy: _busy,
      onSaveDraft: _saveDraft,
      onNext: _next,
      onCancel: _cancelOrBack,
      onStepTapped: _goToStep,
      child: VisitFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(_error!, style: const TextStyle(color: NavigatorTokens.errorFg)),
              ),
            if (_step == 1) _beforeAfter() else _stepField(),
            if (_step == JobJourney.bath.form.length - 1)
              const VisitInfoBanner(
                text: 'Submit report writes COMPLETE and the works visit report.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepField() {
    return VisitTextField(
      label: WorksVisitWizard.titles[_step],
      value: (_answers['step_$_step'] ?? '').toString(),
      maxLines: _step == 3 ? 5 : 2,
      hint: 'Enter details for ${WorksVisitWizard.titles[_step].toLowerCase()}',
      onChanged: (v) {
        _answers['step_$_step'] = v;
        _persist();
      },
    );
  }

  Widget _beforeAfter() {
    if (_lines.isEmpty) {
      return const VisitFormCaption(text: 'No line items or tasks for this visit.');
    }
    return Column(
      children: [
        for (var i = 0; i < _lines.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: NavigatorTokens.surfaceSunken,
                borderRadius: NavigatorTokens.fieldRadius,
                border: Border.all(color: NavigatorTokens.borderHairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (_lines[i]['title'] ??
                            _lines[i]['description'] ??
                            _lines[i]['name'] ??
                            'Item ${i + 1}')
                        .toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: NavigatorTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  JobPhotoSlot(
                    label: 'BEFORE',
                    path: _photos['before_$i'],
                    onPicked: (p) {
                      setState(() => _photos['before_$i'] = p);
                      _persist();
                    },
                  ),
                  JobPhotoSlot(
                    label: 'AFTER',
                    path: _photos['after_$i'],
                    onPicked: (p) {
                      setState(() => _photos['after_$i'] = p);
                      _persist();
                    },
                  ),
                  VisitTextField(
                    label: 'Notes',
                    value: (_answers['line_notes_$i'] ?? '').toString(),
                    maxLines: 2,
                    onChanged: (v) {
                      _answers['line_notes_$i'] = v;
                      _persist();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
