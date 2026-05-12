
import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';

import '../../../../core/services/auth_service.dart';
import '../dtos/itinerary_step_dto.dart';


/// singleton data source Responsible for CRUD methods data from [ItineraryApiClient].
class ItineraryDataSource{
  final _itineraryService = ItineraryApiClient.instance;
  final _authService = AuthService.instance;

  /// responsible for getting a [ItineraryDTO] from API, using [ItineraryApiClient]
  Future<ItineraryDTO> getItinerary(String id) async{
    final token = await _authService.getToken();
    final result = await _itineraryService.getItinerary(token!, id);
    return ItineraryDTO.fromJson(result);
  }

  /// responsible for getting a list of [ItineraryDTO] from API, using [ItineraryApiClient]
  Future<List<ItineraryStepDTO>> getItinerarySteps(String id) async {
    final token = await _authService.getToken();
    final result = await _itineraryService.getAllItinerarySteps(token!, id);

    final list = result as List;

    return list
        .map((e) => ItineraryStepDTO.fromJson(e))
        .toList();
  }

  /// responsible for getting a [ItineraryStepDTO] from API, using [ItineraryApiClient]
  Future<ItineraryStepDTO> getItineraryStep(String id) async {
    final token = await _authService.getToken();
    final result = await _itineraryService.getItineraryStep(token!, id);
    return ItineraryStepDTO.fromJson(result);
  }

  /// responsible for creating a [ItineraryDTO] from API, using [ItineraryApiClient]
  Future<void> createItinerary(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    await _itineraryService.createItinerary(token!, data);
  }

  /// responsible for updating a [ItineraryDTO] from API, using [ItineraryApiClient]
  Future<ItineraryDTO> updateItinerary(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    final result = await _itineraryService.updateItinerary(token!, '', data);
    return ItineraryDTO.fromJson(result);
  }

  /// responsible for deleting a [ItineraryDTO] from API, using [ItineraryApiClient]
  Future<void> deleteItinerary(String id) async {
    final token = await _authService.getToken();
    await _itineraryService.deleteItinerary(token!, id);

  }




}