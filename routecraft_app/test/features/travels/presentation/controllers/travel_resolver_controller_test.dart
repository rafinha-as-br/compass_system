import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/features/travels/presentation/controllers/travel_resolver_controller.dart';

class _FakeTravelRepository implements TravelRepository {
  Result<Travel>? nextResult;
  String? capturedId;

  @override
  Future<Result<Travel>> getTravel(String id) async {
    capturedId = id;
    return nextResult!;
  }

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => throw UnimplementedError();

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
        endDate: DateTime(2026, 1, 5),
        startLocation: 'SP',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );

void main() {
  group('TravelResolverController', () {
    test('fetches the travel by id and exposes it once loaded', () async {
      final repository = _FakeTravelRepository()..nextResult = Result.success(_travel('Chapada'));

      final controller = TravelResolverController(travelId: 't1', travelUseCases: TravelUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isError, isFalse);
      expect(controller.state.travel?.travelName, 'Chapada');
      expect(repository.capturedId, 't1');
    });

    test('surfaces a repository failure as an error state', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.failure('not found');

      final controller = TravelResolverController(travelId: 't1', travelUseCases: TravelUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isError, isTrue);
      expect(controller.state.travel, isNull);
    });

    test('retry re-runs the fetch', () async {
      final repository = _FakeTravelRepository()..nextResult = const Result.failure('boom');
      final controller = TravelResolverController(travelId: 't1', travelUseCases: TravelUseCases(repository));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.isError, isTrue);

      repository.nextResult = Result.success(_travel('Chapada'));
      await controller.retry();

      expect(controller.state.isError, isFalse);
      expect(controller.state.travel?.travelName, 'Chapada');
    });
  });
}
