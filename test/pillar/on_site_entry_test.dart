import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given ON_SITE and furthestStep 2, openJob returns form phase and step 2',
    () {
      final target = openJob(
        status: 'ON_SITE',
        kind: FormKind.leak,
        furthestStep: 2,
      );
      expect(target.phase, ResumePhase.form);
      expect(target.formStep, 2);
      expect(target.screenId, JobJourney.leak.form[2]);
    },
  );
}
