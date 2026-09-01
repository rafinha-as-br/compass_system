import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_itinerary.dart';

class CreateItineraryController extends ChangeNotifier {
  final CrudItinerary crudItinerary;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  CreateItineraryController({required this.crudItinerary});

  /// Creates an itinerary for the given travel.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> createItinerary(
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final itineraryDto = ItineraryDTO.fromJson(itineraryData);
    final result = await crudItinerary.upsert(travelId, itineraryDto.toDomain());

    _isLoading = false;
    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _error = result.error ?? 'Failed to create itinerary.';
      notifyListeners();
      return false;
    }
  }
}
