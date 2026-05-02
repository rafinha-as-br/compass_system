
import '../../domain/entities/itinerary_step.dart';
import '../../domain/entities/transport.dart';

abstract class ItineraryStepDTO {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  bool finished;

  ItineraryStepDTO({
    required this.id,
    required this.title,
    required this.startDate,
    required this.finishDate,
    this.finished = false
  });

  factory ItineraryStepDTO.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'placeholder':
        return PlaceholderStepDTO.fromJson(json);
      case 'boundary':
        return BoundaryStepDTO.fromJson(json);
      case 'stop':
        return StopDTO.fromJson(json);
      case 'hosting':
        return HostingDTO.fromJson(json);
      case 'travel_segment':
        return TravelSegmentDTO.fromJson(json);
      default:
        throw Exception('Unknown itinerary step type: $type');
    }
  }

  Map<String, dynamic> toJson();

  ItineraryStep toDomain({Transport? transport});

}

class PlaceholderStepDTO extends ItineraryStepDTO {
  PlaceholderStepDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
  });

  factory PlaceholderStepDTO.fromJson(Map<String, dynamic> json) {
    return PlaceholderStepDTO(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'placeholder',
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
    };
  }

  @override
  PlaceholderStep toDomain({Transport? transport}) {
    return PlaceholderStep(
      id: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
    );
  }
}

class BoundaryStepDTO extends ItineraryStepDTO {
  final String location;
  final bool isStart;

  BoundaryStepDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required this.location,
    this.isStart = true,
  });

  factory BoundaryStepDTO.fromJson(Map<String, dynamic> json) {
    return BoundaryStepDTO(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      location: json['location'],
      isStart: json['isStart'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'boundary',
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'location': location,
      'isStart': isStart,
    };
  }

  @override
  BoundaryStep toDomain({Transport? transport}) {
    return BoundaryStep(
      id: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      location: location,
      isStart: isStart,
    );
  }
}

class StopDTO extends ItineraryStepDTO {
  final String name;
  final String description;
  final List<String> experiences;

  StopDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    super.finished,
    required this.name,
    required this.description,
    required this.experiences,
  });

  factory StopDTO.fromJson(Map<String, dynamic> json) {
    return StopDTO(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      finished: json['finished'] ?? false,
      name: json['name'],
      description: json['description'],
      experiences: List<String>.from(json['experiences']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'stop',
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'name': name,
      'description': description,
      'experiences': experiences,
    };
  }

  @override
  Stop toDomain({Transport? transport}) {
    return Stop(
      id: id,
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

  HostingDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    super.finished,
    required this.name,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  });

  factory HostingDTO.fromJson(Map<String, dynamic> json) {
    return HostingDTO(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      finished: json['finished'] ?? false,
      name: json['name'],
      address: json['address'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'hosting',
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'name': name,
      'address': address,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
    };
  }

  @override
  Hosting toDomain({Transport? transport}) {
    return Hosting(
      id: id,
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
  final String travelSegmentId;
  final String transportId;
  final String startPoint;
  final String finishPoint;

  TravelSegmentDTO({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    super.finished,
    required this.travelSegmentId,
    required this.transportId,
    required this.startPoint,
    required this.finishPoint,
  });

  factory TravelSegmentDTO.fromJson(Map<String, dynamic> json) {
    return TravelSegmentDTO(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      finished: json['finished'] ?? false,
      travelSegmentId: json['travelSegmentId'],
      transportId: json['transportId'],
      startPoint: json['startPoint'],
      finishPoint: json['finishPoint'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'travel_segment',
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'travelSegmentId': travelSegmentId,
      'transportId': transportId,
      'startPoint': startPoint,
      'finishPoint': finishPoint,
    };
  }

  @override
  TravelSegment toDomain({Transport? transport}) {
    if (transport == null) {
      throw Exception('Transport is required for TravelSegmentDTO.toDomain');
    }
    return TravelSegment(
      id: id,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      finished: finished,
      travelSegmentId: travelSegmentId,
      transport: transport,
      startPoint: startPoint,
      finishPoint: finishPoint,
    );
  }
}