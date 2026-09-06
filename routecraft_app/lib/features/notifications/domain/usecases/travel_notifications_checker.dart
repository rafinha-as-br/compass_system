import 'package:routecraft_app/features/notifications/data/repositories/secure_notification_storage.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/detect_travel_changes.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

/// Compares every freshly fetched [Travel] against its last-seen snapshot,
/// persists both the updated snapshots and any newly generated
/// notifications, and returns just the new ones. Meant to be called once
/// per travels fetch (`HomeController`) — the only place travel state is
/// refreshed, keeping notification generation in one spot.
class TravelNotificationsChecker {
  final NotificationStorage _storage;

  TravelNotificationsChecker({NotificationStorage? storage}) : _storage = storage ?? SecureNotificationStorage();

  Future<List<TravelNotification>> checkForChanges(List<Travel> travels) async {
    final snapshots = await _storage.loadSnapshots();
    final newNotifications = <TravelNotification>[];

    for (final travel in travels) {
      final travelId = travel.backEndId;
      if (travelId == null) continue;

      newNotifications.addAll(detectTravelChanges(travel, snapshots[travelId]));
      snapshots[travelId] = snapshotOf(travel);
    }

    await _storage.saveSnapshots(snapshots);
    if (newNotifications.isNotEmpty) {
      final existing = await _storage.loadNotifications();
      await _storage.saveNotifications([...existing, ...newNotifications]);
    }

    return newNotifications;
  }
}
