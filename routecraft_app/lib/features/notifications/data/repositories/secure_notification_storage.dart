import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';

// ponytail: reusing flutter_secure_storage — already a dependency, via
// AuthService — instead of adding shared_preferences just to hold two small
// JSON blobs. Upgrade: move to shared_preferences/sqlite if the
// notification history ever grows large enough for that to matter.
class SecureNotificationStorage implements NotificationStorage {
  static const _snapshotsKey = 'travel_snapshots';
  static const _notificationsKey = 'travel_notifications';

  final FlutterSecureStorage _storage;

  SecureNotificationStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Map<String, TravelSnapshot>> loadSnapshots() async {
    final raw = await _storage.read(key: _snapshotsKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((id, json) {
      final map = json as Map<String, dynamic>;
      return MapEntry(
        id,
        TravelSnapshot(
          travelStatusApiValue: map['travelStatusApiValue'] as String,
          stepsSignature: map['stepsSignature'] as String,
        ),
      );
    });
  }

  @override
  Future<void> saveSnapshots(Map<String, TravelSnapshot> snapshots) async {
    final encoded = jsonEncode(snapshots.map((id, snapshot) => MapEntry(id, {
          'travelStatusApiValue': snapshot.travelStatusApiValue,
          'stepsSignature': snapshot.stepsSignature,
        })));
    await _storage.write(key: _snapshotsKey, value: encoded);
  }

  @override
  Future<List<TravelNotification>> loadNotifications() async {
    final raw = await _storage.read(key: _notificationsKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((json) {
      final map = json as Map<String, dynamic>;
      return TravelNotification(
        id: map['id'] as String,
        travelId: map['travelId'] as String,
        travelName: map['travelName'] as String,
        type: TravelNotificationType.values.byName(map['type'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        read: map['read'] as bool,
      );
    }).toList();
  }

  @override
  Future<void> saveNotifications(List<TravelNotification> notifications) async {
    final encoded = jsonEncode(notifications
        .map((n) => {
              'id': n.id,
              'travelId': n.travelId,
              'travelName': n.travelName,
              'type': n.type.name,
              'createdAt': n.createdAt.toIso8601String(),
              'read': n.read,
            })
        .toList());
    await _storage.write(key: _notificationsKey, value: encoded);
  }
}
