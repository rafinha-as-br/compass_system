import 'package:flutter/material.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';
import 'package:routecraft_app/core/services/compass_service.dart';
import 'package:routecraft_app/core/services/auth_service.dart';

class VisualizationState {
  final bool isLoading;
  final List<Travel> travels;

  const VisualizationState({
    this.isLoading = true,
    this.travels = const [],
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
      final token = await AuthService.instance.getToken();
      if (token == null) {
        _state = const VisualizationState(isLoading: false);
        notifyListeners();
        return;
      }

      // Fetch travels for client from the API
      final response =
          await CompassService.instance.getTravelsForClient(token, 'client_1');

      final List<Travel> travels = [];
      if (response['status'] == 'success') {
        final data = response['data'] as List<dynamic>;
        for (var item in data) {
          travels.add(Travel.fromJson(item as Map<String, dynamic>));
        }
      }

      if (travels.isEmpty) {
        travels.add(
          Travel(
            id: 'mock_travel_999',
            clientId: 'client_1',
            agentId: 'agent_1',
            travelName: 'Mock Travel: New York to Tokyo',
            travelStatus: TravelStatus.routeCreated,
            participantsList: [],
            routePlan: RoutePlan(
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 10)),
              startLocation: 'New York',
              destination: 'Tokyo',
              interestsList: [
                InterestPoint(id: 'ip1', name: 'Mount Fuji', description: 'Sightseeing'),
              ],
            ),
          ),
        );
      }

      _state = VisualizationState(
        isLoading: false,
        travels: travels,
      );
      notifyListeners();
    } catch (e) {
      _state = const VisualizationState(isLoading: false);
      notifyListeners();
    }
  }
}
