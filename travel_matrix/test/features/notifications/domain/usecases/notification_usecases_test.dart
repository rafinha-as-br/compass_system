import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/repository/notification_repository.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';

class _MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late _MockNotificationRepository repository;
  late NotificationUseCases useCases;

  setUp(() {
    repository = _MockNotificationRepository();
    useCases = NotificationUseCases(repository);
  });

  test('getNotifications delegates to repository.getNotifications', () async {
    final notification = TravelNotification(
      id: 'n1',
      travelId: 't1',
      type: TravelNotificationType.routeCreated,
      createdAt: DateTime(2026, 1, 1),
    );
    when(() => repository.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([notification], false)));

    final result = await useCases.getNotifications(page: 0, size: 20);

    expect(result.isSuccess, isTrue);
    expect(result.data!.$1, [notification]);
    verify(() => repository.getNotifications(page: 0, size: 20)).called(1);
  });

  test('getUnreadCount delegates to repository.getUnreadCount', () async {
    when(() => repository.getUnreadCount()).thenAnswer((_) async => const Result.success(3));

    final result = await useCases.getUnreadCount();

    expect(result.isSuccess, isTrue);
    expect(result.data, 3);
    verify(() => repository.getUnreadCount()).called(1);
  });

  test('markAsRead delegates to repository.markAsRead', () async {
    when(() => repository.markAsRead('n1')).thenAnswer((_) async => const Result.success(null));

    final result = await useCases.markAsRead('n1');

    expect(result.isSuccess, isTrue);
    verify(() => repository.markAsRead('n1')).called(1);
  });

  test('markAllAsRead delegates to repository.markAllAsRead', () async {
    when(() => repository.markAllAsRead()).thenAnswer((_) async => const Result.success(null));

    final result = await useCases.markAllAsRead();

    expect(result.isSuccess, isTrue);
    verify(() => repository.markAllAsRead()).called(1);
  });
}
