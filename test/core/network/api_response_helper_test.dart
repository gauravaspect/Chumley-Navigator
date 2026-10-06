import 'package:chumley_navigator/core/network/api_response_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponseHelper.extractMessage', () {
    test('extracts message from nested detail map', () {
      final message = ApiResponseHelper.extractMessage({
        'detail': {
          'message':
              'A Fixed-Price agreement already exists for this source work order.',
          'existing_work_order_id': '0WOTl000009tfGfOAI',
          'hint': 'pass force=true to create another anyway.',
        },
      });

      expect(
        message,
        'A Fixed-Price agreement already exists for this source work order.',
      );
    });

    test('extracts top-level message when present', () {
      expect(
        ApiResponseHelper.extractMessage({'message': 'Simple failure'}),
        'Simple failure',
      );
    });

    test('prefers nested validation.errors over generic detail.message', () {
      final message = ApiResponseHelper.extractMessage({
        'detail': {
          'message': 'validation failed — not written',
          'validation': {
            'valid': false,
            'errors': [
              "'user_id' = 'navigatorengineer_aspect_co_uk' is not a valid 15/18-char Salesforce Id",
            ],
            'warnings': [],
          },
        },
      });

      expect(
        message,
        "'user_id' = 'navigatorengineer_aspect_co_uk' is not a valid 15/18-char Salesforce Id",
      );
    });
  });
}
