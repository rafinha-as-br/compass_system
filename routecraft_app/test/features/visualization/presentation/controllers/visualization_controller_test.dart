import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/features/visualization/presentation/controllers/visualization_controller.dart';

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

Travel _travel(String name) => Travel(
      domainId: name,
      backEndId: name,
      clientName: 'Maria Silva',
      travelName: name,
      travelStatus: TravelStatus.routeCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: '$name-route',
        backEndId: null,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 10),
        startLocation: 'SP',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

void main() {
  group('VisualizationController', () {
    test('fetches travels for the resolved client name on construction', () async {
      final repository = _FakeTravelRepository()
        ..nextResult = Result.success([_travel('Trip A'), _travel('Trip B')]);

      final controller = VisualizationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await Future<void>.delayed(Duration.zero);

      expect(repository.capturedClientName, 'Maria Silva');
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.travels, hasLength(2));
    });

    test('shows an empty, non-loading state without calling the repository when there is no session', () async {
      final repository = _FakeTravelRepository();
      final controller = VisualizationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => null,
      );

      await Future<void>.delayed(Duration.zero);

      expect(repository.capturedClientName, isNull);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.travels, isEmpty);
    });

    test('degrades to an empty, non-loading state on a repository failure', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.failure('Erro de rede');
      final controller = VisualizationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.travels, isEmpty);
    });
  });
}
