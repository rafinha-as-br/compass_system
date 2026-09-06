import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';
import 'package:routecraft_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class _FakeNotificationStorage implements NotificationStorage {
  List<TravelNotification> notifications = [];
  List<TravelNotification>? saved;

  @override
  Future<List<TravelNotification>> loadNotifications() async => notifications;

  @override
  Future<void> saveNotifications(List<TravelNotification> value) async => saved = value;

  @override
  Future<Map<String, TravelSnapshot>> loadSnapshots() async => {};

  @override
  Future<void> saveSnapshots(Map<String, TravelSnapshot> value) async {}
}

class _FakeTravelRepository implements TravelRepository {
  Result<Travel>? nextGetResult;

  @override
  Future<Result<Travel>> getTravel(String id) async => nextGetResult!;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

TravelNotification _notification(String id, {bool read = false}) => TravelNotification(
      id: id,
      travelId: 't1',
      travelName: 'Litoral Norte',
      type: TravelNotificationType.routeReceived,
      createdAt: DateTime(2026, 9, 1),
      read: read,
    );

void main() {
  group('NotificationsController', () {
    test('loads notifications sorted newest-first', () async {
      final storage = _FakeNotificationStorage()
        ..notifications = [
          TravelNotification(
            id: 'n1',
            travelId: 't1',
            travelName: 'Litoral Norte',
            type: TravelNotificationType.routeReceived,
            createdAt: DateTime(2026, 9, 1),
          ),
          TravelNotification(
            id: 'n2',
            travelId: 't1',
            travelName: 'Litoral Norte',
            type: TravelNotificationType.itineraryPublished,
            createdAt: DateTime(2026, 9, 3),
          ),
        ];

      final controller = NotificationsController(storage: storage);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.notifications.map((n) => n.id), ['n2', 'n1']);
    });

    test('markAllRead flips every notification to read and persists it', () async {
      final storage = _FakeNotificationStorage()..notifications = [_notification('n1'), _notification('n2')];
      final controller = NotificationsController(storage: storage);
      await Future<void>.delayed(Duration.zero);

      await controller.markAllRead();

      expect(controller.state.notifications.every((n) => n.read), isTrue);
      expect(storage.saved?.every((n) => n.read), isTrue);
    });

    test('markAllRead does nothing when everything is already read', () async {
      final storage = _FakeNotificationStorage()..notifications = [_notification('n1', read: true)];
      final controller = NotificationsController(storage: storage);
      await Future<void>.delayed(Duration.zero);

      await controller.markAllRead();

      expect(storage.saved, isNull); // never wrote back — no-op short-circuit
    });

    test('resolveTravel returns the fetched travel on success', () async {
      final repository = _FakeTravelRepository()
        ..nextGetResult = Result.success(Travel(
          domainId: 'local-t1',
          backEndId: 't1',
          clientName: 'Rafaela Souza',
          travelName: 'Litoral Norte',
          travelStatus: TravelStatus.routeCreated,
          participantsList: const [],
          routePlan: RoutePlan(
            domainId: 'r1',
            backEndId: 'r1',
            startDate: DateTime(2026, 10, 12),
            endDate: DateTime(2026, 10, 19),
            startLocation: 'São Paulo',
            destination: 'Paraty',
            interestsList: const [],
          ),
        ));
      final controller = NotificationsController(
        storage: _FakeNotificationStorage(),
        travelUseCases: TravelUseCases(repository),
      );

      final travel = await controller.resolveTravel('t1');

      expect(travel?.travelName, 'Litoral Norte');
    });

    test('resolveTravel returns null on failure', () async {
      final repository = _FakeTravelRepository()..nextGetResult = const Result.failure('not found');
      final controller = NotificationsController(
        storage: _FakeNotificationStorage(),
        travelUseCases: TravelUseCases(repository),
      );

      expect(await controller.resolveTravel('t1'), isNull);
    });
  });
}
