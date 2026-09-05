import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class _FakeTravelRepository implements TravelRepository {
  Result<Travel>? nextCreateResult;
  Travel? capturedTravel;

  @override
  Future<Result<Travel>> createTravel(Travel travel) async {
    capturedTravel = travel;
    return nextCreateResult!;
  }

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => throw UnimplementedError();
}

RoutePlan _routePlan() => RoutePlan(
      domainId: 'd-route',
      backEndId: null,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Lisbon',
      interestsList: const [],
    );

void main() {
  group('RouteCreationController.submitRoute', () {
    test('resolves the client name and submits a full Travel, marking success', () async {
      final repository = _FakeTravelRepository()
        ..nextCreateResult = Result.success(Travel(
          domainId: 'd1',
          backEndId: 'assigned-id',
          clientName: 'Maria Silva',
          travelName: 'My Trip',
          travelStatus: TravelStatus.routeCreated,
          participantsList: const [],
          routePlan: _routePlan(),
        ));

      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      controller.tripNameController.text = 'My Trip';
      controller.startLocationController.text = 'SP';
      controller.destinationController.text = 'Lisbon';

      await controller.submitRoute();

      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.errorMessage, isNull);
      expect(repository.capturedTravel?.clientName, 'Maria Silva');
      expect(repository.capturedTravel?.travelName, 'My Trip');
      expect(repository.capturedTravel?.routePlan.startLocation, 'SP');
    });

    test('fails fast without calling the repository when there is no session', () async {
      final repository = _FakeTravelRepository();
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => null,
      );

      await controller.submitRoute();

      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.errorMessage, isNotNull);
      expect(repository.capturedTravel, isNull);
    });

    test('surfaces the repository failure message', () async {
      final repository = _FakeTravelRepository()..nextCreateResult = const Result.failure('Erro de rede');
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await controller.submitRoute();

      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.errorMessage, contains('Erro de rede'));
    });

    test('addInterestPoint appends a point carrying the given name/description', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );

      controller.addInterestPoint('Culture & History', 'Historical sites');

      expect(controller.interestPoints, hasLength(1));
      expect(controller.interestPoints.single.name, 'Culture & History');
      expect(controller.interestPoints.single.backEndId, isNull);
    });
  });
}
