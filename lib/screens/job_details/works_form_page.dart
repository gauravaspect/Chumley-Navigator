import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bathroom / PM works form (BF 1–5). Answers stay local until sign-off.
class WorksFormPage extends StatefulWidget {
  const WorksFormPage({
    super.key,
    required this.jobId,
    this.jobNumber = '',
    this.onSubmitted,
    this.onCancelToInTransit,
  });

  final String jobId;
  final String jobNumber;
  final VoidCallback? onSubmitted;
  final VoidCallback? onCancelToInTransit;

  static Future<bool?> open(
    BuildContext context, {
    required String jobId,
    String jobNumber = '',
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorksFormPage(jobId: jobId, jobNumber: jobNumber),
      ),
    );
  }

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
  final _store = FormDraftStore();
  final _jobs = JobsRepository();

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
    final step = await _store.loadFurthestStep(widget.jobId);
    final answers = await _store.loadAnswers(widget.jobId);
    final photos = await _store.loadPhotos(widget.jobId);
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
    await _store.saveDraft(
      jobId: widget.jobId,
      step: _step,
      answers: _answers(),
      photos: {'before': ?_beforePath, 'after': ?_afterPath},
    );
  }

  Future<void> _submit() async {
    await _persist();
    await _jobs.signOff(
      jobId: widget.jobId,
      reportType: 'WORKS',
      reportSuffix: 'bathroom_pm_stage',
      answers: _answers(),
      photoSlots: {'before': ?_beforePath, 'after': ?_afterPath},
    );
    if (!mounted) return;
    if (widget.onSubmitted != null) {
      widget.onSubmitted!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Scaffold(
      backgroundColor: theme.base,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  CommandCentreBackButton(
                    onTap: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else if (widget.onCancelToInTransit != null) {
                        widget.onCancelToInTransit!();
                      } else {
                        Navigator.of(context).maybePop(false);
                      }
                    },
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Works form · ${_titles[_step]}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
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
                      dropdownColor: theme.surface,
                      style: TextStyle(fontSize: 14.sp, color: theme.text),
                      decoration: InputDecoration(
                        labelText: 'Risk assessment',
                        labelStyle: TextStyle(color: theme.textMuted),
                        filled: true,
                        fillColor: theme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Standard controls',
                          child: Text(
                            'Standard controls',
                            style: TextStyle(color: theme.text),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Enhanced controls',
                          child: Text(
                            'Enhanced controls',
                            style: TextStyle(color: theme.text),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _risk = v),
                    ),
                  if (_step == 1) ...[
                    JobPhotoSlot(
                      label: 'Before photo',
                      path: _beforePath,
                      onPicked: (p) => setState(() => _beforePath = p),
                    ),
                    SizedBox(height: 12.h),
                    JobPhotoSlot(
                      label: 'After photo',
                      path: _afterPath,
                      onPicked: (p) => setState(() => _afterPath = p),
                    ),
                  ],
                  if (_step == 2)
                    TextField(
                      controller: _parts,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14.sp, color: theme.text),
                      decoration: InputDecoration(
                        labelText: 'Parts consumed',
                        labelStyle: TextStyle(color: theme.textMuted),
                        filled: true,
                        fillColor: theme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),
                    ),
                  if (_step == 3)
                    TextField(
                      controller: _notes,
                      maxLines: 6,
                      style: TextStyle(fontSize: 14.sp, color: theme.text),
                      decoration: InputDecoration(
                        labelText: 'Job notes',
                        labelStyle: TextStyle(color: theme.textMuted),
                        filled: true,
                        fillColor: theme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),
                    ),
                  if (_step == 4) ...[
                    Text(
                      'Ready to submit works sign-off for ${widget.jobNumber.isNotEmpty ? widget.jobNumber : widget.jobId}.',
                      style: TextStyle(fontSize: 14.sp, color: theme.text),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Risk: ${_risk ?? 'Not recorded'}',
                      style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                    ),
                    Text(
                      'Parts: ${_parts.text.isEmpty ? 'None' : _parts.text}',
                      style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                    ),
                    Text(
                      'Notes: ${_notes.text.isEmpty ? 'None' : _notes.text}',
                      style: TextStyle(fontSize: 13.sp, color: theme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_step > 0) {
                          setState(() => _step--);
                        } else {
                          Navigator.of(context).maybePop(false);
                        }
                      },
                      child: Text(_step == 0 ? 'Cancel' : 'Back'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_step < 4) {
                          await _persist();
                          setState(() => _step++);
                        } else {
                          await _submit();
                        }
                      },
                      child: Text(_step < 4 ? 'Next' : 'Submit report'),
                    ),
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
