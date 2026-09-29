import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';

class NotificationDTO {
  final String id;
  final String travelId;
  final String type;
  final DateTime createdAt;
  final bool read;

  const NotificationDTO({
    required this.id,
    required this.travelId,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) => NotificationDTO(
        id: json['id'] as String,
        travelId: json['travelId'] as String,
        type: json['type'] as String,
        // The backend sends an ISO-8601 UTC instant — parsed as UTC, then
        // converted below so day-grouping and the displayed time both use
        // the agent's local clock, not the server's.
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool,
      );

  TravelNotification toDomain() => TravelNotification(
        id: id,
        travelId: travelId,
        type: switch (type) {
          'ROUTE_CREATED' => TravelNotificationType.routeCreated,
          'ROUTE_EDITED' => TravelNotificationType.routeEdited,
          _ => TravelNotificationType.unknown,
        },
        createdAt: createdAt.toLocal(),
        read: read,
      );
}
