import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:routecraft_app/features/visualization/presentation/controllers/visualization_controller.dart';

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
      appBar: AppBar(
        title: const Text('Routes & Itineraries'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Your Routes (Drafts)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (state.routes.isEmpty)
                  const Text('No routes created yet.\n')
                else
                  ...state.routes.map((r) => _buildRouteCard(context, r)),
                  
                const Divider(height: 32),
                
                const Text('Your Itineraries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (state.itineraries.isEmpty)
                  const Text('No itineraries from agents yet.\n')
                else
                  ...state.itineraries.map((i) => _buildItineraryCard(context, i)),
              ],
            ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RoutePlan route) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.map, color: Theme.of(context).primaryColor),
        title: Text(route.tripName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${route.startLocation} ➔ ${route.destination}'),
        trailing: const Chip(
          label: Text('DRAFT', style: TextStyle(fontSize: 10)),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildItineraryCard(BuildContext context, Itinerary itinerary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.flight_takeoff, color: Colors.green), 
        title: Text('Itinerary: ${itinerary.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${itinerary.listOfStops.length} stops scheduled.'),
        trailing: const Chip(
          label: Text('READY', style: TextStyle(fontSize: 10, color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}
