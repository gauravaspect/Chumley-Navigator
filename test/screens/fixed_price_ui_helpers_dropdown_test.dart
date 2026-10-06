import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedPriceUiHelpers dropdown value safety', () {
    test('resolvedDropdownValue is null when value missing from items', () {
      expect(
        FixedPriceUiHelpers.resolvedDropdownValue('a1nWS000002BFskYAG', [
          'other',
        ]),
        isNull,
      );
    });

    test('resolvedDropdownValue is null when value appears more than once', () {
      expect(
        FixedPriceUiHelpers.resolvedDropdownValue('dup', ['dup', 'dup', 'x']),
        isNull,
      );
    });

    test('resolvedDropdownValue returns value when exactly one match', () {
      expect(
        FixedPriceUiHelpers.resolvedDropdownValue('a1nWS000002BFskYAG', [
          'a1nWS000002BFskYAG',
          'other',
        ]),
        'a1nWS000002BFskYAG',
      );
    });

    test('uniqueDropdownItems preserves first occurrence order', () {
      expect(
        FixedPriceUiHelpers.uniqueDropdownItems(['a', 'b', 'a', 'c', 'b']),
        ['a', 'b', 'c'],
      );
    });
  });
}
