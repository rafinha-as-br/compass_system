import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the `/push-targets` endpoints.
class PushTargetApiClient {
  final HttpApiClient _client;

  const PushTargetApiClient(this._client);

  Future<Map<String, dynamic>> registerAndroid(String token, String endpoint) {
    return _client.post(token, ApiEndpoints.pushTargets, {
      'platform': 'ANDROID',
      'androidEndpoint': endpoint,
    });
  }

  Future<Map<String, dynamic>> unregister(String token, String id) {
    return _client.delete(token, ApiEndpoints.pushTarget(id));
  }
}
