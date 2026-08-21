import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/route_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';

class _MockTravelRepository extends Mock implements TravelRepository {}

Travel _buildTravel(RoutePlan routePlan) {
  return Travel(
    domainId: 'travel-1',
    backEndId: 'travel-1',
    clientName: 'client-1',
    travelName: 'Paris Trip',
    travelStatus: TravelStatus.routeCreated,
    participantsList: const <Person>[],
    routePlan: routePlan,
  );
}

RoutePlan _buildRoute({
  String destination = 'Paris',
  String? domainId = 'route-1',
  String? backEndId = 'route-1',
}) {
  return RoutePlan(
    domainId: domainId ?? 'route-1',
    backEndId: backEndId,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 10),
    startLocation: 'SP',
    destination: destination,
    interestsList: const <InterestPoint>[],
  );
}

void main() {
  late _MockTravelRepository travelRepository;
  late RouteRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_buildTravel(_buildRoute()));
  });

  setUp(() {
    travelRepository = _MockTravelRepository();
    repository = RouteRepositoryImpl(travelRepository: travelRepository);
  });

  test('fetches the travel, replaces its routePlan, updates it, and returns the new route', () async {
    final oldRoute = _buildRoute(destination: 'Paris', backEndId: 'route-1');
    // The incoming plan carries no backend id of its own (as freshly built
    // form data would) — the repository must keep the existing route's
    // identity so the backend updates it in place instead of creating a new one.
    final newRoute = _buildRoute(destination: 'Rome', domainId: 'form-temp', backEndId: null);
    final travel = _buildTravel(oldRoute);

    when(() => travelRepository.getTravel('travel-1')).thenAnswer((_) async => Result.success(travel));
    when(() => travelRepository.updateTravel(any())).thenAnswer(
      (invocation) async => Result.success(invocation.positionalArguments.first as Travel),
    );

    final result = await repository.updateRoute('travel-1', newRoute);

    expect(result.isSuccess, isTrue);
    expect(result.data!.destination, 'Rome');

    final updatedTravel = verify(() => travelRepository.updateTravel(captureAny())).captured.single as Travel;
    expect(updatedTravel.routePlan.destination, 'Rome');
    expect(updatedTravel.routePlan.backEndId, 'route-1');
    expect(updatedTravel.routePlan.domainId, oldRoute.domainId);
    expect(updatedTravel.backEndId, 'travel-1');
    expect(updatedTravel.travelStatus, TravelStatus.routeCreated);
  });

  test('returns failure without updating when the travel cannot be fetched', () async {
    when(() => travelRepository.getTravel('missing'))
        .thenAnswer((_) async => const Result.failure('Travel not found.'));

    final result = await repository.updateRoute('missing', _buildRoute());

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Travel not found.');
    verifyNever(() => travelRepository.updateTravel(any()));
  });

  test('returns failure when the travel update itself fails', () async {
    final travel = _buildTravel(_buildRoute());
    when(() => travelRepository.getTravel('travel-1')).thenAnswer((_) async => Result.success(travel));
    when(() => travelRepository.updateTravel(any()))
        .thenAnswer((_) async => const Result.failure('Network error'));

    final result = await repository.updateRoute('travel-1', _buildRoute(destination: 'Rome'));

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Network error');
  });
}
