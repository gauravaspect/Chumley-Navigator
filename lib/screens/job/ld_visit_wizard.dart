import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/pillar/ld_flow.dart';
import 'package:chumley_navigator/pillar/visit_job.dart';
import 'package:chumley_navigator/screens/job/job_photo_slot.dart';
import 'package:chumley_navigator/screens/job/visit_form_widgets.dart';
import 'package:chumley_navigator/screens/job/visit_wizard_scaffold.dart';
import 'package:chumley_navigator/theme/navigator_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LdVisitWizard extends StatefulWidget {
  const LdVisitWizard({
    super.key,
    required this.job,
    this.initialStep = 0,
    this.onSubmitted,
  });

  final VisitJob job;
  final int initialStep;
  final VoidCallback? onSubmitted;

  @override
  State<LdVisitWizard> createState() => _LdVisitWizardState();
}

class _LdVisitWizardState extends State<LdVisitWizard> {
  final _store = FormDraftStore();
  final _jobs = JobsRepository();
  late int _step;
  Map<String, dynamic> _answers = {};
  Map<String, String> _photos = {};
  bool _busy = false;
  String? _error;

  static const _testMethodKey = 'Test Method';
  static const _equipmentKey = 'Equipment';

  static const _subtitles = [
    'Confirm the on-site risk assessment before starting work.',
    'Record property context, meter reading and arrival photos.',
    'Complete visual inspection and choose your test method.',
    'Document findings, parts used and access route.',
    'Customer sign-off and engineer declaration.',
  ];

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, LdFlow.hosts.length - 1);
    _hydrate();
  }

  Future<void> _hydrate() async {
    final draft = await _jobs.fetchFormDraft(
      saId: widget.job.saId,
      workTypeId: 'leak_detection',
    );
    if (draft != null) {
      _answers = Map<String, dynamic>.from(draft.answers);
      _photos = Map<String, String>.from(draft.photoSlots);
      if (draft.step > _step) {
        _step = draft.step.clamp(0, LdFlow.hosts.length - 1);
      }
    } else {
      _answers = await _store.loadAnswers(widget.job.id);
      _photos = await _store.loadPhotos(widget.job.id);
    }
    if (!mounted) return;
    setState(() {});
    await _jobs.ensureOnSiteAtFormEntry(
      saId: widget.job.saId,
      formStepIndex: _step,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _jobs.saveFormDraft(
      saId: widget.job.saId,
      workTypeId: 'leak_detection',
      answers: _answers,
      photoSlots: _photos,
      step: _step,
    );
  }

  void _setAnswer(String key, String value) {
    setState(() => _answers[key] = value);
    _persist();
  }

  Future<void> _saveDraft() async {
    await _persist();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _next() async {
    if (_step < LdFlow.hosts.length - 1) {
      setState(() => _step++);
      await _persist();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _jobs.submitForm(
        saId: widget.job.saId,
        workTypeId: 'leak_detection',
        reportType: 'leak_detection',
        reportSuffix: 'ld',
        answers: _answers,
        photoSlots: _photos,
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
        targetStep >= LdFlow.hosts.length ||
        targetStep == _step) {
      return;
    }
    setState(() => _step = targetStep);
    _persist();
  }

  void _onEquipmentTap() {
    if ((_answers[_testMethodKey] ?? '').toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Answer 'Test Method' first — it decides what can be offered here.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final host = LdFlow.hosts[_step];
    return VisitWizardScaffold(
      stepIndex: _step,
      stepCount: LdFlow.hosts.length,
      title: host.name,
      subtitle: _subtitles[_step],
      jobNumber: widget.job.jobNumber,
      isLast: _step == LdFlow.hosts.length - 1,
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
                child: Text(
                  _error!,
                  style: const TextStyle(color: NavigatorTokens.errorFg),
                ),
              ),
            ..._fieldsFor(_step),
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsFor(int step) {
    switch (step) {
      case 0:
        return [
          const VisitFormCaption(
            text:
                'Complete HSE gatekeeper checks before any leak detection work.',
          ),
          VisitChoiceChips(
            label: 'Risk assessment completed?',
            options: const ['Yes', 'No — stop work'],
            value: (_answers['Risk assessment completed?'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Risk assessment completed?', v),
          ),
          VisitChoiceChips(
            label: 'Work at height required?',
            options: const ['No', 'Yes — controls in place'],
            value: (_answers['Work at height required?'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Work at height required?', v),
          ),
          VisitChoiceChips(
            label: 'Method statement on site?',
            options: const ['Yes', 'No'],
            value: (_answers['Method statement on site?'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Method statement on site?', v),
          ),
        ];
      case 1:
        return [
          VisitChoiceChips(
            label: 'Property type',
            options: const ['Domestic', 'Commercial', 'Other'],
            value: (_answers['Property type'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Property type', v),
          ),
          VisitTextField(
            label: 'Water meter reading',
            value: (_answers['Water meter reading'] ?? '').toString(),
            onChanged: (v) => _setAnswer('Water meter reading', v),
          ),
          JobPhotoSlot(
            label: 'Front of property',
            path: _photos['front of property'],
            onPicked: (p) {
              setState(() => _photos['front of property'] = p);
              _persist();
            },
          ),
          JobPhotoSlot(
            label: 'Water meter reading',
            path: _photos['water meter reading'],
            onPicked: (p) {
              setState(() => _photos['water meter reading'] = p);
              _persist();
            },
          ),
        ];
      case 2:
        return [
          VisitChoiceChips(
            label: 'Visual inspection complete?',
            options: const ['Yes', 'Partial', 'No access'],
            value: (_answers['Visual inspection complete?'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Visual inspection complete?', v),
          ),
          VisitChoiceChips(
            label: _testMethodKey,
            options: const ['Acoustic', 'Thermal', 'Tracer gas', 'Moisture'],
            value: (_answers[_testMethodKey] ?? '').toString(),
            onSelected: (v) => _setAnswer(_testMethodKey, v),
          ),
          GestureDetector(
            onTap: _onEquipmentTap,
            child: AbsorbPointer(
              absorbing: (_answers[_testMethodKey] ?? '').toString().isEmpty,
              child: VisitChoiceChips(
                label: _equipmentKey,
                options: const ['Kit A', 'Kit B', 'Kit C'],
                value: (_answers[_equipmentKey] ?? '').toString(),
                onSelected: (v) => _setAnswer(_equipmentKey, v),
                enabled: (_answers[_testMethodKey] ?? '').toString().isNotEmpty,
              ),
            ),
          ),
          JobPhotoSlot(
            label: 'Affected area overview',
            path: _photos['affected area overview'],
            onPicked: (p) {
              setState(() => _photos['affected area overview'] = p);
              _persist();
            },
          ),
          JobPhotoSlot(
            label: 'Affected area close up',
            path: _photos['affected area close up'],
            onPicked: (p) {
              setState(() => _photos['affected area close up'] = p);
              _persist();
            },
          ),
        ];
      case 3:
        return [
          VisitChoiceChips(
            label: 'Did this test help find the source of the leak?',
            options: const ['Yes', 'No', 'Inconclusive'],
            value:
                (_answers['Did this test help find the source of the leak?'] ??
                        '')
                    .toString(),
            onSelected: (v) => _setAnswer(
              'Did this test help find the source of the leak?',
              v,
            ),
          ),
          VisitChoiceChips(
            label: 'Parts used?',
            options: const ['No', 'Yes'],
            value: (_answers['Parts used?'] ?? '').toString(),
            onSelected: (v) => _setAnswer('Parts used?', v),
          ),
          VisitTextField(
            label: "Scope notes - customer's reported symptom + history",
            value:
                (_answers["Scope notes - customer's reported symptom + history"] ??
                        '')
                    .toString(),
            maxLines: 4,
            onChanged: (v) => _setAnswer(
              "Scope notes - customer's reported symptom + history",
              v,
            ),
          ),
          JobPhotoSlot(
            label: 'Proposed access route',
            path: _photos['proposed access route'],
            onPicked: (p) {
              setState(() => _photos['proposed access route'] = p);
              _persist();
            },
          ),
        ];
      default:
        return [
          VisitChoiceChips(
            label: 'Customer present for sign-off?',
            options: const ['Yes', 'No'],
            value: (_answers['Customer present for sign-off?'] ?? '')
                .toString(),
            onSelected: (v) => _setAnswer('Customer present for sign-off?', v),
          ),
          VisitTextField(
            label: 'Engineer declaration',
            value: (_answers['Engineer declaration'] ?? '').toString(),
            maxLines: 3,
            onChanged: (v) => _setAnswer('Engineer declaration', v),
          ),
          const VisitInfoBanner(
            text:
                'Submit report writes COMPLETE, the leak report, timeline, and photos.',
          ),
        ];
    }
  }
}
