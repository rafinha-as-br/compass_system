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

  group('AuthController session validation (CPS-190)', () {
    const agent = {'id': '1', 'name': 'Carlos', 'email': 'c@compass.com'};

    Map<String, dynamic> ok() => {'status': 'success', 'data': agent, 'message': null};

    Map<String, dynamic> failed(int code) =>
        {'status': 'error', 'data': null, 'message': 'x', 'statusCode': code};

    Future<String?> storedToken() => AuthStorageService.instance.getToken();

    setUp(() async {
      await AuthStorageService.instance.saveToken('stored-token');
    });

    test('a valid token reopens the session with the agent data loaded', () async {
      String? sentToken;
      final controller = AuthController(fetchAuthenticatedUser: (token) async {
        sentToken = token;
        return ok();
      });

      await controller.initialize();

      expect(sentToken, 'stored-token');
      expect(controller.isAuthenticated, isTrue);
      expect(controller.userName, 'Carlos');
      expect(controller.hasConnectionError, isFalse);
      expect(await storedToken(), 'stored-token');
    });

    for (final code in [401, 403]) {
      test('a token refused with $code ends the session and removes the token', () async {
        final controller = AuthController(fetchAuthenticatedUser: (_) async => failed(code));

        await controller.initialize();

        expect(controller.isAuthenticated, isFalse);
        expect(controller.userData, isNull);
        expect(controller.hasConnectionError, isFalse);
        expect(await storedToken(), isNull);
      });
    }

    test('an unreachable API keeps the token but exposes no agent data', () async {
      final controller = AuthController(fetchAuthenticatedUser: (_) async => throw Exception('offline'));

      await controller.initialize();

      expect(controller.hasConnectionError, isTrue);
      expect(controller.userData, isNull);
      expect(await storedToken(), 'stored-token');
    });

    test('a server error is not a refusal: the session and token are kept', () async {
      final controller = AuthController(fetchAuthenticatedUser: (_) async => failed(500));

      await controller.initialize();

      expect(controller.hasConnectionError, isTrue);
      expect(await storedToken(), 'stored-token');
    });

    test('a 403 flagged as PASSWORD_CHANGE_REQUIRED does not drop the session', () async {
      late AuthController controller;
      controller = AuthController(fetchAuthenticatedUser: (_) async {
        controller.requirePasswordChange();
        return failed(403);
      });

      await controller.initialize();

      expect(controller.mustChangePassword, isTrue);
      expect(await storedToken(), 'stored-token');
    });

    test('retrySession enters logged in with the agent data once the API is back', () async {
      var apiUp = false;
      final controller = AuthController(
        fetchAuthenticatedUser: (_) async => apiUp ? ok() : throw Exception('offline'),
      );
      await controller.initialize();
      expect(controller.hasConnectionError, isTrue);

      apiUp = true;
      await controller.retrySession();

      expect(controller.hasConnectionError, isFalse);
      expect(controller.userName, 'Carlos');
      expect(await storedToken(), 'stored-token');
    });

    test('retrySession stays on the error while the API is still down and flags the retry', () async {
      final controller = AuthController(fetchAuthenticatedUser: (_) async => throw Exception('offline'));
      await controller.initialize();
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isRetryingSession));

      await controller.retrySession();

      expect(states, [true, false]);
      expect(controller.hasConnectionError, isTrue);
    });

    test('retrySession after a token refusal goes to login', () async {
      var refused = false;
      final controller = AuthController(
        fetchAuthenticatedUser: (_) async => refused ? failed(401) : throw Exception('offline'),
      );
      await controller.initialize();

      refused = true;
      await controller.retrySession();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.hasConnectionError, isFalse);
      expect(await storedToken(), isNull);
    });

    test('logout clears the connection error', () async {
      final controller = AuthController(fetchAuthenticatedUser: (_) async => throw Exception('offline'));
      await controller.initialize();

      await controller.logout();

      expect(controller.hasConnectionError, isFalse);
      expect(controller.isAuthenticated, isFalse);
    });
  });
}
