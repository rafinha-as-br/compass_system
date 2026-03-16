import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';

class VisualizationState {
  final bool isLoading;
  final List<RoutePlan> routes;
  final List<Itinerary> itineraries;

  const VisualizationState({
    this.isLoading = true,
    this.routes = const [],
    this.itineraries = const [],
  });
}

class VisualizationController extends ChangeNotifier {
  VisualizationState _state = const VisualizationState();
  VisualizationState get state => _state;

  VisualizationController() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    _state = const VisualizationState(isLoading: true);
    notifyListeners();

    try {
      final routes = await CompassService.instance.getRoutes();
      final itineraries = await CompassService.instance.getItineraries();

      _state = VisualizationState(
        isLoading: false,
        routes: routes,
        itineraries: itineraries,
      );
      notifyListeners();
    } catch (e) {
      _state = const VisualizationState(isLoading: false);
      notifyListeners();
    }
  }
}

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisualizationController(),
      child: const _VisualizationView(),
    );
  }
}

class _VisualizationView extends StatelessWidget {
  const _VisualizationView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VisualizationController>();
    final state = controller.state;

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Routes Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Client Routes (Drafts)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: state.routes.isEmpty
                              ? const Text('No active routes found.')
                              : ListView.builder(
                                  itemCount: state.routes.length,
                                  itemBuilder: (context, index) => _buildRouteCard(context, state.routes[index]),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Itineraries Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Created Itineraries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: state.itineraries.isEmpty
                              ? const Text('No itineraries created.')
                              : ListView.builder(
                                  itemCount: state.itineraries.length,
                                  itemBuilder: (context, index) => _buildItineraryCard(context, state.itineraries[index]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RoutePlan route) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.assignment, color: Theme.of(context).primaryColor),
        title: Text(route.tripName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Client: ${route.clientId}\n${route.startLocation} ➔ ${route.destination}'),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            // Placeholder: Switch to Itinerary Creation tab with this route pre-selected
          },
          child: const Text('Create Itinerary'),
        ),
      ),
    );
  }

  Widget _buildItineraryCard(BuildContext context, Itinerary itinerary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text('Itinerary: ${itinerary.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Stops: ${itinerary.listOfStops.length}\nAgent ID: ${itinerary.createdByAgent}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {},
        ),
      ),
    );
  }
}
