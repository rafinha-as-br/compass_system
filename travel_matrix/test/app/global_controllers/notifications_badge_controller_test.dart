import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/notifications_badge_controller.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';

class _MockNotificationUseCases extends Mock implements NotificationUseCases {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
  });

  test('refresh sets the unread count from the server on success', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(5));
    final controller = NotificationsBadgeController(useCases: useCases);

    await controller.refresh();

    expect(controller.unreadCount, 5);
  });

  test('refresh keeps the previous count when the fetch fails', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(3));
    final controller = NotificationsBadgeController(useCases: useCases);
    await controller.refresh();

    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.failure('Network error'));
    await controller.refresh();

    expect(controller.unreadCount, 3);
  });

  test('onAuthChanged refreshes from the server when the agent is authenticated', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(4));
    final controller = NotificationsBadgeController(useCases: useCases);
    final auth = AuthController()..debugSetUserData({'id': 'agent-1'});

    controller.onAuthChanged(auth);
    await pumpEventQueue();

    expect(controller.unreadCount, 4);
  });

  test('onAuthChanged resets to 0 on logout, without hitting the server', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(7));
    final controller = NotificationsBadgeController(useCases: useCases);
    await controller.refresh();
    expect(controller.unreadCount, 7);
    clearInteractions(useCases);

    final auth = AuthController()..debugSetUserData(null);
    controller.onAuthChanged(auth);

    expect(controller.unreadCount, 0);
    verifyNever(() => useCases.getUnreadCount());
  });
}
