import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FP and PM beat trade words including leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'PM',
        trade: 'Plumbing',
        workType: '',
        description: 'Strip out - bathroom refurbishment',
      ),
      FormKind.bath,
    );
    expect(
      FormKindResolver.kindOf(
        jobType: 'Fixed Price',
        trade: 'Fixed Price',
        workType: '',
        description: '',
      ),
      FormKind.bath,
    );
  });

  test('leak job mentioning bathroom stays leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'REACTIVE',
        trade: 'Leak Detection',
        workType: '',
        description: 'suspected water leak in the bathroom',
      ),
      FormKind.leak,
    );
  });

  test('empty plumbing reactive defaults to leak', () {
    expect(
      FormKindResolver.kindOf(
        jobType: 'REACTIVE',
        trade: 'Plumbing',
        workType: '',
        description: '',
      ),
      FormKind.leak,
    );
  });
}
