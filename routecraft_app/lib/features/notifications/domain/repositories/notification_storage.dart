import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';

/// Local persistence for notification data — snapshots keyed by the
/// travel's stable `backEndId` (never `domainId`, which is re-minted on
/// every fetch) and the notification list itself, both surviving app
/// restarts.
abstract interface class NotificationStorage {
  Future<Map<String, TravelSnapshot>> loadSnapshots();
  Future<void> saveSnapshots(Map<String, TravelSnapshot> snapshots);
  Future<List<TravelNotification>> loadNotifications();
  Future<void> saveNotifications(List<TravelNotification> notifications);
}
