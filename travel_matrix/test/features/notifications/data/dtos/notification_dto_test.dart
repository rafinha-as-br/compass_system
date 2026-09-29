import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/notifications/data/dtos/notification_dto.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';

void main() {
  test('fromJson parses a ROUTE_CREATED notification', () {
    final dto = NotificationDTO.fromJson({
      'id': 'n1',
      'travelId': 't1',
      'type': 'ROUTE_CREATED',
      'createdAt': '2026-01-01T10:00:00Z',
      'read': false,
    });

    expect(dto.toDomain().type, TravelNotificationType.routeCreated);
  });

  test('fromJson parses a ROUTE_EDITED notification', () {
    final dto = NotificationDTO.fromJson({
      'id': 'n1',
      'travelId': 't1',
      'type': 'ROUTE_EDITED',
      'createdAt': '2026-01-01T10:00:00Z',
      'read': true,
    });

    final notification = dto.toDomain();
    expect(notification.type, TravelNotificationType.routeEdited);
    expect(notification.read, isTrue);
  });

  test('fromJson falls back to unknown for an unrecognized type', () {
    final dto = NotificationDTO.fromJson({
      'id': 'n1',
      'travelId': 't1',
      'type': 'ITINERARY_PUBLISHED',
      'createdAt': '2026-01-01T10:00:00Z',
      'read': false,
    });

    expect(dto.toDomain().type, TravelNotificationType.unknown);
  });
}
