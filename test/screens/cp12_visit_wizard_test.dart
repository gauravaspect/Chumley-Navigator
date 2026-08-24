import 'package:chumley_navigator/screens/job/cp12_visit_wizard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cp12VisitWizard exposes 12 step titles ending with Sign off', () {
    expect(Cp12VisitWizard.titles.length, 12);
    expect(Cp12VisitWizard.titles.first, 'Risk assessment');
    expect(Cp12VisitWizard.titles.last, 'Sign off');
  });
}
