import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/services/auth_service.dart';

/// Tracks the client's authentication state and drives [AppRouter]'s
/// redirect via `refreshListenable`.
class AuthController extends ChangeNotifier {
  final Future<bool> Function()? _checkAuthenticatedOverride;
  final Future<void> Function()? _clearTokenOverride;

  /// [checkAuthenticated]/[clearToken] are injectable for widget tests,
  /// without depending on the real `AuthService`/secure storage wiring —
  /// `AuthService.instance` is only touched when an override isn't given.
  /// In production, the default constructor is unaffected.
  AuthController({
    Future<bool> Function()? checkAuthenticated,
    Future<void> Function()? clearToken,
  })  : _checkAuthenticatedOverride = checkAuthenticated,
        _clearTokenOverride = clearToken;

  Future<bool> _checkAuthenticated() =>
      (_checkAuthenticatedOverride ?? AuthService.instance.isAuthenticated)();

  Future<void> _clearToken() =>
      (_clearTokenOverride ?? AuthService.instance.clearToken)();

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
    notifyListeners();
  }

  /// Re-checks the stored session. Call after a successful login so the
  /// router's redirect leaves the public routes.
  Future<void> refresh() async {
    _isAuthenticated = await _checkAuthenticated();
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearToken();
    _isAuthenticated = false;
    notifyListeners();
  }
}
