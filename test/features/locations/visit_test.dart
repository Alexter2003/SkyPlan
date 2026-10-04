import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';

import 'locations_test_support.dart';

void main() {
  final today = DateTime(2026, 6, 15, 14, 30);

  test('only planned visits are editable and cancellable', () {
    expect(makeVisit().isEditable, isTrue);
    expect(makeVisit().canCancel, isTrue);
    expect(makeVisit(status: VisitStatus.completed).isEditable, isFalse);
    expect(makeVisit(status: VisitStatus.cancelled).canCancel, isFalse);
  });

  test('canComplete is true only when the date has arrived', () {
    expect(makeVisit(date: DateTime(2026, 6, 15)).canComplete(today), isTrue);
    expect(makeVisit(date: DateTime(2026, 6, 1)).canComplete(today), isTrue);
    expect(makeVisit(date: DateTime(2026, 6, 16)).canComplete(today), isFalse);
  });

  test('canComplete is false for frozen visits', () {
    final past = DateTime(2026, 6, 1);
    expect(
      makeVisit(date: past, status: VisitStatus.completed).canComplete(today),
      isFalse,
    );
    expect(
      makeVisit(date: past, status: VisitStatus.cancelled).canComplete(today),
      isFalse,
    );
  });
}
