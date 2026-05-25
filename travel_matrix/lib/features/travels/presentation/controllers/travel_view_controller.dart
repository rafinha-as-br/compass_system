import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/core/services/compass_service.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import '../models/view_models/travel_view_model.dart';

/// State for the travel view page.
class TravelViewState {
  final bool isLoading;
  final TravelViewModel? travel;
  final String? errorMessage;

  const TravelViewState({
    this.isLoading = true,
    this.travel,
    this.errorMessage,
  });
}

/// Controller that fetches a single travel by ID for viewing.
class TravelViewController extends ChangeNotifier {
  TravelViewState _state = const TravelViewState();
  TravelViewState get state => _state;

  /// Fetches a travel by its ID.
  Future<void> fetchTravel(String travelId) async {
    _state = const TravelViewState(isLoading: true);
    notifyListeners();

    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        _state = const TravelViewState(
          isLoading: false,
          errorMessage: 'Not authenticated.',
        );
        notifyListeners();
        return;
      }

      final response =
          await CompassService.instance.getTravel(token, travelId);

      if (response['status'] == 'success') {
        final travel = TravelDTO.fromJson(response['data'] as Map<String, dynamic>).toDomain();
        _state = TravelViewState(isLoading: false, travel: TravelViewModel.fromDomain(travel));
      } else {
        _state = TravelViewState(
          isLoading: false,
          errorMessage: response['message'] as String?,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = TravelViewState(
        isLoading: false,
        errorMessage: 'Failed to fetch travel: $e',
      );
      notifyListeners();
    }
  }
}
