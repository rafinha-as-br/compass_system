import 'package:routecraft_app/core/network/clients/notification_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/notifications/data/dtos/notification_dto.dart';

class NotificationDataSource {
  final NotificationApiClient _client;
  final Future<String?> Function()? _getTokenOverride;

  /// [getToken] is injectable for tests, without depending on the real
  /// `AuthService`/secure storage wiring — `AuthService.instance` is only
  /// touched when no override is given.
  NotificationDataSource({NotificationApiClient? client, Future<String?> Function()? getToken})
      : _client = client ?? NotificationApiClient(HttpApiClient.instance),
        _getTokenOverride = getToken;

  Future<String> _token() async => await (_getTokenOverride ?? AuthService.instance.getToken)() ?? '';

  /// Returns the page's notifications plus whether more pages remain
  /// (Spring's `Page.last` inverted) — `content`/`last` are Spring Data's
  /// own JSON field names for a `Page<T>` response, not this app's.
  Future<(List<NotificationDTO>, bool)> getNotifications({required int page, required int size}) async {
    final result = await _client.getNotifications(await _token(), page: page, size: size);
    final content = result['content'];
    final items = content is List
        ? content.cast<Map<String, dynamic>>().map(NotificationDTO.fromJson).toList()
        : <NotificationDTO>[];
    final hasMore = result['last'] == false;
    return (items, hasMore);
  }

  Future<int> getUnreadCount() async {
    final result = await _client.getUnreadCount(await _token());
    return (result['count'] as num).toInt();
  }

  Future<void> markAllAsRead() async {
    await _client.markAllAsRead(await _token());
  }
}
