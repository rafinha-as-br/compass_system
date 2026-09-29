import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/notification_api_client.dart';
import 'package:travel_matrix/features/notifications/data/dtos/notification_dto.dart';

class NotificationDataSource {
  final _client = NotificationApiClient.instance;
  final _authService = AuthStorageService.instance;

  /// Returns the page's notifications plus whether more pages remain
  /// (Spring's `Page.last` inverted) — `content`/`last` are Spring Data's
  /// own JSON field names for a `Page<T>` response, not this app's.
  Future<(List<NotificationDTO>, bool)> getNotifications({required int page, required int size}) async {
    final token = await _authService.getToken() ?? '';
    final result = await _client.getNotifications(token, page: page, size: size);
    final content = result['content'];
    final items = content is List
        ? content.cast<Map<String, dynamic>>().map(NotificationDTO.fromJson).toList()
        : <NotificationDTO>[];
    final hasMore = result['last'] == false;
    return (items, hasMore);
  }

  Future<int> getUnreadCount() async {
    final token = await _authService.getToken() ?? '';
    final result = await _client.getUnreadCount(token);
    return (result['count'] as num).toInt();
  }

  Future<void> markAsRead(String id) async {
    final token = await _authService.getToken() ?? '';
    await _client.markAsRead(token, id);
  }

  Future<void> markAllAsRead() async {
    final token = await _authService.getToken() ?? '';
    await _client.markAllAsRead(token);
  }
}
