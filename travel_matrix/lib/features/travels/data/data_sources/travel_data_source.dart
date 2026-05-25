import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/travel_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';

class TravelDataSource {
  final _travelService = TravelApiClient.instance;
  final _authService = AuthService.instance;

  Future<TravelDTO> getTravel(String id) async {
    final token = await _authService.getToken() ?? '';
    final result = await _travelService.getTravel(token, id);
    return TravelDTO.fromJson(result);
  }

  Future<List<TravelDTO>> getAllTravels() async {
    final token = await _authService.getToken() ?? '';
    final result = await _travelService.getAllTravels(token);
    final data = result['data'] as List<dynamic>? ?? [];
    return data.map((json) => TravelDTO.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<TravelDTO> createTravel(TravelDTO travelData) async {
    final token = await _authService.getToken() ?? '';
    final result = await _travelService.createTravel(token, travelData.toJson());
    return TravelDTO.fromJson(result);
  }

  Future<TravelDTO> updateTravel(String id, TravelDTO travelData) async {
    final token = await _authService.getToken() ?? '';
    final result = await _travelService.updateTravel(token, id, travelData.toJson());
    return TravelDTO.fromJson(result);
  }

  Future<void> deleteTravel(String id) async {
    final token = await _authService.getToken() ?? '';
    await _travelService.deleteTravel(token, id);
  }
}