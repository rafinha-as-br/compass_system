/// Represents the way of commuting used in a `TravelSegment` step. The
/// client only ever reads this — it's built by the agent in Travel Matrix.
abstract class Transport {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  Transport._({required this.domainId, required this.backEndId});

  factory Transport.newPlaceholder({
    required String domainId,
    required String? backEndId,
    required String description,
  }) {
    return PlaceholderTransport._(
      domainId: domainId,
      backEndId: backEndId,
      description: description,
    );
  }

  factory Transport.newRentalCar({
    required String domainId,
    required String? backEndId,
    required String vehicleModelName,
    required String vehicleLicensePlate,
    required String companyName,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) {
    return RentalCar._(
      domainId: domainId,
      backEndId: backEndId,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
    );
  }

  factory Transport.newBus({
    required String domainId,
    required String? backEndId,
    required String travelNumber,
    required String travelCompany,
    required String departureGate,
    required DateTime departureDateTime,
    required String busStationName,
    required String description,
    required String? details,
  }) {
    return Bus._(
      domainId: domainId,
      backEndId: backEndId,
      travelNumber: travelNumber,
      travelCompany: travelCompany,
      departureGate: departureGate,
      departureDateTime: departureDateTime,
      busStationName: busStationName,
      description: description,
      details: details,
    );
  }

  factory Transport.newAirplane({
    required String domainId,
    required String? backEndId,
    required String flightNumber,
    required String flightCompany,
    required DateTime flightDate,
    required String departureGate,
    required String departureAirport,
    required String arrivalAirport,
  }) {
    return Airplane._(
      domainId: domainId,
      backEndId: backEndId,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }
}

class PlaceholderTransport extends Transport {
  final String description;

  PlaceholderTransport._({
    required super.domainId,
    required super.backEndId,
    required this.description,
  }) : super._();
}

class RentalCar extends Transport {
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCar._({
    required super.domainId,
    required super.backEndId,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super._();
}

class Bus extends Transport {
  final String travelNumber;
  final String travelCompany;
  final String departureGate;
  final DateTime departureDateTime;
  final String busStationName;
  final String description;
  final String? details;

  Bus._({
    required super.domainId,
    required super.backEndId,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  }) : super._();
}

class Airplane extends Transport {
  final String flightNumber;
  final String flightCompany;
  final DateTime flightDate;
  final String departureGate;
  final String departureAirport;
  final String arrivalAirport;

  Airplane._({
    required super.domainId,
    required super.backEndId,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }) : super._();
}
