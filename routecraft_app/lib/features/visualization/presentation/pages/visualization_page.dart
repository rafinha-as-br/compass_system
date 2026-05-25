import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:routecraft_app/features/home/presentation/pages/follow_travel_page.dart';
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
        title: const Text('My Travels'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.travels.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No travels created yet.'),
                    ),
                  )
                else
                  ...state.travels.map((t) => _buildTravelCard(context, t)),
              ],
            ),
    );
  }

  Widget _buildTravelCard(BuildContext context, Travel travel) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          travel.hasItinerary ? Icons.flight_takeoff : Icons.map,
          color: travel.hasItinerary ? Colors.green : Theme.of(context).primaryColor,
        ),
        title: Text(
          travel.travelName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${travel.routePlan.startLocation} ➔ ${travel.routePlan.destination}',
        ),
        trailing: Chip(
          label: Text(
            travel.hasItinerary ? 'ITINERARY READY' : 'ROUTE ONLY',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: travel.hasItinerary ? Colors.green : Colors.orange,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FollowTravelPage(travel: travel),
            ),
          );
        },
      ),
    );
  }
}
