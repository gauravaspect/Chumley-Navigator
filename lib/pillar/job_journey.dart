import 'package:chumley_navigator/pillar/form_kind.dart';

/// Port of `app/state_runtime.js` `JOURNEY` + `resumeScreen`.
class JobJourney {
  final String dispatched;
  final String transit;
  final List<String> form;
  final String complete;

  const JobJourney({
    required this.dispatched,
    required this.transit,
    required this.form,
    required this.complete,
  });

  static const leak = JobJourney(
    dispatched: '1991-3106',
    transit: '1991-3224',
    form: ['2013-3427', '2013-3546', '2013-3795', '2057-3792', '2070-3895'],
    complete: '2072-62797',
  );

  static const gas = JobJourney(
    dispatched: '2205-3809',
    transit: '2205-3953',
    form: [
      '2196-3397',
      '2196-3574',
      '2196-3704',
      '2196-3876',
      '2196-4001',
      '2196-4116',
      '2196-4332',
      '2196-4523',
      '2196-4636',
      '2196-4854',
      '2196-5003',
      '2196-5152',
    ],
    complete: '2205-4099',
  );

  static const bath = JobJourney(
    dispatched: '2317-3931',
    transit: '2317-4075',
    form: ['2317-4332', '2317-4509', '2317-4779', '2317-4914', '2317-5049'],
    complete: '2317-4221',
  );

  static JobJourney forKind(FormKind k) {
    switch (k) {
      case FormKind.gas:
        return gas;
      case FormKind.bath:
        return bath;
      case FormKind.leak:
        return leak;
    }
  }
}

enum ResumePhase { dispatched, transit, form, complete }

ResumePhase resumePhase(String status) {
  final st = status.toUpperCase();
  if (st == 'COMPLETE' || st == 'AWAITING_APPROVAL' || st == 'APPROVED') {
    return ResumePhase.complete;
  }
  if (st == 'ON_SITE') return ResumePhase.form;
  if (st == 'IN_TRANSIT') return ResumePhase.transit;
  return ResumePhase.dispatched;
}

int clampFormStep(int furthest, int formLength) {
  if (formLength <= 0) return 0;
  if (furthest < 0) return 0;
  if (furthest > formLength - 1) return formLength - 1;
  return furthest;
}

class ResumeTarget {
  const ResumeTarget({
    required this.phase,
    required this.formStep,
    required this.screenId,
  });

  final ResumePhase phase;
  final int formStep;
  final String screenId;
}

ResumeTarget openJob({
  required String status,
  required FormKind kind,
  int furthestStep = 0,
}) {
  final journey = JobJourney.forKind(kind);
  final phase = resumePhase(status);
  switch (phase) {
    case ResumePhase.complete:
      return ResumeTarget(
        phase: phase,
        formStep: 0,
        screenId: journey.complete,
      );
    case ResumePhase.transit:
      return ResumeTarget(
        phase: phase,
        formStep: 0,
        screenId: journey.transit,
      );
    case ResumePhase.form:
      final step = clampFormStep(furthestStep, journey.form.length);
      return ResumeTarget(
        phase: phase,
        formStep: step,
        screenId: journey.form[step],
      );
    case ResumePhase.dispatched:
      return ResumeTarget(
        phase: phase,
        formStep: 0,
        screenId: journey.dispatched,
      );
  }
}
