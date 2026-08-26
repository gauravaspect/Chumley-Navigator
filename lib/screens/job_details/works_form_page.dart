import 'package:chumley_navigator/pillar/visit_controller.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bathroom / PM works form (BF 1–5). Answers stay local until sign-off.
class WorksFormPage extends StatefulWidget {
  const WorksFormPage({
    super.key,
    required this.controller,
  });

  final VisitController controller;

  @override
  State<WorksFormPage> createState() => _WorksFormPageState();
}

class _WorksFormPageState extends State<WorksFormPage> {
  int _step = 0;
  String? _risk;
  final _notes = TextEditingController();
  final _parts = TextEditingController();
  String? _beforePath;
  String? _afterPath;

  static const _titles = [
    'Risk assessment',
    'Before & after',
    'Parts used',
    'Job notes',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _notes.dispose();
    _parts.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final store = widget.controller.store;
    final jobId = widget.controller.jobId;
    final step = await store.loadStep(jobId);
    final answers = await store.loadAnswers(jobId);
    final photos = await store.loadPhotos(jobId);
    if (!mounted) return;
    setState(() {
      _step = step.clamp(0, 4);
      _risk = answers['risk'] as String?;
      _notes.text = (answers['notes'] as String?) ?? '';
      _parts.text = (answers['parts'] as String?) ?? '';
      _beforePath = photos['before'];
      _afterPath = photos['after'];
    });
  }

  Map<String, dynamic> _answers() => {
        'form': 'pm_stage',
        'risk': _risk,
        'notes': _notes.text,
        'parts': _parts.text,
      };

  Future<void> _persist() async {
    final store = widget.controller.store;
    final jobId = widget.controller.jobId;
    await store.saveStep(jobId, _step);
    await store.saveAnswers(jobId, _answers());
    await store.savePhotos(jobId, {
      if (_beforePath != null) 'before': _beforePath!,
      if (_afterPath != null) 'after': _afterPath!,
    });
  }

  Future<void> _submit() async {
    await _persist();
    await widget.controller.signOff(
      form: 'pm_stage',
      answers: _answers(),
      photoUrls: [
        if (_beforePath != null) _beforePath!,
        if (_afterPath != null) _afterPath!,
      ],
      photoSkips: const {},
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
                    'Works form · ${_titles[_step]}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  if (_step == 0)
                    DropdownButtonFormField<String>(
                      initialValue: _risk,
                      decoration: const InputDecoration(
                        labelText: 'Risk assessment',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Standard controls',
                          child: Text('Standard controls'),
                        ),
                        DropdownMenuItem(
                          value: 'Additional controls',
                          child: Text('Additional controls'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _risk = v),
                    ),
                  if (_step == 1) ...[
                    JobPhotoSlot(
                      label: 'Before *',
                      filePath: _beforePath,
                      onChanged: (p) => setState(() => _beforePath = p),
                    ),
                    SizedBox(height: 12.h),
                    JobPhotoSlot(
                      label: 'After *',
                      filePath: _afterPath,
                      onChanged: (p) => setState(() => _afterPath = p),
                    ),
                  ],
                  if (_step == 2)
                    TextField(
                      controller: _parts,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Parts used',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  if (_step == 3)
                    TextField(
                      controller: _notes,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Job notes',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  if (_step == 4)
                    Text(
                      'Submit writes COMPLETE, a pm_stage report, and recounts the project.',
                      style: TextStyle(fontSize: 14.sp, height: 1.4),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () async {
                        setState(() => _step--);
                        await _persist();
                      },
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (_step < 4) {
                        setState(() => _step++);
                        await _persist();
                      } else {
                        await _submit();
                      }
                    },
                    child: Text(_step < 4 ? 'Next' : 'Submit report'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
