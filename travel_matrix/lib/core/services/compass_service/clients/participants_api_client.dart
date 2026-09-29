import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the isolated participants endpoint
/// (`PUT /travels/{travelId}/participants`) — upserts only the participants
/// list, without touching the travel's route/itinerary.
class ParticipantsApiClient {
  static ParticipantsApiClient? _instance;

  ParticipantsApiClient._();

  static Future<ParticipantsApiClient> init() async {
    assert(_instance == null, 'ParticipantsApiClient instance already initialized!');
    _instance ??= ParticipantsApiClient._();
    return _instance!;
  }

  static ParticipantsApiClient get instance {
    assert(_instance != null, 'ParticipantsApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> updateParticipants(
    String token,
    String travelId,
    List<Map<String, dynamic>> participants,
  ) async {
    return HttpApiClient.instance.put(token, ApiEndpoints.travelParticipants(travelId), participants);
  }
}
