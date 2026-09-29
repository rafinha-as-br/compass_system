import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';

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
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool,
      );

  TravelNotification toDomain() => TravelNotification(
        id: id,
        travelId: travelId,
        type: switch (type) {
          'ITINERARY_PUBLISHED' => TravelNotificationType.itineraryPublished,
          'ITINERARY_STEP_CHANGED' => TravelNotificationType.itineraryChanged,
          _ => TravelNotificationType.unknown,
        },
        createdAt: createdAt,
        read: read,
      );
}
