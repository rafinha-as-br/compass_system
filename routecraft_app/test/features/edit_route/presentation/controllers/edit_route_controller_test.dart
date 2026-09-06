import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/edit_route/presentation/controllers/edit_route_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/repositories/route_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/route_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations_en.dart';

class _FakeRouteRepository implements RouteRepository {
  Result<RoutePlan>? nextUpdateResult;
  String? capturedTravelId;
  RoutePlan? capturedRoutePlan;

  @override
  Future<Result<RoutePlan>> updateRoute(String travelId, RoutePlan routePlan) async {
    capturedTravelId = travelId;
    capturedRoutePlan = routePlan;
    return nextUpdateResult!;
  }
}

RoutePlan _originalRoute() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 19),
      startLocation: 'São Paulo',
      destination: 'Paraty',
      interestsList: [
        InterestPoint(domainId: 'i1', backEndId: 'i1', name: 'Trilha do Sono', description: ''),
        InterestPoint(domainId: 'i2', backEndId: 'i2', name: 'Passeio de escuna', description: ''),
      ],
    );

EditRouteController _controller({RouteRepository? repository, bool showPublishedWarning = false}) {
  return EditRouteController(
    travelId: 't1',
    original: _originalRoute(),
    showPublishedWarning: showPublishedWarning,
    routeUseCases: RouteUseCases(repository ?? _FakeRouteRepository()),
  );
}

final _l10n = AppLocalizationsEn();

void main() {
  group('EditRouteController.hasChanges', () {
    test('is false when nothing was edited', () {
      final controller = _controller();

      expect(controller.hasChanges, isFalse);
      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), isEmpty);
    });

    test('becomes true when the return date changes', () {
      final controller = _controller();

      controller.setEndDate(DateTime(2026, 10, 21));

      expect(controller.hasChanges, isTrue);
      expect(controller.endDateChanged, isTrue);
      expect(controller.startDateChanged, isFalse);
      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), ['return 19 Oct → 21 Oct']);
    });

    test('becomes true when the destination changes', () {
      final controller = _controller();

      controller.destinationController.text = 'Ubatuba';

      expect(controller.hasChanges, isTrue);
      expect(controller.destinationChanged, isTrue);
      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), ['destination Paraty → Ubatuba']);
    });

    test('becomes true when an interest point is added', () {
      final controller = _controller();

      controller.addInterestPoint('Gastronomia', '');

      expect(controller.hasChanges, isTrue);
      expect(controller.interestsAddedCount, 1);
      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), ['1 interest added']);
    });

    test('becomes true when an interest point is marked for removal, and the point stays visible', () {
      final controller = _controller();

      controller.markForRemoval('i2');

      expect(controller.hasChanges, isTrue);
      expect(controller.interestsRemovedCount, 1);
      expect(controller.isPendingRemoval('i2'), isTrue);
      expect(controller.interestPoints.map((p) => p.domainId), contains('i2'));
      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), ['1 interest removed']);
    });

    test('undoRemoval reverts a pending removal back to no changes', () {
      final controller = _controller();
      controller.markForRemoval('i2');

      controller.undoRemoval('i2');

      expect(controller.hasChanges, isFalse);
      expect(controller.isPendingRemoval('i2'), isFalse);
    });

    test('adding an interest point and then removing it in the same session cancels out to no change', () {
      final controller = _controller();
      controller.addInterestPoint('Gastronomia', '');
      final addedId = controller.interestPoints.last.domainId;

      controller.markForRemoval(addedId);

      expect(controller.interestsAddedCount, 0);
      expect(controller.interestsRemovedCount, 0);
      expect(controller.hasChanges, isFalse);
    });

    test('combines multiple changes into one description list, in a stable order', () {
      final controller = _controller();
      controller.setEndDate(DateTime(2026, 10, 21));
      controller.markForRemoval('i2');

      expect(editRouteChangeDescriptions(controller, _l10n, 'en'), [
        'return 19 Oct → 21 Oct',
        '1 interest removed',
      ]);
    });
  });

  group('EditRouteController.submit', () {
    test('does nothing when there are no changes', () async {
      final repository = _FakeRouteRepository();
      final controller = _controller(repository: repository);

      await controller.submit();

      expect(controller.state.isSuccess, isFalse);
      expect(repository.capturedRoutePlan, isNull);
    });

    test('sends the travelId and the updated route, excluding pending-removal points, on success', () async {
      final repository = _FakeRouteRepository()
        ..nextUpdateResult = Result.success(_originalRoute());
      final controller = _controller(repository: repository);
      controller.setEndDate(DateTime(2026, 10, 21));
      controller.markForRemoval('i2');

      await controller.submit();

      expect(controller.state.isSuccess, isTrue);
      expect(repository.capturedTravelId, 't1');
      expect(repository.capturedRoutePlan?.endDate, DateTime(2026, 10, 21));
      expect(repository.capturedRoutePlan?.interestsList.map((p) => p.domainId), ['i1']);
    });

    test('surfaces the repository failure message without touching isSuccess', () async {
      final repository = _FakeRouteRepository()..nextUpdateResult = const Result.failure('Erro de rede');
      final controller = _controller(repository: repository);
      controller.setEndDate(DateTime(2026, 10, 21));

      await controller.submit();

      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.submitErrorMessage, 'Erro de rede');
    });
  });
}
