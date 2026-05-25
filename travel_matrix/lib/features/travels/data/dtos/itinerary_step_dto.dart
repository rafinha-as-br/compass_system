import 'package:travel_matrix/features/travels/data/dtos/transport_dto.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/itinerary_step.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

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
    final type = json[ItineraryStepApiFields.type];
    switch (type) {
      case ItineraryStepApiValues.placeholder:
        return PlaceholderStepDTO.fromJson(json);
      case ItineraryStepApiValues.stop:
        return StopDTO.fromJson(json);
      case ItineraryStepApiValues.hosting:
        return HostingDTO.fromJson(json);
      case ItineraryStepApiValues.travelSegment:
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
      id: json[ItineraryStepApiFields.id],
      title: json[ItineraryStepApiFields.title],
      description: json[ItineraryStepApiFields.description],
      startDate: DateTime.parse(json[ItineraryStepApiFields.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepApiFields.finishDate]),
      finished: json[ItineraryStepApiFields.finished],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepApiFields.type: ItineraryStepApiValues.placeholder,
      ItineraryStepApiFields.id: id,
      ItineraryStepApiFields.title: title,
      ItineraryStepApiFields.startDate: startDate.toIso8601String(),
      ItineraryStepApiFields.finishDate: finishDate.toIso8601String(),
      ItineraryStepApiFields.finished: finished,
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
      id: json[ItineraryStepApiFields.id],
      title: json[ItineraryStepApiFields.title],
      startDate: DateTime.parse(json[ItineraryStepApiFields.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepApiFields.finishDate]),
      finished: json[ItineraryStepApiFields.finished],
      name: json[ItineraryStepApiFields.name],
      description: json[ItineraryStepApiFields.description],
      experiences: List<String>.from(json[ItineraryStepApiFields.experiences]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepApiFields.type: ItineraryStepApiValues.stop,
      ItineraryStepApiFields.id: id,
      ItineraryStepApiFields.title: title,
      ItineraryStepApiFields.startDate: startDate.toIso8601String(),
      ItineraryStepApiFields.finishDate: finishDate.toIso8601String(),
      ItineraryStepApiFields.finished: finished,
      ItineraryStepApiFields.name: name,
      ItineraryStepApiFields.description: description,
      ItineraryStepApiFields.experiences: experiences,
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
      id: json[ItineraryStepApiFields.id],
      title: json[ItineraryStepApiFields.title],
      startDate: DateTime.parse(json[ItineraryStepApiFields.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepApiFields.finishDate]),
      finished: json[ItineraryStepApiFields.finished],
      name: json[ItineraryStepApiFields.name],
      address: json[ItineraryStepApiFields.address],
      checkIn: DateTime.parse(json[ItineraryStepApiFields.checkIn]),
      checkOut: DateTime.parse(json[ItineraryStepApiFields.checkOut]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepApiFields.type: ItineraryStepApiValues.hosting,
      ItineraryStepApiFields.id: id,
      ItineraryStepApiFields.title: title,
      ItineraryStepApiFields.startDate: startDate.toIso8601String(),
      ItineraryStepApiFields.finishDate: finishDate.toIso8601String(),
      ItineraryStepApiFields.finished: finished,
      ItineraryStepApiFields.name: name,
      ItineraryStepApiFields.address: address,
      ItineraryStepApiFields.checkIn: checkIn.toIso8601String(),
      ItineraryStepApiFields.checkOut: checkOut.toIso8601String(),
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
      id: json[ItineraryStepApiFields.id],
      title: json[ItineraryStepApiFields.title],
      startDate: DateTime.parse(json[ItineraryStepApiFields.startDate]),
      finishDate: DateTime.parse(json[ItineraryStepApiFields.finishDate]),
      finished: json[ItineraryStepApiFields.finished],
      transport: TransportDTO.fromJson(json[ItineraryStepApiFields.transport]),
      startPoint: json[ItineraryStepApiFields.startPoint],
      finishPoint: json[ItineraryStepApiFields.finishPoint],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ItineraryStepApiFields.type: ItineraryStepApiValues.travelSegment,
      ItineraryStepApiFields.id: id,
      ItineraryStepApiFields.title: title,
      ItineraryStepApiFields.startDate: startDate.toIso8601String(),
      ItineraryStepApiFields.finishDate: finishDate.toIso8601String(),
      ItineraryStepApiFields.finished: finished,
      ItineraryStepApiFields.transport: transport.toJson(),
      ItineraryStepApiFields.startPoint: startPoint,
      ItineraryStepApiFields.finishPoint: finishPoint,
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

