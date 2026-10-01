import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/notifications/data/datasources/notification_data_source.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _dataSource;

  NotificationRepositoryImpl({NotificationDataSource? dataSource}) : _dataSource = dataSource ?? NotificationDataSource();

  @override
  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size}) async {
    try {
      final (dtos, hasMore) = await _dataSource.getNotifications(page: page, size: size);
      return Result.success((dtos.map((dto) => dto.toDomain()).toList(), hasMore));
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar as notificações.', isConnectivityError: true);
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      return Result.success(await _dataSource.getUnreadCount());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar a contagem de notificações.', isConnectivityError: true);
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível marcar as notificações como lidas.', isConnectivityError: true);
    }
  }
}
