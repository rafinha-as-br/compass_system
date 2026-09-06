import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/detect_travel_changes.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

RoutePlan _routePlan() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 19),
      startLocation: 'São Paulo',
      destination: 'Paraty',
      interestsList: const [],
    );

ItineraryStep _stop(String backEndId, DateTime start, DateTime finish) => ItineraryStep.newStop(
      domainId: 'local-$backEndId',
      backEndId: backEndId,
      title: 'Stop $backEndId',
      startDate: start,
      finishDate: finish,
      finished: false,
      name: 'Stop',
      description: '',
      experiences: const [],
    );

Travel _travel(TravelStatus status, {Itinerary? itinerary, String backEndId = 't1'}) => Travel(
      domainId: 'local-$backEndId',
      backEndId: backEndId,
      clientName: 'Rafaela Souza',
      travelName: 'Litoral Norte',
      travelStatus: status,
      participantsList: const [],
      routePlan: _routePlan(),
      itinerary: itinerary,
    );

void main() {
  group('detectTravelChanges', () {
    test('a travel with no backEndId (not yet persisted) never generates a notification', () {
      final travel = Travel(
        domainId: 'local-t1',
        backEndId: null,
        clientName: 'Rafaela Souza',
        travelName: 'Litoral Norte',
        travelStatus: TravelStatus.routeCreated,
        participantsList: const [],
        routePlan: _routePlan(),
      );

      expect(detectTravelChanges(travel, null), isEmpty);
    });

    test('no previous snapshot generates only "route received", never a retroactive itinerary notification', () {
      final travel = _travel(
        TravelStatus.itineraryCreated,
        itinerary: Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12)),
        ]),
      );

      final notifications = detectTravelChanges(travel, null);

      expect(notifications, hasLength(1));
      expect(notifications.single.type, TravelNotificationType.routeReceived);
      expect(notifications.single.travelId, 't1');
    });

    test('transitioning from route_created to itinerary_created generates "itinerary published"', () {
      final previous = TravelSnapshot(travelStatusApiValue: TravelStatus.routeCreated.toApiValue(), stepsSignature: '');
      final travel = _travel(
        TravelStatus.itineraryCreated,
        itinerary: Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
          _stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12)),
        ]),
      );

      final notifications = detectTravelChanges(travel, previous);

      expect(notifications, hasLength(1));
      expect(notifications.single.type, TravelNotificationType.itineraryPublished);
    });

    test('a step changing on an already-published itinerary generates "itinerary changed"', () {
      final oldItinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
        _stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12)),
      ]);
      final previous = TravelSnapshot(
        travelStatusApiValue: TravelStatus.itineraryCreated.toApiValue(),
        stepsSignature: snapshotOf(_travel(TravelStatus.itineraryCreated, itinerary: oldItinerary)).stepsSignature,
      );

      final newItinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
        _stop('s1', DateTime(2026, 10, 13), DateTime(2026, 10, 13)), // date changed
      ]);
      final travel = _travel(TravelStatus.itineraryCreated, itinerary: newItinerary);

      final notifications = detectTravelChanges(travel, previous);

      expect(notifications, hasLength(1));
      expect(notifications.single.type, TravelNotificationType.itineraryChanged);
    });

    test('no notification when nothing actually changed', () {
      final itinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
        _stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12)),
      ]);
      final travel = _travel(TravelStatus.itineraryCreated, itinerary: itinerary);
      final previous = snapshotOf(travel);

      expect(detectTravelChanges(travel, previous), isEmpty);
    });

    test('is idempotent: applying the same travel repeatedly after updating the snapshot never re-fires', () {
      final travel = _travel(TravelStatus.itineraryCreated, itinerary: Itinerary(
        domainId: 'it1',
        backEndId: 'it1',
        agentName: 'Ana',
        itinerarySteps: [_stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12))],
      ));

      // First time: no snapshot yet.
      final first = detectTravelChanges(travel, null);
      expect(first, hasLength(1));

      // Snapshot gets persisted after processing; a repeated fetch of the
      // exact same travel state must not fire again.
      final persisted = snapshotOf(travel);
      final second = detectTravelChanges(travel, persisted);
      expect(second, isEmpty);
    });

    test('no notification for a status change that does not cross the itinerary boundary (e.g. travel_started)', () {
      final itinerary = Itinerary(domainId: 'it1', backEndId: 'it1', agentName: 'Ana', itinerarySteps: [
        _stop('s1', DateTime(2026, 10, 12), DateTime(2026, 10, 12)),
      ]);
      final previous = snapshotOf(_travel(TravelStatus.itineraryCreated, itinerary: itinerary));
      final travel = _travel(TravelStatus.travelStarted, itinerary: itinerary);

      expect(detectTravelChanges(travel, previous), isEmpty);
    });
  });
}
