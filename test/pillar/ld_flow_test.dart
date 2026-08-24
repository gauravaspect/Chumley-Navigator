import 'package:chumley_navigator/pillar/ld_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LdFlow.hosts.length == 5 and photo host map keys match PHOTO_HOST', () {
    expect(LdFlow.hosts.length, 5);
    expect(LdFlow.hosts.map((h) => h.sid).toList(), [
      '2013-3427',
      '2013-3546',
      '2013-3795',
      '2057-3792',
      '2070-3895',
    ]);
    expect(LdFlow.photoHost.keys.toSet(), {
      'front of property',
      'water meter reading',
      'affected area overview',
      'affected area close up',
      'proposed access route',
    });
    expect(LdFlow.photoHost['front of property'], '2013-3546');
    expect(LdFlow.photoHost['water meter reading'], '2013-3670');
    expect(LdFlow.photoHost['proposed access route'], '2057-3792');
  });
}
