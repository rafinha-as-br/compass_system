import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';

class _MockTravelRepository extends Mock implements TravelRepository {}

Travel _buildTravel({
  String id = 'travel-1',
  TravelStatus status = TravelStatus.routeCreated,
}) {
  return Travel(
    domainId: id,
    backEndId: id,
    clientName: 'client-1',
    travelName: 'Paris Trip',
    travelStatus: status,
    participantsList: const <Person>[],
    routePlan: RoutePlan(
      domainId: 'route-1',
      backEndId: 'route-1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Paris',
      interestsList: const <InterestPoint>[],
    ),
  );
}

void main() {
  late _MockTravelRepository repository;
  late CrudTravelUseCases useCases;

  setUpAll(() {
    registerFallbackValue(_buildTravel());
  });

  setUp(() {
    repository = _MockTravelRepository();
    useCases = CrudTravelUseCases(repository);
  });

  group('markAsReady', () {
    test('fetches the travel, sets status to itineraryCreated, and updates it', () async {
      final travel = _buildTravel();
      when(() => repository.getTravel('travel-1'))
          .thenAnswer((_) async => Result.success(travel));
      when(() => repository.updateTravel(any()))
          .thenAnswer((invocation) async => Result.success(invocation.positionalArguments.first as Travel));

      final result = await useCases.markAsReady('travel-1');

      expect(result.isSuccess, isTrue);
      expect(result.data!.travelStatus, TravelStatus.itineraryCreated);
      final updatedArg = verify(() => repository.updateTravel(captureAny())).captured.single as Travel;
      expect(updatedArg.travelStatus, TravelStatus.itineraryCreated);
    });

    test('returns failure without calling update when the travel cannot be fetched', () async {
      when(() => repository.getTravel('missing'))
          .thenAnswer((_) async => const Result.failure('Travel not found.'));

      final result = await useCases.markAsReady('missing');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Travel not found.');
      verifyNever(() => repository.updateTravel(any()));
    });
  });

  test('create delegates to repository.createTravel', () async {
    final travel = _buildTravel();
    when(() => repository.createTravel(travel)).thenAnswer((_) async => Result.success(travel));

    final result = await useCases.create(travel);

    expect(result.isSuccess, isTrue);
    verify(() => repository.createTravel(travel)).called(1);
  });

  test('createFromRequest delegates to repository.createTravelFromRequest', () async {
    final travel = _buildTravel();
    final request = {'clientId': 'client-1', 'agentId': 'agent-1', 'travelName': 'Paris Trip'};
    when(() => repository.createTravelFromRequest(request)).thenAnswer((_) async => Result.success(travel));

    final result = await useCases.createFromRequest(request);

    expect(result.isSuccess, isTrue);
    verify(() => repository.createTravelFromRequest(request)).called(1);
  });

  test('delete delegates to repository.deleteTravel', () async {
    when(() => repository.deleteTravel('travel-1')).thenAnswer((_) async => const Result.success(true));

    final result = await useCases.delete('travel-1');

    expect(result.isSuccess, isTrue);
    verify(() => repository.deleteTravel('travel-1')).called(1);
  });
}
