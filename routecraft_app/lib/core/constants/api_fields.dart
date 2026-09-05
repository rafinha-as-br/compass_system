// Centralizes API field names and fixed values used across the travels
// DTOs — mirrors travel_matrix/lib/core/constants/api_fields.dart, trimmed
// to what RouteCraft's client-facing contract actually needs.

abstract final class CommonApiFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String type = 'type';
  static const String startDate = 'startDate';
  static const String finishDate = 'finishDate';
}

abstract final class TravelApiFields {
  static const String id = CommonApiFields.id;
  static const String clientName = 'clientName';
  static const String travelName = 'travelName';
  static const String travelStatus = 'travelStatus';
  static const String routePlan = 'routePlan';
  static const String itinerary = 'itinerary';
  static const String participants = 'participants';
}

abstract final class PersonApiFields {
  static const String id = CommonApiFields.id;
  static const String name = CommonApiFields.name;
  static const String age = 'age';
  static const String sex = 'sex';
}

abstract final class RoutePlanApiFields {
  static const String id = CommonApiFields.id;
  static const String startDate = CommonApiFields.startDate;
  static const String finishDate = CommonApiFields.finishDate;
  static const String startLocation = 'startLocation';
  static const String destination = 'destination';
  static const String interestPoints = 'interestPoints';
}

abstract final class InterestPointApiFields {
  static const String id = CommonApiFields.id;
  static const String name = CommonApiFields.name;
  static const String description = CommonApiFields.description;
}

abstract final class ItineraryApiFields {
  static const String id = CommonApiFields.id;
  static const String agentName = 'agentName';
  static const String steps = 'steps';
}

abstract final class ItineraryStepApiFields {
  static const String id = CommonApiFields.id;
  static const String type = CommonApiFields.type;
  static const String title = 'title';
  static const String startDate = CommonApiFields.startDate;
  static const String finishDate = CommonApiFields.finishDate;
  static const String finished = 'finished';
  static const String name = CommonApiFields.name;
  static const String description = CommonApiFields.description;
  static const String experiences = 'experiences';
  static const String address = 'address';
  static const String checkIn = 'checkIn';
  static const String checkOut = 'checkOut';
  static const String transport = 'transport';
  static const String startPoint = 'startPoint';
  static const String finishPoint = 'finishPoint';
}

abstract final class ItineraryStepApiValues {
  static const String placeholder = 'placeholder';
  static const String stop = 'stop';
  static const String hosting = 'hosting';
  static const String travelSegment = 'travel_segment';
}

abstract final class TransportApiFields {
  static const String id = CommonApiFields.id;
  static const String type = CommonApiFields.type;
  static const String description = CommonApiFields.description;

  /// Rental car
  static const String vehicleModelName = 'vehicleModelName';
  static const String vehicleLicensePlate = 'vehicleLicensePlate';
  static const String companyName = 'companyName';
  static const String checkInDate = 'checkInDate';
  static const String checkOutDate = 'checkOutDate';

  /// Bus
  static const String travelNumber = 'travelNumber';
  static const String travelCompany = 'travelCompany';
  static const String departureGate = 'departureGate';
  static const String departureDateTime = 'departureDateTime';
  static const String busStationName = 'busStationName';
  static const String details = 'details';

  /// Airplane
  static const String flightNumber = 'flightNumber';
  static const String flightDate = 'flightDate';
  static const String departureAirport = 'departureAirport';
  static const String arrivalAirport = 'arrivalAirport';
}

abstract final class TransportApiValues {
  static const String placeholder = 'placeholder';
  static const String rentalCar = 'rental_car';
  static const String bus = 'bus';
  static const String airplane = 'airplane';
}
