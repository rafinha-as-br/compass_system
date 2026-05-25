import 'package:flutter/cupertino.dart';

import '../../../domain/usecases/crud_itinerary.dart';
import '../../../../travels/data/dtos/itinerary_dto.dart';

/// Controller responsible for updating an existing [Itinerary] via the domain
/// use case [CrudItinerary].
///
/// Takes a raw data map to avoid coupling the presentation layer to the
/// domain entity directly — mapping is done in [ItineraryRepositoryImpl].
class UpdateItineraryController extends ChangeNotifier {
  final CrudItinerary crudItinerary;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  UpdateItineraryController({required this.crudItinerary});

  /// Updates an existing itinerary identified by [travelId].
  ///
  /// [itineraryData] is a raw map matching the API contract.
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateItinerary(
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final itineraryDto = ItineraryDTO.fromJson(itineraryData);
    
    final result = await crudItinerary.upsert(
      travelId, 
      itineraryDto.toDomain()
    );

    _isLoading = false;
    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _error = result.error ?? 'Failed to update itinerary.';
      notifyListeners();
      return false;
    }
  }
}