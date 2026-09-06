import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/travel_notifications_checker.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

class _FakeNotificationStorage implements NotificationStorage {
  Map<String, TravelSnapshot> snapshots = {};
  List<TravelNotification> notifications = [];

  @override
  Future<Map<String, TravelSnapshot>> loadSnapshots() async => snapshots;

  @override
  Future<void> saveSnapshots(Map<String, TravelSnapshot> value) async => snapshots = value;

  @override
  Future<List<TravelNotification>> loadNotifications() async => notifications;

  @override
  Future<void> saveNotifications(List<TravelNotification> value) async => notifications = value;
}

Travel _travel(String backEndId, TravelStatus status) => Travel(
      domainId: 'local-$backEndId',
      backEndId: backEndId,
      clientName: 'Rafaela Souza',
      travelName: 'Trip $backEndId',
      travelStatus: status,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: '$backEndId-route',
        backEndId: '$backEndId-route',
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 19),
        startLocation: 'São Paulo',
        destination: 'Paraty',
        interestsList: const [],
      ),
    );

void main() {
  group('TravelNotificationsChecker', () {
    test('the first check of a travel persists its snapshot and generates "route received"', () async {
      final storage = _FakeNotificationStorage();
      final checker = TravelNotificationsChecker(storage: storage);

      final result = await checker.checkForChanges([_travel('t1', TravelStatus.routeCreated)]);

      expect(result, hasLength(1));
      expect(result.single.type, TravelNotificationType.routeReceived);
      expect(storage.snapshots.containsKey('t1'), isTrue);
      expect(storage.notifications, hasLength(1));
    });

    test('a repeated check with no state change persists no new notifications', () async {
      final storage = _FakeNotificationStorage();
      final checker = TravelNotificationsChecker(storage: storage);
      await checker.checkForChanges([_travel('t1', TravelStatus.routeCreated)]);

      final second = await checker.checkForChanges([_travel('t1', TravelStatus.routeCreated)]);

      expect(second, isEmpty);
      expect(storage.notifications, hasLength(1)); // still just the first one
    });

    test('new notifications are appended to whatever was already stored', () async {
      final storage = _FakeNotificationStorage();
      final checker = TravelNotificationsChecker(storage: storage);
      await checker.checkForChanges([_travel('t1', TravelStatus.routeCreated)]);

      await checker.checkForChanges([_travel('t2', TravelStatus.routeCreated)]);

      expect(storage.notifications.map((n) => n.travelId), ['t1', 't2']);
    });
  });
}
