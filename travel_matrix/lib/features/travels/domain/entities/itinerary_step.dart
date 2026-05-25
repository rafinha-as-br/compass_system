import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'transport.dart';

/// Represents one small detailed part of a [Itinerary].
abstract class ItineraryStep {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? backEndId;
  /// Step for the title
  final String title;
  /// Start date for the step
  final DateTime startDate;
  /// Finish date for the step
  final DateTime finishDate;
  /// Whether the step is finished or not
  bool finished;

  /// Private constructor
  ItineraryStep._({
    required this.domainId,
    required this.backEndId,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.finished,
  });

  /// Creates a new [PlaceholderStep] for an [ItineraryStep].
  ///
  /// Factory constructor to create a new domain entity from view model entity
  factory ItineraryStep.newPlaceholder({
    required String domainId,
    required String? backEndId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime finishDate,
  }) {
    return PlaceholderStep._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      description: description,
      startDate: startDate,
      finishDate: finishDate,
      finished: false,
    );
  }

  /// Creates a new [Stop] for an [ItineraryStep]
  ///
  /// Factory constructor to create a new domain entity from view model entity
  factory ItineraryStep.newStop({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
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
      finished: false,
      name: name,
      description: description,
      experiences: experiences,
    );
  }

  /// Creates a new [Hosting] for an [ItineraryStep]
  ///
  /// Factory constructor to create a new domain entity from view model entity
  factory ItineraryStep.newHosting({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
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
      finished: false,
      name: name,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  /// Creates a new [TravelSegment] for an [ItineraryStep]
  ///
  /// Factory constructor to create a new domain entity from view model entity
  factory ItineraryStep.newTravelSegment({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
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
      finished: false,
      transport: transport,
      startPoint: startPoint,
      finishPoint: finishPoint,
    );
  }

}

/// Represents an [ItineraryStep] without type
class PlaceholderStep extends ItineraryStep {
  /// Description for the placeholder
  final String description;

  /// Private constructor
  PlaceholderStep._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.description,
  }): super._() ;

}

/// Represents a short period of time on a specific place
class Stop extends ItineraryStep {
  /// The place where the stop is located
  final String name;
  /// Description of the stop
  final String description;
  /// List of experiences lived on the stop
  final List<String> experiences;

  /// Private constructor
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
  }): super._();
}

/// Represents a hosting done on a specific place
class Hosting extends ItineraryStep {
  /// The place where the hosting is located
  final String name;
  /// Address of the place where the hosting is located
  final String address;
  /// Check in date of the hosting
  final DateTime checkIn;
  /// Check out date of the hosting
  final DateTime checkOut;

  /// Private constructor
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
    }): super._();
}

/// Represents a displacement on the [Itinerary], having different types of commuting.
class TravelSegment extends ItineraryStep {
  /// Type of transport used on the segment
  final Transport transport;
  /// Start point of the segment
  final String startPoint;
  /// Finish point of the segment
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
    required this.finishPoint
    }): super._();
}