import 'package:chumley_navigator/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserModel serializes backend auth payload fields', () {
    final user = UserModel.fromJson(const {
      'id': 'user_id',
      'email': 'user@example.com',
      'name': 'John Doe',
      'role': 'engineer',
      'azureOid': 'azure_oid',
      'engineerId': 'engineer_id',
      'tradeGroups': ['Plumbing'],
    });

    expect(user.id, 'user_id');
    expect(user.email, 'user@example.com');
    expect(user.displayName, 'John Doe');
    expect(user.role, 'engineer');
    expect(user.azureOid, 'azure_oid');
    expect(user.engineerId, 'engineer_id');
    expect(user.tradeGroups, ['Plumbing']);
    expect(UserModel.fromJson(user.toJson()), user);
  });
}
