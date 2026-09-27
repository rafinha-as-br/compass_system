import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';

abstract interface class NotificationRepository {
  /// Returns this page's notifications plus whether more pages remain.
  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size});
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markAllAsRead();
}
