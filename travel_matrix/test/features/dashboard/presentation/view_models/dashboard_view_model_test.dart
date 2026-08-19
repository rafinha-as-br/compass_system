import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';

void main() {
  group('DashboardViewModel', () {
    test('fromDomain round-trips the KPIs and nested lists', () {
      final stats = DashboardStats(
        totalTravels: 12,
        completedItineraries: 7,
        pendingItineraries: 5,
        activeClients: 9,
        recentTravels: [
          DashboardTravelSummary(
            id: '1',
            clientName: 'Maria Silva',
            travelName: 'Litoral Norte',
            destination: 'Ubatuba',
            startLocation: 'São Paulo',
            startDate: DateTime(2026, 8, 1),
            status: 'itinerary_created',
            hasItinerary: true,
          ),
        ],
        activeClientsList: const [
          DashboardClientSummary(
            id: '1',
            name: 'Maria Silva',
            email: 'maria@compass.com',
            phoneNumber: '11999999999',
          ),
        ],
      );

      final viewModel = DashboardViewModel.fromDomain(stats);

      expect(viewModel.totalTravels, stats.totalTravels);
      expect(viewModel.recentTravels, hasLength(1));
      expect(viewModel.activeClientsList, hasLength(1));

      final travel = viewModel.recentTravels.single;
      expect(travel.clientName, 'Maria Silva');
      expect(travel.route, 'São Paulo -> Ubatuba');
      // O ViewModel mantém o status bruto do backend — a tradução para
      // texto exibível fica a cargo da camada de apresentação (l10n).
      expect(travel.status, 'itinerary_created');

      final client = viewModel.activeClientsList.single;
      expect(client.name, 'Maria Silva');
      expect(client.email, 'maria@compass.com');
    });
  });
}
