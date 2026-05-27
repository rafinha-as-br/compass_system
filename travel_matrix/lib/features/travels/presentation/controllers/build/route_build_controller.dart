import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

class CreateRouteController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Updates the route for a given travel.
  ///
  /// Since routes are created as part of travel creation, this method
  /// handles route updates on existing travels.
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateRoute(
    String travelId,
    Map<String, dynamic> routeData,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) {
        _setError('Not authenticated.');
        _setLoading(false);
        return false;
      }

      final response = await CompassService.instance
          .updateRoute(token, travelId, routeData);

      _setLoading(false);

      if (response['status'] == 'success') {
        return true;
      } else {
        _setError(response['message'] as String? ?? 'Failed to update route.');
        return false;
      }
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
  }
}