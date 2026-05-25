import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';
import 'package:travel_matrix/core/services/auth_service.dart';

class ItineraryDataSource {
  final _itineraryService = ItineraryApiClient.instance;
  final _authService = AuthService.instance;

  Future<ItineraryDTO> upsertItinerary(String travelId, ItineraryDTO data) async {
    final token = await _authService.getToken() ?? '';
    final result = await _itineraryService.upsertItinerary(token, travelId, data.toJson());
    return ItineraryDTO.fromJson(result);
  }
}