import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

import 'package:routecraft_app/features/visualization/presentation/controllers/visualization_controller.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`VisualizationPage()`) is unaffected — the default wiring is used.
  final VisualizationController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? VisualizationController(),
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
          color: travel.hasItinerary ? TravelAppColors.success : Theme.of(context).primaryColor,
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
            style: const TextStyle(fontSize: 10, color: TravelAppColors.textOnDark),
          ),
          backgroundColor: travel.hasItinerary ? TravelAppColors.success : TravelAppColors.warning,
        ),
        onTap: () {
          context.push(AppRoutes.itineraryFollowTravel, extra: travel);
        },
      ),
    );
  }
}
