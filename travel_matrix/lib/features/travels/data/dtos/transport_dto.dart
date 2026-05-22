import 'package:uuid/uuid.dart';

import '../../domain/entities/transport.dart';

/// Data transfer object for [Transport], having the same structure as the API.
abstract class TransportDTO {
  /// Main id used for API reference
  final String? id;

  TransportDTO._({required this.id});

  /// Factory constructor to create a Transport DTO type from JSON
  factory TransportDTO.fromJson(Map<String, dynamic> json) {
    final type = json[TransportAPIConstants.type];
    switch (type) {
      case TransportAPIConstants.placeholder:
        return PlaceHolderStepDTO.fromJson(json);
      case TransportAPIConstants.rentalCar:
        return RentalCarDTO.fromJson(json);
      case TransportAPIConstants.bus:
        return BusDTO.fromJson(json);
      case TransportAPIConstants.airplane:
        return AirplaneDTO.fromJson(json);
      default:
        /// Return a placeholder and throw the rest of the data out
        return PlaceHolderStepDTO.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

}

/// Data transfer object for [PlaceholderTransport], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [PlaceholderTransport] and [PlaceHolderStepDTO].
class PlaceHolderStepDTO extends TransportDTO {
  PlaceHolderStepDTO._({required super.id}): super._();

  /// from Json factory constructor
  factory PlaceHolderStepDTO.fromJson(Map<String, dynamic> json) {
    return PlaceHolderStepDTO._(id: json[TransportAPIConstants.id]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportAPIConstants.type: 'placeholder',
      TransportAPIConstants.id: id,
    };
  }

  /// To domain mapper method
  Transport toDomain() {
    return Transport.newPlaceholder(
        domainId: Uuid().v4(),
        backEndId: id
    );
  }

  /// From domain factory constructor
  factory PlaceHolderStepDTO.fromDomain({required PlaceholderTransport placeholder}) {
    return PlaceHolderStepDTO._(id: placeholder.backEndId);
  }


}

/// Data transfer object for [RentalCar], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [RentalCar] and [RentalCarDTO].
class RentalCarDTO extends TransportDTO {
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

  RentalCarDTO._({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  }): super._();

  /// from Json factory constructor
  factory RentalCarDTO.fromJson(Map<String, dynamic> json) {
    return RentalCarDTO._(
      id: json[TransportAPIConstants.type],
      vehicleModelName: json[TransportAPIConstants.vehicleModelName],
      vehicleLicensePlate: json[TransportAPIConstants.vehicleLicensePlate],
      companyName: json[TransportAPIConstants.companyName],
      checkInDate: DateTime.parse(json[TransportAPIConstants.checkInDate]),
      checkOutDate: DateTime.parse(json[TransportAPIConstants.checkOutDate]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportAPIConstants.type: TransportAPIConstants.rentalCar,
      TransportAPIConstants.id: id,
      TransportAPIConstants.vehicleModelName: vehicleModelName,
      TransportAPIConstants.vehicleLicensePlate: vehicleLicensePlate,
      TransportAPIConstants.companyName: companyName,
      TransportAPIConstants.checkInDate: checkInDate.toIso8601String(),
      TransportAPIConstants.checkOutDate: checkOutDate.toIso8601String(),
    };
  }

  /// To domain mapper method
  Transport toDomain() {
    return Transport.newRentalCar(
      domainId: Uuid().v4(),
      backEndId: id,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate
    );
  }

  /// From domain factory constructor
  factory RentalCarDTO.fromDomain({required RentalCar rentalCar}) {
    return RentalCarDTO._(
      id: rentalCar.backEndId,
      vehicleModelName: rentalCar.vehicleModelName,
      vehicleLicensePlate: rentalCar.vehicleLicensePlate,
      companyName: rentalCar.companyName,
      checkInDate: rentalCar.checkInDate,
      checkOutDate: rentalCar.checkOutDate,
    );
  }

}

/// Data transfer object for [Bus], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Bus] and [BusDTO].
class BusDTO extends TransportDTO {
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

  BusDTO({
    required super.id,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  }): super._();

  /// from Json factory constructor
  factory BusDTO.fromJson(Map<String, dynamic> json) {
    return BusDTO(
      id: json[TransportAPIConstants.id],
      travelNumber: json[TransportAPIConstants.travelNumber],
      travelCompany: json[TransportAPIConstants.travelCompany],
      departureGate: json[TransportAPIConstants.departureGate],
      departureDateTime: DateTime.parse(json[TransportAPIConstants.departureDateTime]),
      busStationName: json[TransportAPIConstants.busStationName],
      description: json[TransportAPIConstants.description],
      details: json[TransportAPIConstants.details],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportAPIConstants.type: TransportAPIConstants.bus,
      TransportAPIConstants.id: id,
      TransportAPIConstants.travelNumber: travelNumber,
      TransportAPIConstants.travelCompany: travelCompany,
      TransportAPIConstants.departureGate: departureGate,
      TransportAPIConstants.departureDateTime: departureDateTime.toIso8601String(),
      TransportAPIConstants.busStationName: busStationName,
      TransportAPIConstants.description: description,
      TransportAPIConstants.details: details,
    };
  }

  /// To domain mapper method
  Transport toDomain() {
    return Transport.newBus(
      domainId: Uuid().v4(),
      backEndId: id,
      travelNumber: travelNumber,
      travelCompany: travelCompany,
      departureGate: departureGate,
      departureDateTime: departureDateTime,
      busStationName: busStationName,
      description: description,
      details: details,
    );
  }

  /// From domain factory constructor
  factory BusDTO.fromDomain({required Bus bus}) {
    return BusDTO(
      id: bus.backEndId,
      travelNumber: bus.travelNumber,
      travelCompany: bus.travelCompany,
      departureGate: bus.departureGate,
      departureDateTime: bus.departureDateTime,
      busStationName: bus.busStationName,
      description: bus.description,
      details: bus.details,
    );
  }


}

/// Data transfer object for [Airplane], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Airplane] and [AirplaneDTO].
class AirplaneDTO extends TransportDTO {
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

  AirplaneDTO({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }): super._();

  factory AirplaneDTO.fromJson(Map<String, dynamic> json) {
    return AirplaneDTO(
      id: json[TransportAPIConstants.id],
      flightNumber: json[TransportAPIConstants.flightNumber],
      flightCompany: json[TransportAPIConstants.flightCompany],
      flightDate: DateTime.parse(json[TransportAPIConstants.flightDate]),
      departureGate: json[TransportAPIConstants.departureGate],
      departureAirport: json[TransportAPIConstants.departureAirport],
      arrivalAirport: json[TransportAPIConstants.arrivalAirport],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportAPIConstants.type: TransportAPIConstants.airplane,
      TransportAPIConstants.id: id,
      TransportAPIConstants.flightNumber: flightNumber,
      TransportAPIConstants.companyName: flightCompany,
      TransportAPIConstants.flightDate: flightDate.toIso8601String(),
      TransportAPIConstants.departureGate: departureGate,
      TransportAPIConstants.departureAirport: departureAirport,
      TransportAPIConstants.arrivalAirport: arrivalAirport,
    };
  }

  /// To domain mapper method
  Transport toDomain() {
    return Transport.newAirplane(
      domainId: Uuid().v4(),
      backEndId: id,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }

  /// From domain factory constructor
  factory AirplaneDTO.fromDomain({required Airplane airplane}) {
    return AirplaneDTO(
      id: airplane.backEndId,
      flightNumber: airplane.flightNumber,
      flightCompany: airplane.flightCompany,
      flightDate: airplane.flightDate,
      departureGate: airplane.departureGate,
      departureAirport: airplane.departureAirport,
      arrivalAirport: airplane.arrivalAirport,
    );
  }

}

/// Contains the constants field names from the API
class TransportAPIConstants {
  static const String type = 'type';
  static const String rentalCar = 'rental_car';
  static const String bus = 'bus';
  static const String airplane = 'airplane';
  static const String id = 'id';
  static const String vehicleModelName = 'vehicleModelName';
  static const String vehicleLicensePlate = 'vehicleLicensePlate';
  static const String companyName = 'companyName';
  static const String checkInDate = 'checkInDate';
  static const String checkOutDate = 'checkOutDate';
  static const String travelNumber = 'travelNumber';
  static const String travelCompany = 'travelCompany';
  static const String departureGate = 'departureGate';
  static const String departureDateTime = 'departureDateTime';
  static const String busStationName = 'busStationName';
  static const String description = 'description';
  static const String details = 'details';
  static const String flightNumber = 'flightNumber';
  static const String flightCompany = 'flightCompany';
  static const String flightDate = 'flightDate';
  static const String departureAirport = 'departureAirport';
  static const String arrivalAirport = 'arrivalAirport';
  static const String placeholder = 'placeholder';
}
