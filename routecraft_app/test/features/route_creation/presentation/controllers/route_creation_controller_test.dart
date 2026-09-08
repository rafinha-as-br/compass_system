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

Future<RouteCreationController> _controllerAtReview({
  required TravelUseCases travelUseCases,
  required Future<String?> Function() getClientName,
}) async {
  final controller = RouteCreationController(travelUseCases: travelUseCases, getClientName: getClientName);
  await Future<void>.delayed(Duration.zero); // let the client auto-participant load
  controller.tripNameController.text = 'My Trip';
  controller.setStartDate(DateTime(2026, 1, 1));
  controller.setEndDate(DateTime(2026, 1, 10));
  controller.startLocationController.text = 'SP';
  controller.destinationController.text = 'Lisbon';
  controller.updateParticipant(controller.participants.single.domainId, age: '30', sex: 'F');
  for (var i = 0; i < routeCreationStepCount; i++) {
    controller.nextStep();
  }
  return controller;
}

void main() {
  group('RouteCreationController step validation', () {
    test('does not advance past the name step while it is empty', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );

      controller.nextStep();

      expect(controller.state.currentStep, 0);
    });

    test('advances past the name step once it is filled', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.tripNameController.text = 'Litoral Norte';

      controller.nextStep();

      expect(controller.state.currentStep, 1);
    });

    test('does not advance past the dates step without both dates set', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.tripNameController.text = 'Trip';
      controller.nextStep();
      controller.setStartDate(DateTime(2026, 1, 10));

      controller.nextStep();

      expect(controller.state.currentStep, 1);
    });

    test('does not advance past the dates step when the return is before the departure', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.tripNameController.text = 'Trip';
      controller.nextStep();
      controller.setStartDate(DateTime(2026, 1, 10));
      controller.setEndDate(DateTime(2026, 1, 5));

      controller.nextStep();

      expect(controller.state.currentStep, 1);
      expect(controller.isDatesValid, isFalse);
    });

    test('reports the number of nights once dates are coherent', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );

      controller.setStartDate(DateTime(2026, 10, 12));
      controller.setEndDate(DateTime(2026, 10, 19));

      expect(controller.isDatesValid, isTrue);
      expect(controller.nights, 7);
    });

    test('does not advance past the locations step while either field is empty', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.tripNameController.text = 'Trip';
      controller.nextStep();
      controller.setStartDate(DateTime(2026, 1, 1));
      controller.setEndDate(DateTime(2026, 1, 5));
      controller.nextStep();
      controller.startLocationController.text = 'SP';

      controller.nextStep();

      expect(controller.state.currentStep, 2);
    });

    test('advances past the optional interests step with no interests added', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.tripNameController.text = 'Trip';
      controller.nextStep();
      controller.setStartDate(DateTime(2026, 1, 1));
      controller.setEndDate(DateTime(2026, 1, 5));
      controller.nextStep();
      controller.startLocationController.text = 'SP';
      controller.destinationController.text = 'Lisbon';
      controller.nextStep();

      controller.nextStep();

      // Arrived at the participants step (5th), not the review — interests
      // didn't block advancement even with none added.
      expect(controller.state.currentStep, 4);
    });

    test('editStep jumps back from the review to the given step', () async {
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      expect(controller.state.isReviewStep, isTrue);

      controller.editStep(0);

      expect(controller.state.currentStep, 0);
    });

    test('applyWeekShortcut sets a 7-night range starting tomorrow', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );

      controller.applyWeekShortcut();

      expect(controller.isDatesValid, isTrue);
      expect(controller.nights, 7);
    });

    test('applyWeekendShortcut picks a Saturday/Sunday pair', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );

      controller.applyWeekendShortcut();

      expect(controller.startDate!.weekday, DateTime.saturday);
      expect(controller.endDate!.weekday, DateTime.sunday);
    });
  });

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
          routePlan: RoutePlan(
            domainId: 'd-route',
            backEndId: null,
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 10),
            startLocation: 'SP',
            destination: 'Lisbon',
            interestsList: const [],
          ),
        ));

      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await controller.submitRoute();

      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.submitErrorMessage, isNull);
      expect(repository.capturedTravel?.clientName, 'Maria Silva');
      expect(repository.capturedTravel?.travelName, 'My Trip');
      expect(repository.capturedTravel?.routePlan.startLocation, 'SP');
    });

    test('fails fast without calling the repository when there is no session', () async {
      final repository = _FakeTravelRepository();
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => null,
      );

      await controller.submitRoute();

      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.hasNoSession, isTrue);
      expect(repository.capturedTravel, isNull);
    });

    test('surfaces the repository failure message', () async {
      final repository = _FakeTravelRepository()..nextCreateResult = const Result.failure('Erro de rede');
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await controller.submitRoute();

      expect(controller.state.isSuccess, isFalse);
      expect(controller.state.submitErrorMessage, 'Erro de rede');
    });

    test('a new attempt clears the previous failure message, even when the retry has no session', () async {
      final repository = _FakeTravelRepository()..nextCreateResult = const Result.failure('Erro de rede');
      String? clientName = 'Maria Silva';
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => clientName,
      );
      await controller.submitRoute();
      expect(controller.state.submitErrorMessage, 'Erro de rede');

      clientName = null; // simulate the session dropping before the retry
      await controller.submitRoute();

      expect(controller.state.hasNoSession, isTrue);
      expect(controller.state.submitErrorMessage, isNull);
    });
  });

  group('RouteCreationController interest points', () {
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

    test('removeInterestPoint removes the point with the matching id', () {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => null,
      );
      controller.addInterestPoint('Trilha', '');
      final id = controller.interestPoints.single.domainId;

      controller.removeInterestPoint(id);

      expect(controller.interestPoints, isEmpty);
    });
  });

  group('RouteCreationController participants', () {
    test('the client is added automatically once the client name resolves', () async {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.participants, hasLength(1));
      expect(controller.participants.single.name, 'Maria Silva');
      expect(controller.isClientParticipant(controller.participants.single), isTrue);
    });

    test('the client cannot be removed', () async {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);
      final clientId = controller.participants.single.domainId;

      controller.removeParticipant(clientId);

      expect(controller.participants, hasLength(1));
    });

    test('addParticipant appends a participant that can be removed', () async {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);

      controller.addParticipant(name: 'João', age: '10', sex: 'M');

      expect(controller.participants, hasLength(2));
      final added = controller.participants.last;
      expect(added.name, 'João');
      expect(controller.isClientParticipant(added), isFalse);

      controller.removeParticipant(added.domainId);

      expect(controller.participants, hasLength(1));
    });

    test('updateParticipant changes only the given fields', () async {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);
      final clientId = controller.participants.single.domainId;

      controller.updateParticipant(clientId, age: '35');
      controller.updateParticipant(clientId, sex: 'F');

      final client = controller.participants.single;
      expect(client.name, 'Maria Silva');
      expect(client.age, '35');
      expect(client.sex, 'F');
    });

    test('isParticipantsValid is false until every participant has name/age/sex filled', () async {
      final controller = RouteCreationController(
        travelUseCases: TravelUseCases(_FakeTravelRepository()),
        getClientName: () async => 'Maria Silva',
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.isParticipantsValid, isFalse); // client's age/sex still empty

      controller.updateParticipant(controller.participants.single.domainId, age: '30', sex: 'F');
      expect(controller.isParticipantsValid, isTrue);

      controller.addParticipant(name: 'João', age: '', sex: 'M');
      expect(controller.isParticipantsValid, isFalse); // new participant missing age
    });

    test('submitRoute sends the real participants list', () async {
      final repository = _FakeTravelRepository()
        ..nextCreateResult = Result.success(Travel(
          domainId: 'd1',
          backEndId: 'assigned-id',
          clientName: 'Maria Silva',
          travelName: 'My Trip',
          travelStatus: TravelStatus.routeCreated,
          participantsList: const [],
          routePlan: RoutePlan(
            domainId: 'd-route',
            backEndId: null,
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 10),
            startLocation: 'SP',
            destination: 'Lisbon',
            interestsList: const [],
          ),
        ));
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      controller.addParticipant(name: 'João', age: '10', sex: 'M');

      await controller.submitRoute();

      expect(repository.capturedTravel?.participantsList, hasLength(2));
      expect(repository.capturedTravel?.participantsList.map((p) => p.name), contains('João'));
      expect(repository.capturedTravel?.participantsList.map((p) => p.name), contains('Maria Silva'));
    });
  });

  group('RouteCreationController observations', () {
    test('submitRoute sends the trimmed observations text', () async {
      final repository = _FakeTravelRepository()..nextCreateResult = Result.success(_dummyTravel());
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );
      controller.observationsController.text = '  Viajando com bebê de colo.  ';

      await controller.submitRoute();

      expect(repository.capturedTravel?.observations, 'Viajando com bebê de colo.');
    });

    test('submitRoute sends null when observations is left empty', () async {
      final repository = _FakeTravelRepository()..nextCreateResult = Result.success(_dummyTravel());
      final controller = await _controllerAtReview(
        travelUseCases: TravelUseCases(repository),
        getClientName: () async => 'Maria Silva',
      );

      await controller.submitRoute();

      expect(repository.capturedTravel?.observations, isNull);
    });
  });
}

Travel _dummyTravel() => Travel(
      domainId: 'd1',
      backEndId: 'assigned-id',
      clientName: 'Maria Silva',
      travelName: 'My Trip',
      travelStatus: TravelStatus.routeCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: 'd-route',
        backEndId: null,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 10),
        startLocation: 'SP',
        destination: 'Lisbon',
        interestsList: const [],
      ),
    );
