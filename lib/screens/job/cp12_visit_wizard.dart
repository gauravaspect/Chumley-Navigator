import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/job_photo_slot.dart';
import 'package:chumley_navigator/screens/job/visit_form_widgets.dart';
import 'package:chumley_navigator/screens/job/visit_wizard_scaffold.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cp12VisitWizard extends StatefulWidget {
  const Cp12VisitWizard({
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
    'Gas Safe',
    'Tightness test',
    'IV calculator',
    'Installation pipework',
    'Appliance inspection',
    'Combustion analysis',
    'Findings',
    'Parts used',
    'Photos',
    'Notes',
    'Sign off',
  ];

  static const subtitles = [
    'Confirm on-site risk assessment before gas work.',
    'Record Gas Safe registration and competence checks.',
    'Document tightness test results.',
    'Calculate ventilation and IV requirements.',
    'Inspect installation pipework condition.',
    'Inspect each appliance on site.',
    'Record combustion analysis readings.',
    'Capture findings and remedial actions.',
    'List any parts used during the visit.',
    'Capture warning notice and appliance photos.',
    'Add engineer notes for the report.',
    'Customer sign-off and CP12 submission.',
  ];

  @override
  State<Cp12VisitWizard> createState() => _Cp12VisitWizardState();
}

class _Cp12VisitWizardState extends State<Cp12VisitWizard> {
  final _store = FormDraftStore();
  final _jobs = JobsRepository();
  late int _step;
  Map<String, dynamic> _answers = {};
  Map<String, String> _photos = {};
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, JobJourney.gas.form.length - 1);
    _hydrate();
  }

  Future<void> _hydrate() async {
    final draft = await _jobs.fetchFormDraft(
      saId: widget.job.saId,
      workTypeId: 'CP12',
    );
    if (draft != null) {
      _answers = Map<String, dynamic>.from(draft.answers);
      _photos = Map<String, String>.from(draft.photoSlots);
      if (draft.step > _step) {
        _step = draft.step.clamp(0, JobJourney.gas.form.length - 1);
      }
    } else {
      _answers = await _store.loadAnswers(widget.job.id);
      _photos = await _store.loadPhotos(widget.job.id);
    }
    if (mounted) setState(() {});
    await _jobs.ensureOnSiteAtFormEntry(
      saId: widget.job.saId,
      formStepIndex: _step,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _jobs.saveFormDraft(
      saId: widget.job.saId,
      workTypeId: 'CP12',
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
    if (_step < JobJourney.gas.form.length - 1) {
      setState(() => _step++);
      await _persist();
      return;
    }
    setState(() => _busy = true);
    try {
      await _jobs.submitForm(
        saId: widget.job.saId,
        workTypeId: 'CP12',
        reportType: 'CP12',
        reportSuffix: 'gas_safety_record',
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
        targetStep >= JobJourney.gas.form.length ||
        targetStep == _step) {
      return;
    }
    setState(() => _step = targetStep);
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    return VisitWizardScaffold(
      stepIndex: _step,
      stepCount: JobJourney.gas.form.length,
      title: Cp12VisitWizard.titles[_step],
      subtitle: Cp12VisitWizard.subtitles[_step],
      jobNumber: widget.job.jobNumber,
      isLast: _step == JobJourney.gas.form.length - 1,
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
            VisitTextField(
              label: Cp12VisitWizard.titles[_step],
              value: (_answers['step_$_step'] ?? '').toString(),
              maxLines: _step == 10 ? 5 : 2,
              hint: 'Enter details for ${Cp12VisitWizard.titles[_step].toLowerCase()}',
              onChanged: (v) {
                _answers['step_$_step'] = v;
                _persist();
              },
            ),
            if (_step == 9) ...[
              JobPhotoSlot(
                label: 'Warning notice / appliance',
                path: _photos['cp12 photo'],
                onPicked: (p) {
                  setState(() => _photos['cp12 photo'] = p);
                  _persist();
                },
              ),
            ],
            if (_step == JobJourney.gas.form.length - 1)
              const VisitInfoBanner(
                text: 'Submit report writes COMPLETE and the CP12 report to the spine.',
              ),
          ],
        ),
      ),
    );
  }
}
