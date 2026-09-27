import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_repository.dart';

class NotificationUseCases {
  final NotificationRepository repository;

  const NotificationUseCases(this.repository);

  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size}) =>
      repository.getNotifications(page: page, size: size);

  Future<Result<int>> getUnreadCount() => repository.getUnreadCount();

  Future<Result<void>> markAllAsRead() => repository.markAllAsRead();
}
