import 'package:flutter/foundation.dart';
import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

/// Thin wrapper over [HttpApiClient] for the places autocomplete facade
/// (`GET /places/autocomplete`, CPS-152). Provider unavailability comes
/// back as an [ApiException] like any other failed call — the caller
/// (`PlacesAutocompleteField`) is what degrades to free text.
class PlacesApiClient {
  static PlacesApiClient? _instance;

  final HttpApiClient _client;

  PlacesApiClient._(this._client);

  @visibleForTesting
  factory PlacesApiClient.forTesting(HttpApiClient client) => PlacesApiClient._(client);

  static Future<PlacesApiClient> init() async {
    assert(_instance == null, 'PlacesApiClient instance already initialized!');
    _instance ??= PlacesApiClient._(HttpApiClient.instance);
    return _instance!;
  }

  static PlacesApiClient get instance {
    assert(_instance != null, 'PlacesApiClient instance not initialized!');
    return _instance!;
  }

  Future<List<PlaceSuggestion>> autocomplete(String token, String query) async {
    final response = await _client.get(token, ApiEndpoints.placesAutocomplete(query));
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PlaceSuggestion.fromJson)
        .toList();
  }
}
