import 'transport.dart';

/// Represents one step of an [Itinerary]. The client only ever reads this —
/// it's built by the agent in Travel Matrix.
abstract class ItineraryStep {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  final bool finished;

  ItineraryStep._({
    required this.domainId,
    required this.backEndId,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.finished,
  });

  factory ItineraryStep.newPlaceholder({
    required String domainId,
    required String? backEndId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime finishDate,
    required bool finished,
  }) {
    return PlaceholderStep._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      description: description,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
    );
  }

  factory ItineraryStep.newStop({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required bool finished,
    required String name,
    required String description,
    required List<String> experiences,
  }) {
    return Stop._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      name: name,
      description: description,
      experiences: experiences,
    );
  }

  factory ItineraryStep.newHosting({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required bool finished,
    required String name,
    required String address,
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    return Hosting._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      name: name,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  factory ItineraryStep.newTravelSegment({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required bool finished,
    required Transport transport,
    required String startPoint,
    required String finishPoint,
  }) {
    return TravelSegment._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      transport: transport,
      startPoint: startPoint,
      finishPoint: finishPoint,
    );
  }
}

class PlaceholderStep extends ItineraryStep {
  final String description;

  PlaceholderStep._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.description,
  }) : super._();
}

class Stop extends ItineraryStep {
  final String name;
  final String description;
  final List<String> experiences;

  Stop._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.description,
    required this.experiences,
  }) : super._();
}

class Hosting extends ItineraryStep {
  final String name;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  Hosting._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  }) : super._();
}

class TravelSegment extends ItineraryStep {
  final Transport transport;
  final String startPoint;
  final String finishPoint;

  TravelSegment._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.transport,
    required this.startPoint,
    required this.finishPoint,
  }) : super._();
}
