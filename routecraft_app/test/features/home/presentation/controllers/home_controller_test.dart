import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/home/presentation/controllers/home_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

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
  group('HomeController', () {
    test('groups travels by urgency: in progress, upcoming, completed', () async {
      final repository = _FakeTravelRepository()
        ..nextResult = Result.success([
          _travel('Chapada', TravelStatus.travelFinished),
          _travel('Litoral Norte', TravelStatus.travelStarted),
          _travel('Serra Gaúcha', TravelStatus.routeCreated),
          _travel('Bahia', TravelStatus.itineraryCreated),
        ]);

      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.inProgress.map((t) => t.travelName), ['Litoral Norte']);
      expect(controller.state.upcoming.map((t) => t.travelName), containsAll(['Serra Gaúcha', 'Bahia']));
      expect(controller.state.completed.map((t) => t.travelName), ['Chapada']);
    });

    test('sorts upcoming travels by the earliest route start date', () async {
      final repository = _FakeTravelRepository()
        ..nextResult = Result.success([
          _travel('Later', TravelStatus.routeCreated, startDate: DateTime(2026, 3, 1)),
          _travel('Sooner', TravelStatus.routeCreated, startDate: DateTime(2026, 1, 1)),
        ]);

      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.upcoming.map((t) => t.travelName), ['Sooner', 'Later']);
    });

    test('shows an empty, non-loading state without calling the repository when there is no session', () async {
      final repository = _FakeTravelRepository();
      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => null,
      );

      await Future<void>.delayed(Duration.zero);

      expect(repository.capturedClientName, isNull);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isEmpty, isTrue);
    });

    test('degrades to an empty, non-loading state on a repository failure', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.failure('Erro de rede');
      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isEmpty, isTrue);
    });

    test('degrades to an empty, non-loading state when reading the client name throws', () async {
      final repository = _FakeTravelRepository();
      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => throw StateError('secure storage unavailable'),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isEmpty, isTrue);
    });

    test('refresh() re-fetches, picking up a travel created after the initial load', () async {
      final repository = _FakeTravelRepository()..nextResult = Result.success(const []);
      final controller = HomeController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.isEmpty, isTrue);

      repository.nextResult = Result.success([_travel('Nova Rota', TravelStatus.routeCreated)]);
      await controller.refresh();

      expect(controller.state.upcoming.map((t) => t.travelName), ['Nova Rota']);
    });
  });
}
