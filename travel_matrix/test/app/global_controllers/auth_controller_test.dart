import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
  });

  group('AuthController mustChangePassword', () {
    test('requirePasswordChange flags an authenticated agent and notifies', () {
      final controller = AuthController();
      controller.debugSetUserData({'id': '1', 'name': 'Carlos', 'email': 'c@compass.com'});
      var notified = 0;
      controller.addListener(() => notified++);

      controller.requirePasswordChange();

      expect(controller.mustChangePassword, isTrue);
      expect(notified, 1);
    });

    test('requirePasswordChange is ignored without a session', () {
      final controller = AuthController();

      controller.requirePasswordChange();

      expect(controller.mustChangePassword, isFalse);
    });

    test('passwordChanged clears the flag', () {
      final controller = AuthController();
      controller.debugSetUserData({'id': '1'});
      controller.requirePasswordChange();

      controller.passwordChanged();

      expect(controller.mustChangePassword, isFalse);
    });
  });

  group('AuthController agent info', () {
    test('userId reads the id from userData', () {
      final controller = AuthController();
      controller.debugSetUserData({'id': 'agent-42', 'name': 'Carlos', 'email': 'carlos@compass.com'});

      expect(controller.userId, 'agent-42');
    });

    test('userId is null when there is no authenticated user', () {
      final controller = AuthController();

      expect(controller.userId, isNull);
    });

    test('agentDisplayName prefers the name when it is set', () {
      final controller = AuthController();
      controller.debugSetUserData({'id': '1', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

      expect(controller.agentDisplayName, 'Carlos Agent');
    });

    test('agentDisplayName falls back to the email when the name is empty', () {
      final controller = AuthController();
      controller.debugSetUserData({'id': '1', 'name': '', 'email': 'carlos@compass.com'});

      expect(controller.agentDisplayName, 'carlos@compass.com');
    });

    test('agentDisplayName is empty when there is no authenticated user', () {
      final controller = AuthController();

      expect(controller.agentDisplayName, '');
    });
  });
}
