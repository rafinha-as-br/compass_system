
/* this controller is responsible for UPDATE an ITINERARY
   it will be used in itinerary_creation_page.dart
*/

// update_itinerary_controller.dart
import 'package:flutter/cupertino.dart';

class UpdateItineraryController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateItinerary(
      String travelId,
      Map<String, dynamic> itineraryData,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement actual use case when available
      // await CrudItinerary.update(travelId, itineraryData);

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