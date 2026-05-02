
import '../../domain/entities/transport.dart';

abstract class TransportDTO {
  final String id;

  TransportDTO({required this.id});

  factory TransportDTO.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'rental_car':
        return RentalCarDTO.fromJson(json);
      case 'bus':
        return BusDTO.fromJson(json);
      case 'airplane':
        return AirplaneDTO.fromJson(json);
      default:
        throw Exception('Unknown transport type: $type');
    }
  }

  Map<String, dynamic> toJson();

  Transport toDomain();

}

class RentalCarDTO extends TransportDTO {
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCarDTO({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  });

  factory RentalCarDTO.fromJson(Map<String, dynamic> json) {
    return RentalCarDTO(
      id: json['id'],
      vehicleModelName: json['vehicleModelName'],
      vehicleLicensePlate: json['vehicleLicensePlate'],
      companyName: json['companyName'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rental_car',
      'id': id,
      'vehicleModelName': vehicleModelName,
      'vehicleLicensePlate': vehicleLicensePlate,
      'companyName': companyName,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
    };
  }

  @override
  RentalCar toDomain() {
    return RentalCar(
      id: id,
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

  BusDTO({
    required super.id,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  });

  factory BusDTO.fromJson(Map<String, dynamic> json) {
    return BusDTO(
      id: json['id'],
      travelNumber: json['travelNumber'],
      travelCompany: json['travelCompany'],
      departureGate: json['departureGate'],
      departureDateTime: DateTime.parse(json['departureDateTime']),
      busStationName: json['busStationName'],
      description: json['description'],
      details: json['details'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'bus',
      'id': id,
      'travelNumber': travelNumber,
      'travelCompany': travelCompany,
      'departureGate': departureGate,
      'departureDateTime': departureDateTime.toIso8601String(),
      'busStationName': busStationName,
      'description': description,
      'details': details,
    };
  }

  @override
  Bus toDomain() {
    return Bus(
      id: id,
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

  AirplaneDTO({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  factory AirplaneDTO.fromJson(Map<String, dynamic> json) {
    return AirplaneDTO(
      id: json['id'],
      flightNumber: json['flightNumber'],
      flightCompany: json['flightCompany'],
      flightDate: DateTime.parse(json['flightDate']),
      departureGate: json['departureGate'],
      departureAirport: json['departureAirport'],
      arrivalAirport: json['arrivalAirport'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'airplane',
      'id': id,
      'flightNumber': flightNumber,
      'flightCompany': flightCompany,
      'flightDate': flightDate.toIso8601String(),
      'departureGate': departureGate,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
    };
  }

  @override
  Airplane toDomain() {
    return Airplane(
      id: id,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }
}