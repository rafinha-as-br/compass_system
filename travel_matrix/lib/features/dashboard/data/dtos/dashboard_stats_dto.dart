import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardStatsDto {
  final int totalTravels;
  final int completedItineraries;
  final int pendingItineraries;
  final int activeClients;
  final List<DashboardTravelSummaryDto> recentTravels;
  final List<DashboardClientSummaryDto> activeClientsList;

  const DashboardStatsDto({
    required this.totalTravels,
    required this.completedItineraries,
    required this.pendingItineraries,
    required this.activeClients,
    required this.recentTravels,
    required this.activeClientsList,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    return DashboardStatsDto(
      totalTravels: json['totalTravels'] as int? ?? 0,
      completedItineraries: json['completedItineraries'] as int? ?? 0,
      pendingItineraries: json['pendingItineraries'] as int? ?? 0,
      activeClients: json['activeClients'] as int? ?? 0,
      recentTravels: (json['recentTravels'] as List<dynamic>? ?? const [])
          .map((e) => DashboardTravelSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeClientsList:
          (json['activeClientsList'] as List<dynamic>? ?? const [])
              .map((e) => DashboardClientSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  DashboardStats toDomain() {
    return DashboardStats(
      totalTravels: totalTravels,
      completedItineraries: completedItineraries,
      pendingItineraries: pendingItineraries,
      activeClients: activeClients,
      recentTravels: recentTravels.map((e) => e.toDomain()).toList(),
      activeClientsList: activeClientsList.map((e) => e.toDomain()).toList(),
    );
  }
}

class DashboardTravelSummaryDto {
  final String id;
  final String clientId;
  final String travelName;
  final String destination;
  final String startLocation;
  final DateTime startDate;
  final String status;
  final bool hasItinerary;

  const DashboardTravelSummaryDto({
    required this.id,
    required this.clientId,
    required this.travelName,
    required this.destination,
    required this.startLocation,
    required this.startDate,
    required this.status,
    required this.hasItinerary,
  });

  factory DashboardTravelSummaryDto.fromJson(Map<String, dynamic> json) {
    final routePlan = json['routePlan'] as Map<String, dynamic>? ?? const {};
    return DashboardTravelSummaryDto(
      id: json['id'] as String? ?? '',
      clientId: json['clientName'] as String? ?? '',
      travelName: json['travelName'] as String? ?? '',
      destination: routePlan['destination'] as String? ?? '',
      startLocation: routePlan['startLocation'] as String? ?? '',
      startDate: DateTime.tryParse(routePlan['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: json['travelStatus'] as String? ?? 'route_created',
      hasItinerary: json['itinerary'] != null,
    );
  }

  DashboardTravelSummary toDomain() {
    return DashboardTravelSummary(
      id: id,
      clientId: clientId,
      travelName: travelName,
      destination: destination,
      startLocation: startLocation,
      startDate: startDate,
      status: status,
      hasItinerary: hasItinerary,
    );
  }
}

class DashboardClientSummaryDto {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const DashboardClientSummaryDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory DashboardClientSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardClientSummaryDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  DashboardClientSummary toDomain() {
    return DashboardClientSummary(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}
