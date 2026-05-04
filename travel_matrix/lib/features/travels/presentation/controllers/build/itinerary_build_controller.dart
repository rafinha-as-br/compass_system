/* this controller is responsible for creating and delete an ITINERARY
   it will be used in itinerary_creation_page.dart
*/

// itinerary_create_controller.dart
import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

import '../../../domain/repository/itinerary_repository.dart';

// create_itinerary_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

class CreateItineraryController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createItinerary(
      String travelId,
      Map<String, dynamic> itineraryData,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement actual use case when available
      // await CrudItinerary.create(travelId, itineraryData);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}