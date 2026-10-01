import 'package:travel_matrix/core/services/compass_service/clients/participants_api_client.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import '../../../../core/services/auth_storage_service.dart';

class ParticipantsDataSource {
  final _participantsService = ParticipantsApiClient.instance;
  final _authService = AuthStorageService.instance;

  Future<List<PersonDTO>> updateParticipants(String travelId, List<PersonDTO> participants) async {
    final token = await _authService.getToken() ?? '';
    final result = await _participantsService.updateParticipants(
      token,
      travelId,
      participants.map((p) => p.toJson()).toList(),
    );
    final data = result['data'] as List<dynamic>;
    return data.map((json) => PersonDTO.fromJson(json as Map<String, dynamic>)).toList();
  }
}
