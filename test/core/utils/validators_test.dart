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
      expect(SkyValidators.password('abc123'), isNotNull);
    });

    test('rejects passwords without a digit', () {
      expect(SkyValidators.password('onlyletters'), isNotNull);
    });

    test('accepts a password mixing letters and digits, 8+ chars', () {
      expect(SkyValidators.password('sky2026plan'), isNull);
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
