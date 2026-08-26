import 'package:chumley_navigator/pillar/job_journey.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ON_SITE resumes at furthest form step not step 0', () {
    expect(resumePhase('ON_SITE'), ResumePhase.form);
    expect(clampFormStep(3, JobJourney.leak.form.length), 3);
    expect(JobJourney.leak.form.length, 5);
    expect(JobJourney.gas.form.length, 12);
    expect(JobJourney.bath.form.length, 5);
  });

  test('COMPLETE does not resume at dispatched', () {
    expect(resumePhase('COMPLETE'), ResumePhase.complete);
  });
}
