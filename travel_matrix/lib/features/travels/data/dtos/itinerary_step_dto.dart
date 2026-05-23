import 'package:travel_matrix/features/travels/data/dtos/transport_dto.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/itinerary_step.dart';

/// Data transfer object for [ItineraryStep], having the same structure as the API.
abstract class ItineraryStepDTO {
  /// Main id used for API reference
  final String? id;
  /// Step title
  final String title;
  /// Start date for the step
  final DateTime startDate;
  /// Finish date for the step
  final DateTime finishDate;
  /// Whether the step is finished or not
  final bool finished;

  ItineraryStepDTO({
    required this.id,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.finished,
  });

  /// Factory constructor to create a Step DTO type from JSON
  factory ItineraryStepDTO.fromJson(Map<String, dynamic> json) {
    final type = json[ItineraryStepAPIConstants.type];
    switch (type) {
      case ItineraryStepAPIConstants.placeholder:
        return PlaceholderStepDTO.fromJson(json);
      case ItineraryStepAPIConstants.stop:
        return StopDTO.fromJson(json);
      case ItineraryStepAPIConstants.hosting:
        return HostingDTO.fromJson(json);
      case ItineraryStepAPIConstants.travelSegment:
        return TravelSegmentDTO.fromJson(json);
      default:
        // Returns a placeholder and throw the rest of the data out
        return PlaceholderStepDTO.fromJson(json);
    }
  }

  /// To json method
  Map<String, dynamic> toJson();
  /// to domain mapper method
  ItineraryStep toDomain();
  /// From domain factory constructor
  factory ItineraryStepDTO.fromDomain({required ItineraryStep step}) {
    switch (step) {
      case PlaceholderStep _:
        return PlaceholderStepDTO.fromDomain(step: step);
      case Stop _:
        return StopDTO.fromDomain(stop: step);
      case Hosting _:
        return HostingDTO.fromDomain(hosting: step);
      case TravelSegment _:
        return TravelSegmentDTO.fromDomain(travelSegment: step);
      default:
        throw Exception('Unknown step type: ${step.runtimeType}');
    }


  }



}

/// Data transfer object for [PlaceholderStep], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [PlaceholderStep] and [PlaceholderStepDTO].
class PlaceholderStepDTO extends ItineraryStepDTO {
  /// Description for the placeholder
  final String description;

  PlaceholderStepDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.description,
  });

  factory PlaceholderStepDTO.fromJson(Map<String, dynamic> json) {
    return PlaceholderStepDTO(
      id: json[ItineraryStepAPIConstants.id],
      title: json[ItineraryStepAPIConstants.title],
      description: json[ItineraryStepAPIConstants.description],
      startDate: DateTime.parse(json[ItineraryStepAPIConstants.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepAPIConstants.finishDate]),
      finished: json[ItineraryStepAPIConstants.finished],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepAPIConstants.type: ItineraryStepAPIConstants.placeholder,
      ItineraryStepAPIConstants.id: id,
      ItineraryStepAPIConstants.title: title,
      ItineraryStepAPIConstants.startDate: startDate.toIso8601String(),
      ItineraryStepAPIConstants.finishDate: finishDate.toIso8601String(),
      ItineraryStepAPIConstants.finished: finished,
    };
  }

  /// To domain method
  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newPlaceholder(
        domainId: Uuid().v4(),
        backEndId: id,
        title: title,
        description: description,
        startDate: startDate,
        finishDate: finishDate
    );
  }

  /// From domain factory constructor
  factory PlaceholderStepDTO.fromDomain({required PlaceholderStep step}) {
    return PlaceholderStepDTO(
      id: step.backEndId,
      title: step.title,
      description: step.description,
      startDate: step.startDate,
      finishDate: step.finishDate,
      finished: step.finished,
    );
  }
}

