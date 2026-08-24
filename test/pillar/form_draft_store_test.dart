import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('draft store round-trips answers and furthest step', () async {
    SharedPreferences.setMockInitialValues({});
    final store = FormDraftStore();
    await store.saveAnswers('job-a', {'Q1': 'Yes'});
    await store.saveFurthestStep('job-a', 2);
    expect(await store.loadAnswers('job-a'), {'Q1': 'Yes'});
    expect(await store.loadFurthestStep('job-a'), 2);
    await store.saveAnswers('job-b', {'Q1': 'No'});
    expect(await store.loadAnswers('job-a'), {'Q1': 'Yes'});
  });
}
