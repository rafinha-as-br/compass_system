
import 'transport.dart';

abstract class ItineraryStep {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  bool finished;

  ItineraryStep({
    required this.id,
    required this.title,
    required this.startDate,
    required this.finishDate,
    this.finished = false
  });

  Map<String, dynamic> toJson();
}


class PlaceholderStep extends ItineraryStep {
  PlaceholderStep({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'type': 'PlaceholderStep',
    };
  }
}

class BoundaryStep extends ItineraryStep {
  final String location;
  final bool isStart;

  BoundaryStep({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required this.location,
    this.isStart = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'location': location,
      'isStart': isStart,
      'type': 'BoundaryStep',
    };
  }
}

class Stop extends ItineraryStep {
  final String name;
  final String description;
  final List<String> experiences;

  Stop({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    super.finished,
    required this.name,
    required this.description,
    required this.experiences,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

class Hosting extends ItineraryStep {
  final String name;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  Hosting({
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

class TravelSegment extends ItineraryStep {
  final String travelSegmentId;
  final Transport transport;
  final String startPoint;
  final String finishPoint;

  TravelSegment({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    super.finished,
    required this.travelSegmentId,
    required this.transport,
    required this.startPoint,
    required this.finishPoint,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'finished': finished,
      'travelSegmentId': travelSegmentId,
      'transport': transport.toJson(),
      'startPoint': startPoint,
      'finishPoint': finishPoint,
      'type': 'TravelSegment',
    };
  }
}