import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:routecraft_app/core/services/compass_service.dart';
import 'package:routecraft_app/core/services/local_db_service.dart';

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
      // Fetch routes locally first
      final localRoutes = await LocalDbService.instance.getLocalRoutes();
      final serverRoutes = await CompassService.instance.getRoutes(); // Assuming wrapper exists
      
      // Merge unique routes (very basic strategy for MVP)
      final allRoutes = <String, RoutePlan>{};
      for (var r in serverRoutes) { allRoutes[r.id] = r; }
      for (var r in localRoutes) { allRoutes[r.id] = r; }

      final itineraries = await CompassService.instance.getItineraries();

      _state = VisualizationState(
        isLoading: false,
        routes: allRoutes.values.toList(),
        itineraries: itineraries,
      );
      notifyListeners();
    } catch (e) {
      _state = const VisualizationState(isLoading: false);
      notifyListeners();
    }
  }
}
