import 'package:uuid/uuid.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

/// The snapshot to persist for [travel] after processing it.
TravelSnapshot snapshotOf(Travel travel) => TravelSnapshot(
      travelStatusApiValue: travel.travelStatus.toApiValue(),
      stepsSignature: _stepsSignature(travel.itinerary?.itinerarySteps ?? const []),
    );

String _stepsSignature(List<ItineraryStep> steps) {
  final parts = steps.map((s) => '${s.backEndId}:${s.startDate.toIso8601String()}:${s.finishDate.toIso8601String()}').toList()
    ..sort();
  return parts.join('|');
}

/// Compares [travel]'s current state against [previous] — the last
/// snapshot seen for it locally, `null` the very first time — and returns
/// the notifications this change should generate.
///
/// [previous] being `null` never generates a retroactive "itinerary
/// published"/"itinerary changed" notification for state that already
/// existed before this device started watching — it only generates "route
/// received", since seeing the travel at all for the first time is itself
/// the event worth surfacing.
List<TravelNotification> detectTravelChanges(Travel travel, TravelSnapshot? previous) {
  final travelId = travel.backEndId;
  if (travelId == null) return const [];

  if (previous == null) {
    return [_notification(travel, TravelNotificationType.routeReceived)];
  }

  final hadItinerary = TravelStatus.fromApiValue(previous.travelStatusApiValue) != TravelStatus.routeCreated;
  final hasItineraryNow = travel.hasItinerary;

  if (!hadItinerary && hasItineraryNow) {
    return [_notification(travel, TravelNotificationType.itineraryPublished)];
  }
  if (hadItinerary && hasItineraryNow && snapshotOf(travel).stepsSignature != previous.stepsSignature) {
    return [_notification(travel, TravelNotificationType.itineraryChanged)];
  }
  return const [];
}

TravelNotification _notification(Travel travel, TravelNotificationType type) => TravelNotification(
      id: const Uuid().v4(),
      travelId: travel.backEndId!,
      travelName: travel.travelName,
      type: type,
      createdAt: DateTime.now(),
    );
