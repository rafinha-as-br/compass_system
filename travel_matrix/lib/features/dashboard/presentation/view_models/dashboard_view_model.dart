import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardViewModel {
  final int totalTravels;
  final int completedItineraries;
  final int pendingItineraries;
  final int activeClients;
  final List<DashboardTravelRowViewModel> recentTravels;
  final List<DashboardClientRowViewModel> activeClientsList;

  const DashboardViewModel({
    required this.totalTravels,
    required this.completedItineraries,
    required this.pendingItineraries,
    required this.activeClients,
    required this.recentTravels,
    required this.activeClientsList,
  });

  factory DashboardViewModel.fromDomain(DashboardStats stats) {
    return DashboardViewModel(
      totalTravels: stats.totalTravels,
      completedItineraries: stats.completedItineraries,
      pendingItineraries: stats.pendingItineraries,
      activeClients: stats.activeClients,
      recentTravels:
          stats.recentTravels.map(DashboardTravelRowViewModel.fromDomain).toList(),
      activeClientsList:
          stats.activeClientsList.map(DashboardClientRowViewModel.fromDomain).toList(),
    );
  }
}

class DashboardTravelRowViewModel {
  final String id;
  final String clientName;
  final String travelName;
  final String route;
  final String destination;
  final DateTime startDate;

  /// Status bruto vindo do backend (ex.: `route_created`). A tradução para
  /// texto exibível ao usuário é responsabilidade da camada de apresentação
  /// (que tem acesso a l10n) — ver `_statusLabel` em `dashboard_page.dart`.
  final String status;
  final bool hasItinerary;

  const DashboardTravelRowViewModel({
    required this.id,
    required this.clientName,
    required this.travelName,
    required this.route,
    required this.destination,
    required this.startDate,
    required this.status,
    required this.hasItinerary,
  });

  factory DashboardTravelRowViewModel.fromDomain(DashboardTravelSummary travel) {
    return DashboardTravelRowViewModel(
      id: travel.id,
      clientName: travel.clientName,
      travelName: travel.travelName,
      route: '${travel.startLocation} -> ${travel.destination}',
      destination: travel.destination,
      startDate: travel.startDate,
      status: travel.status,
      hasItinerary: travel.hasItinerary,
    );
  }
}

class DashboardClientRowViewModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const DashboardClientRowViewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory DashboardClientRowViewModel.fromDomain(DashboardClientSummary client) {
    return DashboardClientRowViewModel(
      id: client.id,
      name: client.name,
      email: client.email,
      phoneNumber: client.phoneNumber,
    );
  }
}
