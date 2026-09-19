import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/utils/validators.dart';

void main() {
  group('SkyValidators.required', () {
    test('rejects null and blank values', () {
      expect(SkyValidators.required(null), isNotNull);
      expect(SkyValidators.required('   '), isNotNull);
    });

    test('accepts non-blank values', () {
      expect(SkyValidators.required('Antigua Guatemala'), isNull);
    });
  });

  group('SkyValidators.email', () {
    test('rejects malformed addresses', () {
      expect(SkyValidators.email('not-an-email'), isNotNull);
      expect(SkyValidators.email('missing@tld'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(SkyValidators.email('user@example.com'), isNull);
    });
  });

  group('SkyValidators.password', () {
    test('rejects short passwords', () {
      expect(SkyValidators.password('Abc123'), isNotNull);
    });

    test('rejects passwords without a digit', () {
      expect(SkyValidators.password('OnlyLetters'), isNotNull);
    });

    test('rejects passwords without an uppercase letter', () {
      expect(SkyValidators.password('sky2026plan'), isNotNull);
    });

    test('rejects passwords without a lowercase letter', () {
      expect(SkyValidators.password('SKY2026PLAN'), isNotNull);
    });

    test('accepts a password mixing upper/lowercase and digits, 8+ chars', () {
      expect(SkyValidators.password('Sky2026plan'), isNull);
    });
  });

  group('SkyValidators.passwordRules', () {
    test('flags every unmet rule for an empty password', () {
      final rules = SkyValidators.passwordRules('');
      expect(rules.every((r) => !r.met), isTrue);
    });

    test('flags every rule as met for a compliant password', () {
      final rules = SkyValidators.passwordRules('Sky2026plan');
      expect(rules.every((r) => r.met), isTrue);
    });
  });

  group('SkyValidators.username', () {
    test('rejects usernames shorter than 3 characters', () {
      expect(SkyValidators.username('ab'), isNotNull);
    });

    test('rejects usernames with disallowed characters', () {
      expect(SkyValidators.username('user name!'), isNotNull);
    });

    test('accepts a valid username', () {
      expect(SkyValidators.username('user.123-_'), isNull);
    });
  });

  group('SkyValidators.loginIdentifier', () {
    test('rejects a too-short identifier', () {
      expect(SkyValidators.loginIdentifier('ab'), isNotNull);
    });

    test('accepts an email or username indistinctly', () {
      expect(SkyValidators.loginIdentifier('user@example.com'), isNull);
      expect(SkyValidators.loginIdentifier('user123'), isNull);
    });
  });

  group('SkyValidators.confirmationCode', () {
    test('rejects a code that is not 5 alphanumeric characters', () {
      expect(SkyValidators.confirmationCode('A1B2'), isNotNull);
      expect(SkyValidators.confirmationCode('A1B2C3'), isNotNull);
      expect(SkyValidators.confirmationCode('A1B-C'), isNotNull);
    });

    test('accepts a well-formed code', () {
      expect(SkyValidators.confirmationCode('A1B2C'), isNull);
    });
  });

  group('SkyValidators.passwordsMatch', () {
    test('rejects a mismatched confirmation', () {
      expect(
        SkyValidators.passwordsMatch('sky2026plan', 'other2026'),
        isNotNull,
      );
    });

    test('accepts a matching confirmation', () {
      expect(
        SkyValidators.passwordsMatch('sky2026plan', 'sky2026plan'),
        isNull,
      );
    });
  });

  group('SkyValidators.rangesOverlap', () {
    test('detects overlapping activity time ranges', () {
      final start = DateTime(2026, 9, 6, 15);
      final end = DateTime(2026, 9, 6, 17);
      final otherStart = DateTime(2026, 9, 6, 16);
      final otherEnd = DateTime(2026, 9, 6, 18);

      expect(
        SkyValidators.rangesOverlap(start, end, otherStart, otherEnd),
        isTrue,
      );
    });

    test('back-to-back ranges do not overlap', () {
      final start = DateTime(2026, 9, 6, 15);
      final end = DateTime(2026, 9, 6, 17);
      final otherStart = DateTime(2026, 9, 6, 17);
      final otherEnd = DateTime(2026, 9, 6, 18);

      expect(
        SkyValidators.rangesOverlap(start, end, otherStart, otherEnd),
        isFalse,
      );
    });
  });
}
