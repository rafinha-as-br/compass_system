
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';

/// Represents a way of commuting in a [TravelSegment]
abstract class Transport {
  /// Main id used for local reference
  final String domainId;
  /// Main id used for API reference
  final String? backEndId;
  /// Private constructor
  Transport._({
    required this.domainId,
    required this.backEndId,
  });

  /// Creates a new [PlaceholderTransport] for an [Transport].
  ///
  /// Factory constructor to create a new domain entity from view model entity
  factory Transport.newPlaceholder({
    required String domainId,
    required String? backEndId,
  }) {
    return PlaceholderTransport._(
      domainId: domainId,
      backEndId: backEndId,
    );
  }

  /// Creates a new [RentalCar] for an [Transport].
  ///
  /// Factory constructor to create a new domain entity from view model entity
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

  /// Creates a new [Bus] for an [Transport].
  ///
  /// Factory constructor to create a new domain entity from view model entity
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
    return Bus(
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

  /// Creates a new [Airplane] for an [Transport].
  ///
  /// Factory constructor to create a new domain entity from view model entity
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
    return Airplane(
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

/// Represents a transport without type
class PlaceholderTransport extends Transport {
  /// Private constructor
  PlaceholderTransport._({
    required super.domainId,
    required super.backEndId,
  }): super._();
}

/// Represents a rental car used on a [TravelSegment]
class RentalCar extends Transport {
  /// Vehicle model name used on the rental car
  final String vehicleModelName;
  /// Vehicle license plate used on the rental car
  final String vehicleLicensePlate;
  /// Company name used on the rental car
  final String companyName;
  /// Check in date for getting the car
  final DateTime checkInDate;
  /// Check out date to return the car
  final DateTime checkOutDate;

  /// private constructor
  RentalCar._({
    required super.domainId,
    required super.backEndId,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  }): super._();
}

/// Represents a bus used on a [TravelSegment]
class Bus extends Transport {
  /// Ticket number
  final String travelNumber;
  /// Company name
  final String travelCompany;
  /// Departure gate to get on the bus
  final String departureGate;
  /// Departure date and time
  final DateTime departureDateTime;
  /// Bus station name to get on the bus
  final String busStationName;
  /// Description of the bus travel
  final String description;
  /// Extra details if necessary
  final String? details;

  Bus({
    required super.domainId,
    required super.backEndId,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  }): super._();
}

/// Represents an airplane used on a [TravelSegment]
class Airplane extends Transport {
  /// Flight number
  final String flightNumber;
  /// Company name
  final String flightCompany;
  /// Flight date and time
  final DateTime flightDate;
  /// Departure gate to get on the airplane
  final String departureGate;
  /// Departure airport
  final String departureAirport;
  /// Arrival airport
  final String arrivalAirport;

  Airplane({
    required super.domainId,
    required super.backEndId,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }): super._();
}