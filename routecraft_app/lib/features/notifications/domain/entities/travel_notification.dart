enum TravelNotificationType { itineraryPublished, itineraryChanged, routeReceived }

/// A notification about a change in one of the client's travels, derived
/// entirely on-device by comparing freshly fetched state against the last
/// snapshot seen locally — the backend has no notifications endpoint, so
/// this is the only source of these (see `detectTravelChanges`).
class TravelNotification {
  final String id;
  final String travelId;
  final String travelName;
  final TravelNotificationType type;
  final DateTime createdAt;
  final bool read;

  const TravelNotification({
    required this.id,
    required this.travelId,
    required this.travelName,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  TravelNotification copyWith({bool? read}) => TravelNotification(
        id: id,
        travelId: travelId,
        travelName: travelName,
        type: type,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

/// The last-seen state of one travel — compared against a fresh fetch to
/// derive [TravelNotification]s without any backend support for them.
class TravelSnapshot {
  final String travelStatusApiValue;

  /// Fingerprint of the itinerary's steps (count + identity + dates) —
  /// equal snapshots mean nothing about the itinerary changed, without
  /// needing to compare full step objects field by field.
  final String stepsSignature;

  const TravelSnapshot({required this.travelStatusApiValue, required this.stepsSignature});
}
