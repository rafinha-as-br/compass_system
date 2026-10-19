import 'dart:async';

import 'package:flutter/widgets.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
  });

  test('refresh sets the unread count from the server on success', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(5));
    final controller = NotificationsBadgeController(useCases: useCases);
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.unreadCount, 5);
  });

  test('refresh keeps the previous count when the fetch fails', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(3));
    final controller = NotificationsBadgeController(useCases: useCases);
    addTearDown(controller.dispose);
    await controller.refresh();

    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.failure('Network error'));
    await controller.refresh();

    expect(controller.unreadCount, 3);
  });

  test('onAuthChanged refreshes from the server when the agent is authenticated', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(4));
    final controller = NotificationsBadgeController(useCases: useCases);
    addTearDown(controller.dispose);
    final auth = AuthController()..debugSetUserData({'id': 'agent-1'});

    controller.onAuthChanged(auth);
    await pumpEventQueue();

    expect(controller.unreadCount, 4);
  });

  test('onAuthChanged resets to 0 on logout, without hitting the server', () async {
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(7));
    final controller = NotificationsBadgeController(useCases: useCases);
    addTearDown(controller.dispose);
    await controller.refresh();
    expect(controller.unreadCount, 7);
    clearInteractions(useCases);

    final auth = AuthController()..debugSetUserData(null);
    controller.onAuthChanged(auth);

    expect(controller.unreadCount, 0);
    verifyNever(() => useCases.getUnreadCount());
  });

  group('keeps the count fresh while signed in (no push needed)', () {
    late _MockNotificationUseCases useCases;
    late ValueNotifier<int> navigation;
    late NotificationsBadgeController controller;
    late AuthController auth;

    // Timers still running when the test body ends fail testWidgets.
    void signOut() => controller.onAuthChanged(AuthController()..debugSetUserData(null));

    setUp(() {
      useCases = _MockNotificationUseCases();
      when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(1));
      navigation = ValueNotifier(0);
      controller = NotificationsBadgeController(useCases: useCases, navigation: navigation);
      auth = AuthController()..debugSetUserData({'id': 'agent-1'});
    });

    tearDown(() {
      controller.dispose();
      navigation.dispose();
    });

    testWidgets('polls every pollInterval', (tester) async {
      controller.onAuthChanged(auth);
      await tester.pump();
      clearInteractions(useCases);

      await tester.pump(NotificationsBadgeController.pollInterval * 2);

      verify(() => useCases.getUnreadCount()).called(2);
      signOut();
    });

    testWidgets('re-fetches on navigation', (tester) async {
      controller.onAuthChanged(auth);
      await tester.pump();
      clearInteractions(useCases);

      navigation.value++;
      await tester.pump();

      verify(() => useCases.getUnreadCount()).called(1);
      signOut();
    });

    testWidgets('stops polling while the tab is hidden and re-fetches when it is visible again', (tester) async {
      controller.onAuthChanged(auth);
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      clearInteractions(useCases);
      await tester.pump(NotificationsBadgeController.pollInterval * 2);
      verifyNever(() => useCases.getUnreadCount());

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      verify(() => useCases.getUnreadCount()).called(1);
      signOut();
    });

    testWidgets('does nothing after logout, and a late fetch cannot bring the old count back', (tester) async {
      final pending = Completer<Result<int>>();
      when(() => useCases.getUnreadCount()).thenAnswer((_) => pending.future);
      controller.onAuthChanged(auth);
      await tester.pump();

      controller.onAuthChanged(AuthController()..debugSetUserData(null));
      pending.complete(const Result.success(9));
      await tester.pump();
      expect(controller.unreadCount, 0);

      clearInteractions(useCases);
      navigation.value++;
      await tester.pump(NotificationsBadgeController.pollInterval * 2);
      verifyNever(() => useCases.getUnreadCount());
    });

    testWidgets('an older fetch landing after a newer one cannot overwrite it', (tester) async {
      final older = Completer<Result<int>>();
      when(() => useCases.getUnreadCount()).thenAnswer((_) => older.future);
      controller.onAuthChanged(auth);
      await tester.pump();

      when(() => useCases.getUnreadCount()).thenAnswer((_) async => const Result.success(0));
      await controller.refresh();
      older.complete(const Result.success(3));
      await tester.pump();

      expect(controller.unreadCount, 0);
      signOut();
    });
  });
}