/// Data transfer object for [Stop], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Stop] and [StopDTO].
class StopDTO extends ItineraryStepDTO {
  /// Name of the place
  final String name;
  /// Description of the place
  final String description;
  /// Experiences of the place
  final List<String> experiences;

  StopDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.description,
    required this.experiences,
  });

  /// From json factory constructor
  factory StopDTO.fromJson(Map<String, dynamic> json) {
    return StopDTO(
      id: json[ItineraryStepAPIConstants.id],
      title: json[ItineraryStepAPIConstants.title],
      startDate: DateTime.parse(json[ItineraryStepAPIConstants.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepAPIConstants.finishDate]),
      finished: json[ItineraryStepAPIConstants.finished],
      name: json[ItineraryStepAPIConstants.name],
      description: json[ItineraryStepAPIConstants.description],
      experiences: List<String>.from(json[ItineraryStepAPIConstants.experiences]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepAPIConstants.type: ItineraryStepAPIConstants.stop,
      ItineraryStepAPIConstants.id: id,
      ItineraryStepAPIConstants.title: title,
      ItineraryStepAPIConstants.startDate: startDate.toIso8601String(),
      ItineraryStepAPIConstants.finishDate: finishDate.toIso8601String(),
      ItineraryStepAPIConstants.finished: finished,
      ItineraryStepAPIConstants.name: name,
      ItineraryStepAPIConstants.description: description,
      ItineraryStepAPIConstants.experiences: experiences,
    };
  }

  /// To domain method
  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newStop(
        domainId: Uuid().v4(),
        backEndId: id,
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        name: name,
        description: description,
        experiences: experiences
    );
  }

  /// From domain factory constructor
  factory StopDTO.fromDomain({required Stop stop}) {
    return StopDTO(
      id: stop.backEndId,
      title: stop.title,
      startDate: stop.startDate,
      finishDate: stop.finishDate,
      finished: stop.finished,
      name: stop.name,
      description: stop.description,
      experiences: stop.experiences,
    );
  }

}

