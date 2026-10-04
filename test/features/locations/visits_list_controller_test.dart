import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/cancel_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/complete_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/delete_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_visits.dart';
import 'package:sky_plan/features/locations/presentation/state/visits_list_controller.dart';

import 'locations_test_support.dart';

VisitsListController _controller(FakeVisitsRepository repo) {
  return VisitsListController(
    getVisits: GetVisits(repo),
    completeVisit: CompleteVisit(repo),
    cancelVisit: CancelVisit(repo),
    deleteVisit: DeleteVisit(repo),
  );
}

void main() {
  test('load groups visits by status', () async {
    final repo = FakeVisitsRepository([
      makeVisit(id: 1),
      makeVisit(id: 2, status: VisitStatus.completed),
      makeVisit(id: 3, status: VisitStatus.cancelled),
      makeVisit(id: 4),
    ]);
    final controller = _controller(repo);

    await controller.load();

    expect(controller.hasLoaded, isTrue);
    expect(controller.countFor(VisitStatus.planned), 2);
    expect(controller.visitsFor(VisitStatus.completed).single.id, 2);
    expect(controller.visitsFor(VisitStatus.cancelled).single.id, 3);
  });

  test('load exposes the API error message', () async {
    final repo = FakeVisitsRepository()
      ..error = const ApiException(status: 500, message: 'Falla del servidor');
    final controller = _controller(repo);

    await controller.load();

    expect(controller.errorMessage, 'Falla del servidor');
    expect(controller.hasLoaded, isFalse);
  });

  test('delete removes the visit and returns null', () async {
    final repo = FakeVisitsRepository([makeVisit(id: 1), makeVisit(id: 2)]);
    final controller = _controller(repo);
    await controller.load();

    final error = await controller.delete(controller.visits.first);

    expect(error, isNull);
    expect(repo.deletedIds, [1]);
    expect(controller.visits.map((v) => v.id), [2]);
    expect(controller.busyIds, isEmpty);
  });

  test('complete and cancel replace the visit with its new status', () async {
    final repo = FakeVisitsRepository([makeVisit(id: 1), makeVisit(id: 2)]);
    final controller = _controller(repo);
    await controller.load();

    await controller.complete(controller.visits[0]);
    await controller.cancel(controller.visits[1]);

    expect(controller.visits[0].status, VisitStatus.completed);
    expect(controller.visits[1].status, VisitStatus.cancelled);
  });

  test('a failed action returns the message and keeps the list', () async {
    final repo = FakeVisitsRepository([makeVisit(id: 1)]);
    final controller = _controller(repo);
    await controller.load();
    repo.error = const ApiException(
      status: 400,
      message: 'La visita ya fue finalizada',
    );

    final error = await controller.complete(controller.visits.first);

    expect(error, 'La visita ya fue finalizada');
    expect(controller.visits.single.status, VisitStatus.planned);
  });
}
