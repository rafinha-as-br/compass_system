import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';

abstract class NotificationRepository {
  /// Returns this page's notifications plus whether more pages remain.
  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size});

  Future<Result<int>> getUnreadCount();

  Future<Result<void>> markAsRead(String id);

  Future<Result<void>> markAllAsRead();
}
