import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the `/notifications` endpoints.
class NotificationApiClient {
  final HttpApiClient _client;

  const NotificationApiClient(this._client);

  Future<Map<String, dynamic>> getNotifications(String token, {required int page, required int size}) {
    return _client.get(token, ApiEndpoints.notifications(page, size));
  }

  Future<Map<String, dynamic>> getUnreadCount(String token) {
    return _client.get(token, ApiEndpoints.notificationsUnreadCount);
  }

  Future<Map<String, dynamic>> markAllAsRead(String token) {
    return _client.put(token, ApiEndpoints.notificationsReadAll, const <String, dynamic>{});
  }
}
