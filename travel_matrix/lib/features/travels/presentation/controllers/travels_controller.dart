import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:mock_repository/mock_repository.dart';

class TravelsState {
  final bool isLoading;
  final List<Travel> travels;
  final String? errorMessage;

  const TravelsState({
    this.isLoading = true,
    this.travels = const [],
    this.errorMessage,
  });
}

class TravelsController extends ChangeNotifier {
  TravelsState _state = const TravelsState();
  TravelsState get state => _state;

  TravelsController() {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _state = const TravelsState(isLoading: true);
    notifyListeners();

    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        _state = const TravelsState(
            isLoading: false,
            errorMessage: 'Not authenticated.');
        notifyListeners();
        return;
      }

      final response = await CompassService.instance.getAllTravels(token);

      if (response['status'] == 'success') {
        final data = response['data'] as List<dynamic>;
        final travels = data
            .map((e) => Travel.fromJson(e as Map<String, dynamic>))
            .toList();
        _state = TravelsState(isLoading: false, travels: travels);
      } else {
        _state = TravelsState(
          isLoading: false,
          errorMessage: response['message'] as String?,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = TravelsState(
        isLoading: false,
        errorMessage: 'Failed to fetch travels: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> createTravel(Map<String, dynamic> travelData) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.createTravel(token, travelData);
      if (response['status'] == 'success') {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTravel(String travelId) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.deleteTravel(token, travelId);
      if (response['status'] == 'success') {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRoute(
      String travelId, Map<String, dynamic> routeData) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .updateRoute(token, travelId, routeData);
      if (response['status'] == 'success') {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createItinerary(
      String travelId, Map<String, dynamic> itineraryData) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .createItinerary(token, travelId, itineraryData);
      if (response['status'] == 'success') {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItinerary(
      String travelId, Map<String, dynamic> itineraryData) async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response = await CompassService.instance
          .updateItinerary(token, travelId, itineraryData);
      if (response['status'] == 'success') {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
