import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/home_job_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 8, 24);

  test('hides COMPLETE from Home', () {
    expect(
      HomeJobFilter.showOnHome(
        status: 'COMPLETE',
        scheduledStart: today,
        selectedDay: today,
        today: today,
      ),
      isFalse,
    );
  });

  test('pulls IN_TRANSIT onto today even if scheduled another day', () {
    expect(
      HomeJobFilter.showOnHome(
        status: 'IN_TRANSIT',
        scheduledStart: DateTime(2026, 8, 20),
        selectedDay: today,
        today: today,
      ),
      isTrue,
    );
  });

  test('shows dispatched job on its scheduled day', () {
    expect(
      HomeJobFilter.showOnHome(
        status: 'DISPATCHED',
        scheduledStart: today,
        selectedDay: today,
        today: today,
      ),
      isTrue,
    );
  });

  test('FormKind.bath jobs never classify as leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'FP',
        trade: 'Leak Detection',
        workType: '',
        description: '',
      ),
      FormKind.bath,
    );
  });
}
