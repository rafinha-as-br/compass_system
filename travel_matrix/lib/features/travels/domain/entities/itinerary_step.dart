
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
}


class PlaceholderStep extends ItineraryStep {
  PlaceholderStep({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
  });

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
}