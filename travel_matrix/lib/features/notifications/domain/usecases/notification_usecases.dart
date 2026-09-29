import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/repository/notification_repository.dart';

class NotificationUseCases {
  final NotificationRepository repository;

  const NotificationUseCases(this.repository);

  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size}) =>
      repository.getNotifications(page: page, size: size);

  Future<Result<int>> getUnreadCount() => repository.getUnreadCount();

  Future<Result<void>> markAsRead(String id) => repository.markAsRead(id);

  Future<Result<void>> markAllAsRead() => repository.markAllAsRead();
}
