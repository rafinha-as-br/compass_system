import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:uuid/uuid.dart';
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

  /// Creates a new [PlaceholderStep] for an [ItineraryStep]
  factory ItineraryStep.newPlaceholder({
    required String domainId,
    required String? backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
  }) {
    return PlaceholderStep._(
      domainId: domainId,
      backEndId: backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: false,
    );
  }

  /// Creates a new [Stop] for an [ItineraryStep]
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

  /// To json method, returns a [Map] with the step data
  Map<String, dynamic> toJson();

  /// From json method, returns a [ItineraryStep] from a [Map]
  ItineraryStep fromJson(Map<String, dynamic> json);
}

/// Represents an [ItineraryStep] without type
class PlaceholderStep extends ItineraryStep {
  /// Private constructor
  PlaceholderStep._({
    required super.domainId,
    required super.backEndId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
  }): super._() ;

  @override
  PlaceholderStep fromJson(Map<String, dynamic> json) {
    return PlaceholderStep._(
      domainId: Uuid().v4(),
      backEndId: json['backEndId'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
        finished: json['finished'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'backEndId': backEndId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'type': 'PlaceholderStep',
    };
  }

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

  @override
  Stop fromJson(Map<String, dynamic> json) {
    return Stop._(
      domainId: Uuid().v4(),
      backEndId: json['backEndId'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      experiences: List<String>.from(json['experiences']),
      name: json['name'],
      description: json['description'],
      finished: json['finished'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'backEndId': backEndId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'name': name,
      'description': description,
      'experiences': experiences,
      'type': 'Stop',
    };
  }

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

  @override
  Hosting fromJson(Map<String, dynamic> json) {
    return Hosting._(
      domainId: Uuid().v4(),
      backEndId: json['backEndId'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      address: json['address'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      name: json['name'],
      finished: json['finished'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'backEndId': backEndId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'name': name,
      'address': address,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'type': 'Hosting',
    };
  }


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



  @override
  TravelSegment fromJson(Map<String, dynamic> json) {
    return TravelSegment._(
      domainId: Uuid().v4(),
      backEndId: json['backEndId'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      finished: json['finished'],
      startPoint: json['startPoint'],
      finishPoint: json['finishPoint'],
      transport: json['transport'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'backEndId': backEndId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'startPoint': startPoint,
      'finishPoint': finishPoint,
      'transport': transport.toJson(),
      'type': 'TravelSegment',
    };

  }
}