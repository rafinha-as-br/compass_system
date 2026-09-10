import 'package:routecraft_app/core/network/clients/participants_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';

class ParticipantsDataSource {
  final ParticipantsApiClient _client;
  final Future<String?> Function()? _getTokenOverride;

  ParticipantsDataSource({ParticipantsApiClient? client, Future<String?> Function()? getToken})
      : _client = client ?? ParticipantsApiClient(HttpApiClient.instance),
        _getTokenOverride = getToken;

  Future<String> _token() async => await (_getTokenOverride ?? AuthService.instance.getToken)() ?? '';

  Future<List<PersonDTO>> updateParticipants(String travelId, List<PersonDTO> participants) async {
    final result = await _client.updateParticipants(
      await _token(),
      travelId,
      participants.map((p) => p.toJson()).toList(),
    );
    final data = result['data'] as List<dynamic>;
    return data.map((json) => PersonDTO.fromJson(json as Map<String, dynamic>)).toList();
  }
}
