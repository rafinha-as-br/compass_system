import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the `/users` endpoints that back
/// the client's personal-data screen.
class ClientUserApiClient {
  final HttpApiClient _client;

  const ClientUserApiClient(this._client);

  Future<Map<String, dynamic>> getCurrentUser(String token) {
    return _client.get(token, ApiEndpoints.currentUser);
  }

  Future<Map<String, dynamic>> updateUser(String token, String id, Map<String, dynamic> body) {
    return _client.put(token, ApiEndpoints.userById(id), body);
  }

  Future<Map<String, dynamic>> resetPassword(String token, String id) {
    return _client.post(token, ApiEndpoints.userResetPassword(id), const {});
  }
}
