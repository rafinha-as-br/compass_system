
import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';

import '../../../../core/services/auth_service.dart';
import '../dtos/itinerary_step_dto.dart';

class ItineraryDataSource{
  final _itineraryService = ItineraryApiClient.instance;
  final _authService = AuthService.instance;


  Future<ItineraryDTO> getItinerary(String id) async{
    final token = await _authService.getToken();
    final result = await _itineraryService.getItinerary(token!, id);
    return ItineraryDTO.fromJson(result);
  }

  Future<List<ItineraryStepDTO>> getItinerarySteps(String id) async {
    final token = await _authService.getToken();
    final result = await _itineraryService.getAllItinerarySteps(token!, id);

    final list = result as List;

    return list
        .map((e) => ItineraryStepDTO.fromJson(e))
        .toList();
  }

  Future<ItineraryStepDTO> getItineraryStep(String id) async {
    final token = await _authService.getToken();
    final result = await _itineraryService.getItineraryStep(token!, id);
    return ItineraryStepDTO.fromJson(result);
  }




}