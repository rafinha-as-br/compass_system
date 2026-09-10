import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/features/travels/presentation/controllers/travels_controller.dart';

class _FakeTravelRepository implements TravelRepository {
  Result<List<Travel>>? nextResult;
  String? capturedClientName;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async {
    capturedClientName = clientName;
    return nextResult!;
  }

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

Travel _travel(String name, TravelStatus status, {DateTime? startDate}) => Travel(
      domainId: name,
      backEndId: name,
      clientName: 'Maria Silva',
      travelName: name,
      travelStatus: status,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: '$name-route',
        backEndId: null,
        startDate: startDate ?? DateTime(2026, 1, 1),
        endDate: (startDate ?? DateTime(2026, 1, 1)).add(const Duration(days: 5)),
        startLocation: 'SP',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

void main() {
  group('TravelsController', () {
    test('loads every travel for the client, including finished ones', () async {
      final repository = _FakeTravelRepository()
        ..nextResult = Result.success([
          _travel('Chapada', TravelStatus.travelFinished),
          _travel('Litoral Norte', TravelStatus.travelStarted),
        ]);

      final controller = TravelsController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.travels.map((t) => t.travelName), ['Chapada', 'Litoral Norte']);
      expect(repository.capturedClientName, 'Maria Silva');
    });

    test('surfaces a repository failure as an error state', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.failure('boom');

      final controller = TravelsController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isError, isTrue);
    });

    test('filteredTravels: name search is case-insensitive and matches a substring', () {
      final state = TravelsState(
        travels: [
          _travel('Chapada Diamantina', TravelStatus.travelFinished),
          _travel('Serra Gaúcha', TravelStatus.routeCreated),
        ],
        isLoading: false,
      );
      final controller = TravelsController.withState(state);

      controller.setSearchQuery('chapada');

      expect(controller.state.filteredTravels.map((t) => t.travelName), ['Chapada Diamantina']);
    });

    test('filteredTravels: status filter narrows the list, null means every status', () {
      final state = TravelsState(
        travels: [
          _travel('Chapada Diamantina', TravelStatus.travelFinished),
          _travel('Serra Gaúcha', TravelStatus.routeCreated),
        ],
        isLoading: false,
      );
      final controller = TravelsController.withState(state);

      controller.setStatusFilter(TravelStatus.travelFinished);
      expect(controller.state.filteredTravels.map((t) => t.travelName), ['Chapada Diamantina']);

      controller.setStatusFilter(null);
      expect(controller.state.filteredTravels, hasLength(2));
    });

    test('filteredTravels sorts by start date, most recent first', () {
      final state = TravelsState(
        travels: [
          _travel('Antiga', TravelStatus.travelFinished, startDate: DateTime(2020, 1, 1)),
          _travel('Recente', TravelStatus.travelFinished, startDate: DateTime(2026, 1, 1)),
        ],
        isLoading: false,
      );
      final controller = TravelsController.withState(state);

      expect(controller.state.filteredTravels.map((t) => t.travelName), ['Recente', 'Antiga']);
    });

    test('hasNoResults is true only when travels exist but none match the filter', () {
      final withTravels = TravelsState(
        travels: [_travel('Chapada', TravelStatus.travelFinished)],
        isLoading: false,
        searchQuery: 'não existe',
      );
      expect(withTravels.hasNoResults, isTrue);

      const withoutTravels = TravelsState(isLoading: false);
      expect(withoutTravels.hasNoResults, isFalse);
      expect(withoutTravels.isEmpty, isTrue);
    });
  });
}
