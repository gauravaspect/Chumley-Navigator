import 'package:chumley_navigator/models/reactive_work_order_submit_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactiveWorkOrderSubmitPayload', () {
    test('toSubmitJson matches dry-run contract', () {
      const payload = ReactiveWorkOrderSubmitPayload(
        sourceWorkOrderId: '0WOTl000009kpf3OAA',
        userId: '0054G00000BaJZHQA3',
        workTypeId: '08q4G0000004CQ9QAM',
        jobTitle: 'Test job title',
        description: 'Test - dry run only.',
        accessNotes: 'Ring the bell.',
        customerDecision: 'accept',
      );

      expect(payload.toSubmitJson(), {
        'source_work_order_id': '0WOTl000009kpf3OAA',
        'user_id': '0054G00000BaJZHQA3',
        'work_type_id': '08q4G0000004CQ9QAM',
        'job_title': 'Test job title',
        'description': 'Test - dry run only.',
        'access_notes': 'Ring the bell.',
        'customer_decision': 'accept',
        'work_commencing_choice': 'now',
      });
    });

    test(
      'validate requires source, user, work type, title, description, decision',
      () {
        const payload = ReactiveWorkOrderSubmitPayload(
          sourceWorkOrderId: '',
          userId: '',
          workTypeId: '',
          jobTitle: '',
          description: '',
          accessNotes: '',
          customerDecision: '',
        );
        final errors = payload.validate();
        expect(errors, contains('Source work order is required.'));
        expect(
          errors,
          contains('User id is required to raise this work order.'),
        );
        expect(errors, contains('Work type is required.'));
        expect(errors, contains('Job title is required.'));
        expect(errors, contains('Description is required.'));
        expect(errors, contains('Customer decision is required.'));
      },
    );
  });
}
