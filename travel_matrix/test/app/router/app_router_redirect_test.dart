import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/app/router/app_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';

String? _redirect({
  required bool isAuth,
  bool mustChangePassword = false,
  bool connectionError = false,
  required String location,
}) {
  return AppRouter.redirectFor(
    isAuth: isAuth,
    mustChangePassword: mustChangePassword,
    connectionError: connectionError,
    location: location,
  );
}

void main() {
  group('AppRouter.redirectFor', () {
    test('unauthenticated users are sent to the landing page', () {
      expect(_redirect(isAuth: false, location: AppRoutes.dashboard), AppRoutes.landing);
      expect(_redirect(isAuth: false, location: AppRoutes.changePassword), AppRoutes.landing);
      expect(_redirect(isAuth: false, location: AppRoutes.landing), isNull);
    });

    test('authenticated users skip the landing page', () {
      expect(_redirect(isAuth: true, location: AppRoutes.landing), AppRoutes.dashboard);
      expect(_redirect(isAuth: true, location: AppRoutes.travels), isNull);
    });

    test('an agent with a pending password change is locked to the change-password screen', () {
      for (final location in [
        AppRoutes.landing,
        AppRoutes.dashboard,
        AppRoutes.travels,
        AppRoutes.company,
        AppRoutes.account,
        AppRoutes.notifications,
      ]) {
        expect(
          _redirect(isAuth: true, mustChangePassword: true, location: location),
          AppRoutes.changePassword,
          reason: location,
        );
      }
      expect(
        _redirect(isAuth: true, mustChangePassword: true, location: AppRoutes.changePassword),
        isNull,
      );
    });

    test('after the change, the agent leaves the change-password screen', () {
      expect(_redirect(isAuth: true, location: AppRoutes.changePassword), AppRoutes.dashboard);
    });

    test('a session whose agent data could not load is locked to the connection-error screen', () {
      for (final location in [
        AppRoutes.landing,
        AppRoutes.dashboard,
        AppRoutes.travels,
        AppRoutes.account,
        AppRoutes.changePassword,
      ]) {
        expect(
          _redirect(isAuth: true, connectionError: true, location: location),
          AppRoutes.connectionError,
          reason: location,
        );
      }
      expect(
        _redirect(isAuth: true, connectionError: true, location: AppRoutes.connectionError),
        isNull,
      );
    });

    test('once the retry succeeds, the agent leaves the connection-error screen', () {
      expect(_redirect(isAuth: true, location: AppRoutes.connectionError), AppRoutes.dashboard);
    });

    test('without a session the connection-error screen goes to the landing page', () {
      expect(_redirect(isAuth: false, location: AppRoutes.connectionError), AppRoutes.landing);
    });
  });
}
