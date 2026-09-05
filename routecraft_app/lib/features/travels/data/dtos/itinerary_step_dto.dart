import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'date_parsing.dart';
import 'transport_dto.dart';

abstract class ItineraryStepDTO {
  final String? id;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  final bool finished;

  ItineraryStepDTO._({
    required this.id,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.finished,
  });

  factory ItineraryStepDTO.fromJson(Map<String, dynamic> json) {
    final type = json[ItineraryStepApiFields.type];
    switch (type) {
      case ItineraryStepApiValues.stop:
        return StopDTO.fromJson(json);
      case ItineraryStepApiValues.hosting:
        return HostingDTO.fromJson(json);
      case ItineraryStepApiValues.travelSegment:
        return TravelSegmentDTO.fromJson(json);
      case ItineraryStepApiValues.placeholder:
      default:
        return PlaceholderStepDTO.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  ItineraryStep toDomain();
}

class PlaceholderStepDTO extends ItineraryStepDTO {
  final String description;

  PlaceholderStepDTO._({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.description,
  }) : super._();

  factory PlaceholderStepDTO.fromJson(Map<String, dynamic> json) {
    final startDate = parseIsoDate(json[ItineraryStepApiFields.startDate]);
    return PlaceholderStepDTO._(
      id: json[ItineraryStepApiFields.id]?.toString(),
      title: json[ItineraryStepApiFields.title]?.toString() ?? '',
      description: json[ItineraryStepApiFields.description]?.toString() ?? '',
      startDate: startDate,
      finishDate: parseIsoDate(json[ItineraryStepApiFields.finishDate], fallback: startDate),
      finished: json[ItineraryStepApiFields.finished] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ItineraryStepApiFields.type: ItineraryStepApiValues.placeholder,
        ItineraryStepApiFields.id: id,
        ItineraryStepApiFields.title: title,
        ItineraryStepApiFields.description: description,
        ItineraryStepApiFields.startDate: startDate.toIso8601String(),
        ItineraryStepApiFields.finishDate: finishDate.toIso8601String(),
        ItineraryStepApiFields.finished: finished,
      };

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newPlaceholder(
      domainId: const Uuid().v4(),
      backEndId: id,
      title: title,
      description: description,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
    );
  }
}

class StopDTO extends ItineraryStepDTO {
  final String name;
  final String description;
  final List<String> experiences;

  StopDTO._({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.description,
    required this.experiences,
  }) : super._();

  factory StopDTO.fromJson(Map<String, dynamic> json) {
    final startDate = parseIsoDate(json[ItineraryStepApiFields.startDate]);
    return StopDTO._(
      id: json[ItineraryStepApiFields.id]?.toString(),
      title: json[ItineraryStepApiFields.title]?.toString() ?? '',
      startDate: startDate,
      finishDate: parseIsoDate(json[ItineraryStepApiFields.finishDate], fallback: startDate),
      finished: json[ItineraryStepApiFields.finished] as bool? ?? false,
      name: json[ItineraryStepApiFields.name]?.toString() ?? '',
      description: json[ItineraryStepApiFields.description]?.toString() ?? '',
      experiences: List<String>.from(json[ItineraryStepApiFields.experiences] as List<dynamic>? ?? const []),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
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

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newStop(
      domainId: const Uuid().v4(),
      backEndId: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      name: name,
      description: description,
      experiences: experiences,
    );
  }
}

class HostingDTO extends ItineraryStepDTO {
  final String name;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  HostingDTO._({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.name,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  }) : super._();

  factory HostingDTO.fromJson(Map<String, dynamic> json) {
    final startDate = parseIsoDate(json[ItineraryStepApiFields.startDate]);
    return HostingDTO._(
      id: json[ItineraryStepApiFields.id]?.toString(),
      title: json[ItineraryStepApiFields.title]?.toString() ?? '',
      startDate: startDate,
      finishDate: parseIsoDate(json[ItineraryStepApiFields.finishDate], fallback: startDate),
      finished: json[ItineraryStepApiFields.finished] as bool? ?? false,
      name: json[ItineraryStepApiFields.name]?.toString() ?? '',
      address: json[ItineraryStepApiFields.address]?.toString() ?? '',
      checkIn: parseIsoDate(json[ItineraryStepApiFields.checkIn], fallback: startDate),
      checkOut: parseIsoDate(json[ItineraryStepApiFields.checkOut], fallback: startDate),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
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

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newHosting(
      domainId: const Uuid().v4(),
      backEndId: id,
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
}

class TravelSegmentDTO extends ItineraryStepDTO {
  final TransportDTO transport;
  final String startPoint;
  final String finishPoint;

  TravelSegmentDTO._({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.finished,
    required this.transport,
    required this.startPoint,
    required this.finishPoint,
  }) : super._();

  factory TravelSegmentDTO.fromJson(Map<String, dynamic> json) {
    final startDate = parseIsoDate(json[ItineraryStepApiFields.startDate]);
    return TravelSegmentDTO._(
      id: json[ItineraryStepApiFields.id]?.toString(),
      title: json[ItineraryStepApiFields.title]?.toString() ?? '',
      startDate: startDate,
      finishDate: parseIsoDate(json[ItineraryStepApiFields.finishDate], fallback: startDate),
      finished: json[ItineraryStepApiFields.finished] as bool? ?? false,
      transport: TransportDTO.fromJson(
        json[ItineraryStepApiFields.transport] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      startPoint: json[ItineraryStepApiFields.startPoint]?.toString() ?? '',
      finishPoint: json[ItineraryStepApiFields.finishPoint]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
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

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newTravelSegment(
      domainId: const Uuid().v4(),
      backEndId: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      transport: transport.toDomain(),
      startPoint: startPoint,
      finishPoint: finishPoint,
    );
  }
}

