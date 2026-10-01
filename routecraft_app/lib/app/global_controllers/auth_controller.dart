import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/core/services/push_service.dart';

/// Tracks the client's authentication state and drives [AppRouter]'s
/// redirect via `refreshListenable`.
class AuthController extends ChangeNotifier {
  final Future<bool> Function()? _checkAuthenticatedOverride;
  final Future<void> Function()? _clearTokenOverride;
  final Future<void> Function()? _registerForPushOverride;
  final Future<void> Function()? _unregisterFromPushOverride;

  /// [checkAuthenticated]/[clearToken]/[registerForPush]/[unregisterFromPush]
  /// are injectable for widget tests, without depending on the real
  /// `AuthService`/`PushService`/secure storage wiring — the real singletons
  /// are only touched when an override isn't given. In production, the
  /// default constructor is unaffected.
  AuthController({
    Future<bool> Function()? checkAuthenticated,
    Future<void> Function()? clearToken,
    Future<void> Function()? registerForPush,
    Future<void> Function()? unregisterFromPush,
  })  : _checkAuthenticatedOverride = checkAuthenticated,
        _clearTokenOverride = clearToken,
        _registerForPushOverride = registerForPush,
        _unregisterFromPushOverride = unregisterFromPush;

  Future<bool> _checkAuthenticated() =>
      (_checkAuthenticatedOverride ?? AuthService.instance.isAuthenticated)();

  Future<void> _clearToken() =>
      (_clearTokenOverride ?? AuthService.instance.clearToken)();

  Future<void> _registerForPush() =>
      (_registerForPushOverride ?? PushService.instance.registerForPush)();

  Future<void> _unregisterFromPush() =>
      (_unregisterFromPushOverride ?? PushService.instance.unregisterFromPush)();

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Resolves the initial auth state. Keeps the splash visible for at least
  /// [minSplashDuration] so the brand moment isn't a flash on a fast device.
  Future<void> initialize({
    Duration minSplashDuration = const Duration(seconds: 2),
  }) async {
    final results = await Future.wait([
      _checkAuthenticated(),
      Future.delayed(minSplashDuration),
    ]);
    _isAuthenticated = results[0] as bool;
    if (_isAuthenticated) {
      // Fire-and-forget: the plugin's own contract expects registration to
      // be (re-)requested on every launch, but a slow/failed one never
      // blocks the splash screen (CPS-148).
      unawaited(_registerForPush());
    }
    notifyListeners();
  }

  /// Re-checks the stored session. Call after a successful login so the
  /// router's redirect leaves the public routes.
  Future<void> refresh() async {
    _isAuthenticated = await _checkAuthenticated();
    notifyListeners();
  }

  Future<void> logout() async {
    // Must run before the token is cleared — unregistering needs a
    // still-valid Bearer token to authenticate the DELETE call (CPS-148).
    await _unregisterFromPush();
    await _clearToken();
    _isAuthenticated = false;
    notifyListeners();
  }
}