/// Data transfer object for [Hosting], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Hosting] and [HostingDTO].
class HostingDTO extends ItineraryStepDTO {
  final String name;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  HostingDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  });

  factory HostingDTO.fromJson(Map<String, dynamic> json) {
    return HostingDTO(
      id: json[ItineraryStepAPIConstants.id],
      title: json[ItineraryStepAPIConstants.title],
      startDate: DateTime.parse(json[ItineraryStepAPIConstants.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepAPIConstants.finishDate]),
      finished: json[ItineraryStepAPIConstants.finished],
      name: json[ItineraryStepAPIConstants.name],
      address: json[ItineraryStepAPIConstants.address],
      checkIn: DateTime.parse(json[ItineraryStepAPIConstants.checkIn]),
      checkOut: DateTime.parse(json[ItineraryStepAPIConstants.checkOut]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepAPIConstants.type: ItineraryStepAPIConstants.hosting,
      ItineraryStepAPIConstants.id: id,
      ItineraryStepAPIConstants.title: title,
      ItineraryStepAPIConstants.startDate: startDate.toIso8601String(),
      ItineraryStepAPIConstants.finishDate: finishDate.toIso8601String(),
      ItineraryStepAPIConstants.finished: finished,
      ItineraryStepAPIConstants.name: name,
      ItineraryStepAPIConstants.address: address,
      ItineraryStepAPIConstants.checkIn: checkIn.toIso8601String(),
      ItineraryStepAPIConstants.checkOut: checkOut.toIso8601String(),
    };
  }

  /// To domain method
  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newHosting(
      domainId: Uuid().v4(),
      backEndId: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      name: name,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  /// From domain factory constructor
  factory HostingDTO.fromDomain({required Hosting hosting}) {
    return HostingDTO(
      id: hosting.backEndId,
      title: hosting.title,
      startDate: hosting.startDate,
      finishDate: hosting.finishDate,
      finished: hosting.finished,
      name: hosting.name,
      address: hosting.address,
      checkIn: hosting.checkIn,
      checkOut: hosting.checkOut,
    );
  }

}

/// Data transfer object for [TravelSegment], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [TravelSegment] and [TravelSegmentDTO].
class TravelSegmentDTO extends ItineraryStepDTO {
  /// Id for the transport used in the segment
  final TransportDTO transport;
  /// Start point of the segment
  final String startPoint;
  /// Finish point of the segment
  final String finishPoint;

  TravelSegmentDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.transport,
    required this.startPoint,
    required this.finishPoint,
  });

  /// From json factory constructor
  factory TravelSegmentDTO.fromJson(Map<String, dynamic> json) {
    return TravelSegmentDTO(
      id: json[ItineraryStepAPIConstants.id],
      title: json[ItineraryStepAPIConstants.title],
      startDate: DateTime.parse(json[ItineraryStepAPIConstants.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepAPIConstants.finishDate]),
      finished: json[ItineraryStepAPIConstants.finished],
      transport: TransportDTO.fromJson(json[ItineraryStepAPIConstants.transport]),
      startPoint: json[ItineraryStepAPIConstants.startPoint],
      finishPoint: json[ItineraryStepAPIConstants.finishPoint],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepAPIConstants.type: ItineraryStepAPIConstants.travelSegment,
      ItineraryStepAPIConstants.id: id,
      ItineraryStepAPIConstants.title: title,
      ItineraryStepAPIConstants.startDate: startDate.toIso8601String(),
      ItineraryStepAPIConstants.finishDate: finishDate.toIso8601String(),
      ItineraryStepAPIConstants.finished: finished,
      ItineraryStepAPIConstants.transport: transport.toJson(),
      ItineraryStepAPIConstants.startPoint: startPoint,
      ItineraryStepAPIConstants.finishPoint: finishPoint,
    };
  }

  /// To domain mapper method
  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newTravelSegment(
      domainId: Uuid().v4(),
      backEndId: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      transport: transport.toDomain(),
      startPoint: startPoint,
      finishPoint: finishPoint,
    );
  }

  /// From domain factory constructor
  factory TravelSegmentDTO.fromDomain({required TravelSegment travelSegment}) {
    return TravelSegmentDTO(
      id: travelSegment.backEndId,
      title: travelSegment.title,
      startDate: travelSegment.startDate,
      finishDate: travelSegment.finishDate,
      finished: travelSegment.finished,
      transport: TransportDTO.fromDomain(transport: travelSegment.transport),
      startPoint: travelSegment.startPoint,
      finishPoint: travelSegment.finishPoint,
    );
  }
}

/// Contains the constants field names from the API
class ItineraryStepAPIConstants{
  /// Main id field
  static const String id = 'id';
  /// Step title field
  static const String title = 'title';
  /// Start date for the step field
  static const String startDate = 'startDate';
  /// Finish date for the step field
  static const String finishDate = 'finishDate';
  /// Bool for the step finished field
  static const String finished = 'finished';
  /// Type field
  static const String type = 'type';
  /// Placeholder type
  static const String placeholder = 'placeholder';
  /// Stop type
  static const String stop = 'stop';
  /// Hosting type
  static const String hosting = 'hosting';
  /// Travel segment type
  static const String travelSegment = 'travel_segment';
  /// Location field
  static const String location = 'location';
  /// Is start field
  static const String isStart = 'isStart';
  /// Name field
  static const String name = 'name';
  /// Description field
  static const String description = 'description';
  /// Experiences field
  static const String experiences = 'experiences';
  /// Address field
  static const String address = 'address';
  /// Check in field
  static const String checkIn = 'checkIn';
  /// Check out field
  static const String checkOut = 'checkOut';
  /// Transport Id field
  static const String transport = 'transportId';
  /// Start point field
  static const String startPoint = 'startPoint';
  /// Finish point field
  static const String finishPoint = 'finishPoint';

}