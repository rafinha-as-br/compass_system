import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

class NotificationApiClient {
  static NotificationApiClient? _instance;

  NotificationApiClient._();

  static Future<NotificationApiClient> init() async {
    assert(_instance == null, 'NotificationApiClient instance already initialized!');
    _instance ??= NotificationApiClient._();
    return _instance!;
  }

  static NotificationApiClient get instance {
    assert(_instance != null, 'NotificationApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getNotifications(String token, {required int page, required int size}) {
    return HttpApiClient.instance.get(token, ApiEndpoints.notifications(page: page, size: size));
  }

  Future<Map<String, dynamic>> getUnreadCount(String token) {
    return HttpApiClient.instance.get(token, ApiEndpoints.notificationsUnreadCount);
  }

  Future<Map<String, dynamic>> markAsRead(String token, String id) {
    return HttpApiClient.instance.put(token, ApiEndpoints.notificationRead(id), const {});
  }

  Future<Map<String, dynamic>> markAllAsRead(String token) {
    return HttpApiClient.instance.put(token, ApiEndpoints.notificationsReadAll, const {});
  }
}
