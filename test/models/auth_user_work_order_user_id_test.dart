import 'package:chumley_navigator/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser.workOrderUserId', () {
    test('uses engineerId (ServiceResource), not email-slug id', () {
      const user = AuthUser(
        id: 'navigatorengineer_aspect_co_uk',
        engineerId: '0HnWS000000APMv0AO',
      );

      expect(user.workOrderUserId, '0HnWS000000APMv0AO');
      expect(AuthUser.isSalesforceId(user.workOrderUserId), isTrue);
      expect(AuthUser.isSalesforceId(user.id), isFalse);
    });
  });
}
