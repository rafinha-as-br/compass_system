import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/data/data_sources/notification_data_source.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _dataSource = NotificationDataSource();

  @override
  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size}) async {
    try {
      final (dtos, hasMore) = await _dataSource.getNotifications(page: page, size: size);
      return Result.success((dtos.map((dto) => dto.toDomain()).toList(), hasMore));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      return Result.success(await _dataSource.getUnreadCount());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _dataSource.markAsRead(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
