import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/presentation/controllers/account_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class _FakeTravelRepository implements TravelRepository {
  Result<List<Travel>>? nextResult;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => nextResult!;

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

RoutePlan _routePlan() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Lisbon',
      interestsList: const [],
    );

Travel _travel(String name, {Itinerary? itinerary}) => Travel(
      domainId: name,
      backEndId: name,
      clientName: 'Maria Silva',
      travelName: name,
      travelStatus: itinerary == null ? TravelStatus.routeCreated : TravelStatus.itineraryCreated,
      participantsList: const [],
      routePlan: _routePlan(),
      itinerary: itinerary,
    );

Itinerary _itinerary(String agentName) =>
    Itinerary(domainId: 'it1', backEndId: 'it1', agentName: agentName, itinerarySteps: const []);

void main() {
  group('AccountController', () {
    test('loads the client name and email', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.success([]);
      final controller = AccountController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
        getClientEmail: () async => 'maria@example.com',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.clientName, 'Maria Silva');
      expect(controller.state.clientEmail, 'maria@example.com');
    });

    test('finds the agent name from the first travel that has an itinerary', () async {
      final repository = _FakeTravelRepository()
        ..nextResult = Result.success([
          _travel('Trip A'),
          _travel('Trip B', itinerary: _itinerary('Marcos Cardoso')),
        ]);
      final controller = AccountController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
        getClientEmail: () async => 'maria@example.com',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.agentName, 'Marcos Cardoso');
    });

    test('agentName stays null when no travel has an itinerary yet', () async {
      final repository = _FakeTravelRepository()..nextResult = Result.success([_travel('Trip A')]);
      final controller = AccountController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
        getClientEmail: () async => 'maria@example.com',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.agentName, isNull);
    });

    test('does not fetch travels and leaves everything empty when there is no session', () async {
      final repository = _FakeTravelRepository();
      final controller = AccountController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => null,
        getClientEmail: () async => null,
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.clientName, isNull);
      expect(controller.state.agentName, isNull);
    });

    test('degrades gracefully instead of crashing when reading the session throws', () async {
      final controller = AccountController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => throw StateError('secure storage unavailable'),
        getClientEmail: () async => null,
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.clientName, isNull);
    });
  });
}
