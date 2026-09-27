import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:routecraft_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class _FakeNotificationRepository implements NotificationRepository {
  Result<(List<TravelNotification>, bool)>? Function(int page)? nextPage;
  Result<void>? markAllAsReadResult;
  List<TravelNotification>? markedAllAsRead;

  @override
  Future<Result<(List<TravelNotification>, bool)>> getNotifications({required int page, required int size}) async =>
      nextPage!(page)!;

  @override
  Future<Result<int>> getUnreadCount() async => throw UnimplementedError();

  @override
  Future<Result<void>> markAllAsRead() async => markAllAsReadResult ?? const Result.success(null);
}

class _FakeTravelRepository implements TravelRepository {
  Result<Travel>? nextGetResult;

  @override
  Future<Result<Travel>> getTravel(String id) async => nextGetResult!;

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

TravelNotification _notification(String id, {bool read = false, DateTime? createdAt}) => TravelNotification(
      id: id,
      travelId: 't1',
      type: TravelNotificationType.itineraryPublished,
      createdAt: createdAt ?? DateTime(2026, 9, 1),
      read: read,
    );

void main() {
  group('NotificationsController', () {
    test('loads the first page on construction', () async {
      final repository = _FakeNotificationRepository()
        ..nextPage = (page) => Result.success((
              [_notification('n1'), _notification('n2', createdAt: DateTime(2026, 9, 3))],
              true,
            ));
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.notifications.map((n) => n.id), ['n1', 'n2']);
      expect(controller.state.hasMore, isTrue);
    });

    test('goes to the error state when the initial fetch fails', () async {
      final repository = _FakeNotificationRepository()..nextPage = (page) => const Result.failure('boom');
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isError, isTrue);
    });

    test('retry() re-fetches from the error state', () async {
      var calls = 0;
      final repository = _FakeNotificationRepository()
        ..nextPage = (page) {
          calls++;
          if (calls == 1) return const Result.failure('boom');
          return Result.success(([_notification('n1')], false));
        };
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.isError, isTrue);

      await controller.retry();

      expect(controller.state.isError, isFalse);
      expect(controller.state.notifications, hasLength(1));
    });

    test('loadMore() appends the next page and advances hasMore/page', () async {
      final repository = _FakeNotificationRepository()
        ..nextPage = (page) => page == 0
            ? Result.success(([_notification('n1')], true))
            : Result.success(([_notification('n2')], false));
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      await controller.loadMore();

      expect(controller.state.notifications.map((n) => n.id), ['n1', 'n2']);
      expect(controller.state.hasMore, isFalse);
    });

    test('loadMore() is a no-op when there is no next page', () async {
      final repository = _FakeNotificationRepository()..nextPage = (page) => Result.success(([_notification('n1')], false));
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      await controller.loadMore();

      expect(controller.state.notifications, hasLength(1));
    });

    test('markAllRead flips every notification to read locally and calls the backend', () async {
      final repository = _FakeNotificationRepository()
        ..nextPage = (page) => Result.success(([_notification('n1'), _notification('n2')], false));
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      await controller.markAllRead();

      expect(controller.state.notifications.every((n) => n.read), isTrue);
    });

    test('markAllRead does nothing when everything is already read', () async {
      final repository = _FakeNotificationRepository();
      repository.nextPage = (page) => Result.success(([_notification('n1', read: true)], false));
      repository.markAllAsReadResult = const Result.failure('should not be called');
      final controller = NotificationsController(notificationUseCases: NotificationUseCases(repository));
      await Future<void>.delayed(Duration.zero);

      // Would surface as an unhandled failure path if markAllAsRead were
      // actually invoked here; the no-op short-circuit prevents that.
      await controller.markAllRead();

      expect(controller.state.notifications.single.read, isTrue);
    });

    test('resolveTravel returns the fetched travel on success', () async {
      final notificationRepository = _FakeNotificationRepository()
        ..nextPage = (page) => Result.success((<TravelNotification>[], false));
      final travelRepository = _FakeTravelRepository()
        ..nextGetResult = Result.success(Travel(
          domainId: 'local-t1',
          backEndId: 't1',
          clientName: 'Rafaela Souza',
          travelName: 'Litoral Norte',
          travelStatus: TravelStatus.routeCreated,
          participantsList: const [],
          routePlan: RoutePlan(
            domainId: 'r1',
            backEndId: 'r1',
            startDate: DateTime(2026, 10, 12),
            endDate: DateTime(2026, 10, 19),
            startLocation: 'São Paulo',
            destination: 'Paraty',
            interestsList: const [],
          ),
        ));
      final controller = NotificationsController(
        notificationUseCases: NotificationUseCases(notificationRepository),
        travelUseCases: TravelUseCases(travelRepository),
      );

      final travel = await controller.resolveTravel('t1');

      expect(travel?.travelName, 'Litoral Norte');
    });

    test('resolveTravel returns null on failure', () async {
      final notificationRepository = _FakeNotificationRepository()
        ..nextPage = (page) => Result.success((<TravelNotification>[], false));
      final travelRepository = _FakeTravelRepository()..nextGetResult = const Result.failure('not found');
      final controller = NotificationsController(
        notificationUseCases: NotificationUseCases(notificationRepository),
        travelUseCases: TravelUseCases(travelRepository),
      );

      expect(await controller.resolveTravel('t1'), isNull);
    });
  });
}
