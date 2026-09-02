import 'package:chumley_navigator/models/engineer_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EngineerFormSummary', () {
    test('fromJson parses summary object correctly', () {
      final json = {
        'id': 'form_123',
        'work_type_id': 'CP12',
        'title': 'Gas Safety Record CP12',
        'status': 'draft',
        'is_draft': true,
        'step': 2,
        'updated_at': '2026-08-30T11:15:49.000Z',
      };

      final summary = EngineerFormSummary.fromJson(json);
      expect(summary.id, 'form_123');
      expect(summary.workTypeId, 'CP12');
      expect(summary.title, 'Gas Safety Record CP12');
      expect(summary.isDraft, true);
      expect(summary.isSubmitted, false);
      expect(summary.step, 2);
      expect(summary.updatedAt, isNotNull);
    });

    test('fromJson handles minimal fields', () {
      final json = {
        'work_type_id': 'PM_WORKS',
        'status': 'submitted',
      };

      final summary = EngineerFormSummary.fromJson(json);
      expect(summary.workTypeId, 'PM_WORKS');
      expect(summary.isSubmitted, true);
      expect(summary.isDraft, false);
    });
  });

  group('EngineerFormDetail', () {
    test('fromJson parses full draft and schema correctly', () {
      final json = {
        'success': true,
        'form': {
          'id': 'form_cp12',
          'work_type_id': 'CP12',
          'title': 'Gas Safety Certificate',
          'status': 'draft',
          'step': 3,
          'schema': {
            'fields': [
              {'name': 'water_isolated', 'type': 'boolean'},
            ]
          },
          'answers': {
            'water_isolated': true,
            'meter_type': 'G4',
          },
          'photo_slots': {
            'before_photo': 'https://example.com/before.jpg',
          },
          'updated_at': '2026-08-30T12:00:00.000Z',
        }
      };

      final detail = EngineerFormDetail.fromJson(json);
      expect(detail.id, 'form_cp12');
      expect(detail.workTypeId, 'CP12');
      expect(detail.title, 'Gas Safety Certificate');
      expect(detail.step, 3);
      expect(detail.answers['water_isolated'], true);
      expect(detail.answers['meter_type'], 'G4');
      expect(detail.photoSlots['before_photo'], 'https://example.com/before.jpg');
      expect(detail.schema['fields'], isNotEmpty);

      final draftPayload = detail.toDraftPayload();
      expect(draftPayload['work_type_id'], 'CP12');
      expect(draftPayload['answers'], detail.answers);
      expect(draftPayload['step'], 3);

      final submitPayload = detail.toSubmitPayload();
      expect(submitPayload['work_type_id'], 'CP12');
      expect(submitPayload['answers'], detail.answers);
      expect(submitPayload['submitted_at'], isNotNull);
    });
  });
}
