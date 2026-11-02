import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/auth/data/models/account_profile_model.dart';
import 'package:sky_plan/features/auth/data/models/auth_user_model.dart';

const _base = {
  'id': 1,
  'email': 'user@example.com',
  'username': 'user123',
  'emailConfirmed': true,
  'createdAt': '2026-09-18T02:00:00.000Z',
};

void main() {
  test('parses first and last name when present', () {
    final user = AuthUserModel.fromJson({
      ..._base,
      'firstName': 'Ana',
      'lastName': 'García',
    });

    expect(user.firstName, 'Ana');
    expect(user.lastName, 'García');
  });

  test('names are null when the server returns null or omits them', () {
    final user = AuthUserModel.fromJson({..._base, 'firstName': null});

    expect(user.firstName, isNull);
    expect(user.lastName, isNull);
  });

  test('AccountProfileModel reads mustChangePassword', () {
    final pending = AccountProfileModel.fromJson({
      ..._base,
      'mustChangePassword': true,
    });
    final normal = AccountProfileModel.fromJson({
      ..._base,
      'mustChangePassword': false,
    });

    expect(pending.mustChangePassword, isTrue);
    expect(normal.mustChangePassword, isFalse);
    expect(pending.user.username, 'user123');
  });

  test('copyWith keeps identity fields and replaces names', () {
    final user = AuthUserModel.fromJson(_base).copyWith(firstName: 'Ana');

    expect(user.firstName, 'Ana');
    expect(user.username, 'user123');
    expect(user.email, 'user@example.com');
  });
}
