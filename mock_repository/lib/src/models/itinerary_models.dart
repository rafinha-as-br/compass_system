class ItineraryStop {
  final String id;
  final String itineraryId;
  final String location;
  final String description;
  final String reservationInformation;
  
  // Custom boolean to track progress
  bool isCompleted;

  ItineraryStop({
    required this.id,
    required this.itineraryId,
    required this.location,
    required this.description,
    required this.reservationInformation,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itineraryId': itineraryId,
      'location': location,
      'description': description,
      'reservationInformation': reservationInformation,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}

class Itinerary {
  final String id;
  final String routeId;
  final String createdByAgent;
  final List<ItineraryStop> listOfStops;

  Itinerary({
    required this.id,
    required this.routeId,
    required this.createdByAgent,
    this.listOfStops = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'createdByAgent': createdByAgent,
      'listOfStops': listOfStops.map((s) => s.toMap()).toList(),
    };
  }
}
