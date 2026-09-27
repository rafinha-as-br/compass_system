import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';

void main() {
  group('AuthController.initialize', () {
    test('sets isAuthenticated from the injected check', () async {
      final controller = AuthController(
        checkAuthenticated: () async => true,
        registerForPush: () async {},
      );

      await controller.initialize(minSplashDuration: Duration.zero);

      expect(controller.isAuthenticated, isTrue);
    });

    test('notifies listeners once resolved', () async {
      final controller = AuthController(checkAuthenticated: () async => false);
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.initialize(minSplashDuration: Duration.zero);

      expect(notified, 1);
      expect(controller.isAuthenticated, isFalse);
    });

    test('waits for at least minSplashDuration even when the check resolves instantly', () async {
      final controller = AuthController(
        checkAuthenticated: () async => true,
        registerForPush: () async {},
      );
      final stopwatch = Stopwatch()..start();

      await controller.initialize(minSplashDuration: const Duration(milliseconds: 50));

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(50));
    });

    test('registers for push when a session is already authenticated', () async {
      var registered = false;
      final controller = AuthController(
        checkAuthenticated: () async => true,
        registerForPush: () async => registered = true,
      );

      await controller.initialize(minSplashDuration: Duration.zero);

      expect(registered, isTrue);
    });

    test('does not register for push when there is no session', () async {
      var registered = false;
      final controller = AuthController(
        checkAuthenticated: () async => false,
        registerForPush: () async => registered = true,
      );

      await controller.initialize(minSplashDuration: Duration.zero);

      expect(registered, isFalse);
    });
  });

  group('AuthController.refresh', () {
    test('re-reads the session and notifies listeners', () async {
      var isAuthenticated = false;
      final controller = AuthController(checkAuthenticated: () async => isAuthenticated);
      await controller.initialize(minSplashDuration: Duration.zero);
      expect(controller.isAuthenticated, isFalse);

      isAuthenticated = true;
      await controller.refresh();

      expect(controller.isAuthenticated, isTrue);
    });
  });

  group('AuthController.logout', () {
    test('clears the token and sets isAuthenticated to false', () async {
      var cleared = false;
      final controller = AuthController(
        checkAuthenticated: () async => true,
        registerForPush: () async {},
        clearToken: () async => cleared = true,
        unregisterFromPush: () async {},
      );
      await controller.initialize(minSplashDuration: Duration.zero);
      expect(controller.isAuthenticated, isTrue);

      await controller.logout();

      expect(cleared, isTrue);
      expect(controller.isAuthenticated, isFalse);
    });

    test('unregisters from push before clearing the token', () async {
      final order = <String>[];
      final controller = AuthController(
        checkAuthenticated: () async => false,
        clearToken: () async => order.add('clearToken'),
        unregisterFromPush: () async => order.add('unregisterFromPush'),
      );

      await controller.logout();

      expect(order, ['unregisterFromPush', 'clearToken']);
    });
  });
}
