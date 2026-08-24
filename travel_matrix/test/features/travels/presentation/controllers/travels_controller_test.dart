import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

Travel _buildTravel(String id) {
  return Travel(
    domainId: id,
    backEndId: id,
    clientName: 'Client $id',
    travelName: 'Travel $id',
    travelStatus: TravelStatus.routeCreated,
    participantsList: const <Person>[],
    routePlan: RoutePlan(
      domainId: 'route-$id',
      backEndId: 'route-$id',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Paris',
      interestsList: const <InterestPoint>[],
    ),
  );
}

void main() {
  late _MockCrudTravelUseCases travelUseCases;
  late _MockCrudRoute routeUseCases;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(
      RoutePlan(
        domainId: 'fallback',
        backEndId: null,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 2),
        startLocation: '',
        destination: '',
        interestsList: const <InterestPoint>[],
      ),
    );
  });

  setUp(() {
    travelUseCases = _MockCrudTravelUseCases();
    routeUseCases = _MockCrudRoute();
    when(() => travelUseCases.readAll()).thenAnswer((_) async => Result.success([_buildTravel('1')]));
  });

  test('fetchTravels populates the list on success', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.travels, hasLength(1));
  });

  test('fetchTravels keeps the previously loaded travels when a refetch fails', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();
    expect(controller.state.travels, hasLength(1));

    when(() => travelUseCases.readAll()).thenAnswer((_) async => const Result.failure('Network error'));
    await controller.fetchTravels();

    expect(controller.state.travels, hasLength(1));
    expect(controller.state.errorMessage, 'Network error');
  });

  test('createTravel forwards the raw request map and refetches on success', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();

    final request = {'clientId': 'c1', 'agentId': 'a1', 'travelName': 'Rome Trip'};
    when(() => travelUseCases.createFromRequest(request))
        .thenAnswer((_) async => Result.success(_buildTravel('2')));

    final success = await controller.createTravel(request);

    expect(success, isTrue);
    verify(() => travelUseCases.createFromRequest(request)).called(1);
    verify(() => travelUseCases.readAll()).called(2); // once on construction, once on refetch
  });

  test('createTravel returns false without refetching when creation fails', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();

    when(() => travelUseCases.createFromRequest(any()))
        .thenAnswer((_) async => const Result.failure('Validation error'));

    final success = await controller.createTravel({'travelName': 'x'});

    expect(success, isFalse);
    verify(() => travelUseCases.readAll()).called(1); // only the initial fetch
  });

  test('deleteTravel delegates to CrudTravelUseCases.delete and refetches on success', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();

    when(() => travelUseCases.delete('1')).thenAnswer((_) async => const Result.success(true));

    final success = await controller.deleteTravel('1');

    expect(success, isTrue);
    verify(() => travelUseCases.delete('1')).called(1);
  });

  test('markTravelAsReady delegates to CrudTravelUseCases.markAsReady and refetches on success', () async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    await pumpEventQueue();

    when(() => travelUseCases.markAsReady('1')).thenAnswer((_) async => Result.success(_buildTravel('1')));

    final success = await controller.markTravelAsReady('1');

    expect(success, isTrue);
    verify(() => travelUseCases.markAsReady('1')).called(1);
  });

  group('updateRoute', () {
    test('builds a RoutePlan from the raw form map and strips temporary interest-point ids', () async {
      final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
      await pumpEventQueue();

      when(() => routeUseCases.updateRoute(any(), any()))
          .thenAnswer((_) async => Result.success(_buildTravel('1').routePlan));

      final success = await controller.updateRoute('1', {
        'startDate': '2026-02-01T00:00:00.000',
        'endDate': '2026-02-10T00:00:00.000',
        'startLocation': 'SP',
        'destination': 'Rome',
        'interestsList': [
          {'id': 'poi_123', 'name': 'New POI', 'description': 'Freshly added'},
          {'id': 'interest-9', 'name': 'Old POI', 'description': 'Already saved'},
        ],
      });

      expect(success, isTrue);
      final captured = verify(() => routeUseCases.updateRoute('1', captureAny())).captured.single as RoutePlan;
      expect(captured.destination, 'Rome');
      expect(captured.startLocation, 'SP');
      expect(captured.interestsList, hasLength(2));
      expect(captured.interestsList[0].backEndId, isNull); // temp poi_ id stripped
      expect(captured.interestsList[1].backEndId, 'interest-9'); // real id kept
    });

    test('returns false without refetching when the route update fails', () async {
      final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
      await pumpEventQueue();

      when(() => routeUseCases.updateRoute(any(), any()))
          .thenAnswer((_) async => const Result.failure('Network error'));

      final success = await controller.updateRoute('1', {
        'startDate': '2026-02-01T00:00:00.000',
        'endDate': '2026-02-10T00:00:00.000',
        'startLocation': 'SP',
        'destination': 'Rome',
        'interestsList': [],
      });

      expect(success, isFalse);
      verify(() => travelUseCases.readAll()).called(1); // only the initial fetch
    });
  });

  group('default construction (no injected use cases)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppInjector.init();
    });

    test('builds its real Repository/UseCase chain without throwing', () {
      // Regression test: TravelsController's default constructor eagerly
      // builds RouteRepositoryImpl -> RouteDataSource, whose field initializer
      // reads RouteApiClient.instance synchronously. If RouteApiClient.init()
      // is ever dropped from CompassService.init() again, that getter's
      // `assert(_instance != null)` is stripped in release builds and the
      // trailing `!` throws "Null check operator used on a null value" the
      // instant this page is opened — before any network request fires.
      expect(() => TravelsController(), returnsNormally);
    });
  });
}
