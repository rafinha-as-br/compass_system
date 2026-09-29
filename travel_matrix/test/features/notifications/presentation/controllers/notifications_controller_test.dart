import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:travel_matrix/features/notifications/presentation/controllers/notifications_controller.dart';

class _MockNotificationUseCases extends Mock implements NotificationUseCases {}

TravelNotification _notification(String id, {bool read = false}) => TravelNotification(
      id: id,
      travelId: 'travel-$id',
      type: TravelNotificationType.routeCreated,
      createdAt: DateTime(2026, 1, 1),
      read: read,
    );

void main() {
  late _MockNotificationUseCases useCases;

  setUp(() {
    useCases = _MockNotificationUseCases();
  });

  test('loads the first page and exposes it through state on success', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('1')], false)));

    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.isError, isFalse);
    expect(controller.state.notifications, hasLength(1));
  });

  test('exposes an error state on failure', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => const Result.failure('Network error'));

    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.isError, isTrue);
  });

  test('retry re-runs the initial fetch', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => const Result.failure('Network error'));

    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();
    expect(controller.state.isError, isTrue);

    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('1')], false)));
    await controller.retry();

    expect(controller.state.isError, isFalse);
    expect(controller.state.notifications, hasLength(1));
  });

  test('loadMore appends the next page and advances it', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('1')], true)));
    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    when(() => useCases.getNotifications(page: 1, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('2')], false)));
    await controller.loadMore();

    expect(controller.state.notifications.map((n) => n.id), ['1', '2']);
    expect(controller.state.hasMore, isFalse);
  });

  test('markAsRead marks only the target notification, optimistically, and calls the backend', () async {
    when(() => useCases.getNotifications(page: 0, size: 20)).thenAnswer(
      (_) async => Result.success(([_notification('1'), _notification('2')], false)),
    );
    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    when(() => useCases.markAsRead('1')).thenAnswer((_) async => const Result.success(null));
    await controller.markAsRead('1');

    expect(controller.state.notifications.firstWhere((n) => n.id == '1').read, isTrue);
    expect(controller.state.notifications.firstWhere((n) => n.id == '2').read, isFalse);
    verify(() => useCases.markAsRead('1')).called(1);
  });

  test('markAllRead marks every notification and calls the backend once', () async {
    when(() => useCases.getNotifications(page: 0, size: 20)).thenAnswer(
      (_) async => Result.success(([_notification('1'), _notification('2')], false)),
    );
    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    when(() => useCases.markAllAsRead()).thenAnswer((_) async => const Result.success(null));
    await controller.markAllRead();

    expect(controller.state.notifications.every((n) => n.read), isTrue);
    verify(() => useCases.markAllAsRead()).called(1);
  });

  test('markAllRead is a no-op when everything is already read', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('1', read: true)], false)));
    final controller = NotificationsController(notificationUseCases: useCases);
    await pumpEventQueue();

    await controller.markAllRead();

    verifyNever(() => useCases.markAllAsRead());
  });

  test('markAsRead and markAllRead report back through onReadStateChanged so the sidebar badge can resync', () async {
    when(() => useCases.getNotifications(page: 0, size: 20))
        .thenAnswer((_) async => Result.success(([_notification('1'), _notification('2')], false)));
    var callbackCount = 0;
    final controller = NotificationsController(notificationUseCases: useCases, onReadStateChanged: () => callbackCount++);
    await pumpEventQueue();

    when(() => useCases.markAsRead('1')).thenAnswer((_) async => const Result.success(null));
    await controller.markAsRead('1');
    expect(callbackCount, 1);

    when(() => useCases.markAllAsRead()).thenAnswer((_) async => const Result.success(null));
    await controller.markAllRead();
    expect(callbackCount, 2);
  });
}
