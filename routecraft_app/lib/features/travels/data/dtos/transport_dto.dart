import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';

abstract class TransportDTO {
  final String? id;

  TransportDTO._({required this.id});

  factory TransportDTO.fromJson(Map<String, dynamic> json) {
    final type = json[TransportApiFields.type];
    switch (type) {
      case TransportApiValues.rentalCar:
        return RentalCarDTO.fromJson(json);
      case TransportApiValues.bus:
        return BusDTO.fromJson(json);
      case TransportApiValues.airplane:
        return AirplaneDTO.fromJson(json);
      case TransportApiValues.placeholder:
      default:
        // Unknown/placeholder types degrade to a placeholder rather than
        // throwing — the client never writes this field, only reads it.
        return PlaceholderTransportDTO.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  Transport toDomain();
}

class PlaceholderTransportDTO extends TransportDTO {
  final String description;

  PlaceholderTransportDTO._({required super.id, required this.description}) : super._();

  factory PlaceholderTransportDTO.fromJson(Map<String, dynamic> json) {
    return PlaceholderTransportDTO._(
      id: json[TransportApiFields.id]?.toString(),
      description: json[TransportApiFields.description]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        TransportApiFields.type: TransportApiValues.placeholder,
        TransportApiFields.id: id,
        TransportApiFields.description: description,
      };

  @override
  Transport toDomain() {
    return Transport.newPlaceholder(domainId: const Uuid().v4(), backEndId: id, description: description);
  }
}

class RentalCarDTO extends TransportDTO {
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCarDTO._({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super._();

  factory RentalCarDTO.fromJson(Map<String, dynamic> json) {
    return RentalCarDTO._(
      id: json[TransportApiFields.id]?.toString(),
      vehicleModelName: json[TransportApiFields.vehicleModelName]?.toString() ?? '',
      vehicleLicensePlate: json[TransportApiFields.vehicleLicensePlate]?.toString() ?? '',
      companyName: json[TransportApiFields.companyName]?.toString() ?? '',
      checkInDate: _parseDate(json[TransportApiFields.checkInDate]),
      checkOutDate: _parseDate(json[TransportApiFields.checkOutDate]),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        TransportApiFields.type: TransportApiValues.rentalCar,
        TransportApiFields.id: id,
        TransportApiFields.vehicleModelName: vehicleModelName,
        TransportApiFields.vehicleLicensePlate: vehicleLicensePlate,
        TransportApiFields.companyName: companyName,
        TransportApiFields.checkInDate: checkInDate.toIso8601String(),
        TransportApiFields.checkOutDate: checkOutDate.toIso8601String(),
      };

  @override
  Transport toDomain() {
    return Transport.newRentalCar(
      domainId: const Uuid().v4(),
      backEndId: id,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
    );
  }
}

class BusDTO extends TransportDTO {
  final String travelNumber;
  final String travelCompany;
  final String departureGate;
  final DateTime departureDateTime;
  final String busStationName;
  final String description;
  final String? details;

  BusDTO._({
    required super.id,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  }) : super._();

  factory BusDTO.fromJson(Map<String, dynamic> json) {
    return BusDTO._(
      id: json[TransportApiFields.id]?.toString(),
      travelNumber: json[TransportApiFields.travelNumber]?.toString() ?? '',
      travelCompany: json[TransportApiFields.travelCompany]?.toString() ?? '',
      departureGate: json[TransportApiFields.departureGate]?.toString() ?? '',
      departureDateTime: _parseDate(json[TransportApiFields.departureDateTime]),
      busStationName: json[TransportApiFields.busStationName]?.toString() ?? '',
      description: json[TransportApiFields.description]?.toString() ?? '',
      details: json[TransportApiFields.details]?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        TransportApiFields.type: TransportApiValues.bus,
        TransportApiFields.id: id,
        TransportApiFields.travelNumber: travelNumber,
        TransportApiFields.travelCompany: travelCompany,
        TransportApiFields.departureGate: departureGate,
        TransportApiFields.departureDateTime: departureDateTime.toIso8601String(),
        TransportApiFields.busStationName: busStationName,
        TransportApiFields.description: description,
        TransportApiFields.details: details,
      };

  @override
  Transport toDomain() {
    return Transport.newBus(
      domainId: const Uuid().v4(),
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
}

class AirplaneDTO extends TransportDTO {
  final String flightNumber;
  final String flightCompany;
  final DateTime flightDate;
  final String departureGate;
  final String departureAirport;
  final String arrivalAirport;

  AirplaneDTO._({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }) : super._();

  factory AirplaneDTO.fromJson(Map<String, dynamic> json) {
    return AirplaneDTO._(
      id: json[TransportApiFields.id]?.toString(),
      flightNumber: json[TransportApiFields.flightNumber]?.toString() ?? '',
      flightCompany: json[TransportApiFields.companyName]?.toString() ?? '',
      flightDate: _parseDate(json[TransportApiFields.flightDate]),
      departureGate: json[TransportApiFields.departureGate]?.toString() ?? '',
      departureAirport: json[TransportApiFields.departureAirport]?.toString() ?? '',
      arrivalAirport: json[TransportApiFields.arrivalAirport]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        TransportApiFields.type: TransportApiValues.airplane,
        TransportApiFields.id: id,
        TransportApiFields.flightNumber: flightNumber,
        TransportApiFields.companyName: flightCompany,
        TransportApiFields.flightDate: flightDate.toIso8601String(),
        TransportApiFields.departureGate: departureGate,
        TransportApiFields.departureAirport: departureAirport,
        TransportApiFields.arrivalAirport: arrivalAirport,
      };

  @override
  Transport toDomain() {
    return Transport.newAirplane(
      domainId: const Uuid().v4(),
      backEndId: id,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }
}

DateTime _parseDate(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
