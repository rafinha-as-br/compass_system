class DashboardStats {
  final int totalTravels;
  final int completedItineraries;
  final int pendingItineraries;
  final int activeClients;
  final List<DashboardTravelSummary> recentTravels;
  final List<DashboardClientSummary> activeClientsList;

  const DashboardStats({
    required this.totalTravels,
    required this.completedItineraries,
    required this.pendingItineraries,
    required this.activeClients,
    required this.recentTravels,
    required this.activeClientsList,
  });
}

class DashboardTravelSummary {
  final String id;
  final String clientId;
  final String travelName;
  final String destination;
  final String startLocation;
  final DateTime startDate;
  final String status;
  final bool hasItinerary;

  const DashboardTravelSummary({
    required this.id,
    required this.clientId,
    required this.travelName,
    required this.destination,
    required this.startLocation,
    required this.startDate,
    required this.status,
    required this.hasItinerary,
  });
}

class DashboardClientSummary {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const DashboardClientSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });
}
