import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';
import 'package:travel_matrix/core/services/web_push_service.dart';

/// Outcome of checking the stored token against the API.
enum _SessionCheck {
  /// The agent's data loaded — the token is valid.
  valid,

  /// The API refused the token (invalid/expired) — the session is over.
  rejected,

  /// The token could not be checked (network failure, API down) — it was not
  /// refused, so the session is kept.
  unavailable,
}

/// Controller responsible for managing authentication state.
class AuthController extends ChangeNotifier {

  AuthController({
    Future<Map<String, dynamic>> Function(String token)? fetchAuthenticatedUser,
  }) : _fetchAuthenticatedUser =
           fetchAuthenticatedUser ?? ((token) => CompassService.instance.getAuthenticatedUser(token));

  final AuthStorageService _storage = AuthStorageService.instance;
  final Future<Map<String, dynamic>> Function(String token) _fetchAuthenticatedUser;

  String? _token;
  Map<String, dynamic>? _userData;

  bool _initialized = false;

  /// The token is stored but the agent's data could not be loaded because the
  /// API was unreachable. The session is kept, the authenticated screens stay
  /// hidden and the connection-error screen offers a retry.
  bool _connectionError = false;
  bool _retryingSession = false;

  bool get hasConnectionError => _connectionError;
  bool get isRetryingSession => _retryingSession;

  /// Agente convidado ainda com a senha temporária. Vem do login ou do 403
  /// PASSWORD_CHANGE_REQUIRED (o flag não sobrevive a um reload, o 403 sim).
  bool _mustChangePassword = false;

  bool get mustChangePassword => _mustChangePassword;

  bool get initialized => _initialized;

  bool get isAuthenticated => _token != null;
  
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get userName => _userData?['name'] as String?;
  String? get userEmail => _userData?['email'] as String?;
  String? get userId => _userData?['id'] as String?;

  /// Display name for the authenticated agent: the name when set, the
  /// email otherwise. Empty string when neither is available.
  String get agentDisplayName {
    final name = userName;
    if (name != null && name.isNotEmpty) return name;
    return userEmail ?? '';
  }

  Future<void> initialize() async {
    HttpApiClient.onPasswordChangeRequired = requirePasswordChange;
    _token = await _storage.getToken();
    if (_token != null) {
      await _validateSession();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token, {bool mustChangePassword = false}) async {
    _token = token;
    _mustChangePassword = mustChangePassword;
    await _storage.saveToken(token);
    await _validateSession();
    notifyListeners();
  }

  /// Tries again after the connection-error screen: re-checks the stored
  /// token. On success the router leaves the screen; on another failure it
  /// stays.
  Future<void> retrySession() async {
    if (_token == null || _retryingSession) return;
    _retryingSession = true;
    notifyListeners();
    try {
      await _validateSession();
    } finally {
      _retryingSession = false;
      notifyListeners();
    }
  }

  /// Checks the token by loading the agent's data and applies the outcome: a
  /// refused token ends the session, an unreachable API keeps it behind the
  /// connection-error screen. The app is never left authenticated without the
  /// agent's data.
  Future<void> _validateSession() async {
    switch (await _loadUserData()) {
      case _SessionCheck.valid:
        _connectionError = false;
        unawaited(WebPushService.instance.registerForPush());
      case _SessionCheck.rejected:
        _connectionError = false;
        _token = null;
        _userData = null;
        _mustChangePassword = false;
        await _storage.clearToken();
      case _SessionCheck.unavailable:
        _connectionError = true;
    }
  }

  /// Roteia para a troca de senha obrigatória (o router reage ao notify).
  void requirePasswordChange() {
    if (_token == null || _mustChangePassword) return;
    _mustChangePassword = true;
    notifyListeners();
  }

  void passwordChanged() {
    _mustChangePassword = false;
    notifyListeners();
  }

  Future<_SessionCheck> _loadUserData() async {
    final currentToken = _token;
    if (currentToken == null) {
      _userData = null;
      return _SessionCheck.rejected;
    }

    try {
      final response = await _fetchAuthenticatedUser(currentToken);
      final data = response['data'];
      if (response['status'] == 'success' && data is Map<String, dynamic>) {
        _userData = data;
        return _SessionCheck.valid;
      }
      _userData = null;
      // 401/403 is how the API refuses an invalid or expired token. A 403 that
      // came with PASSWORD_CHANGE_REQUIRED (flagged by the HTTP client while
      // the request ran) is a valid token waiting on its password change, not
      // a refusal.
      final refused = response['statusCode'] == 401 || response['statusCode'] == 403;
      return refused && !_mustChangePassword ? _SessionCheck.rejected : _SessionCheck.unavailable;
    } catch (_) {
      _userData = null;
      return _SessionCheck.unavailable;
    }
  }

  Future<void> logout() async {
    // Before clearing the token — the unregister DELETE needs a still-valid
    // Bearer token.
    await WebPushService.instance.unregisterFromPush();
    _token = null;
    _userData = null;
    _mustChangePassword = false;
    _connectionError = false;
    await _storage.clearToken();
    notifyListeners();
  }

  /// Seeds [userData] directly, bypassing [initialize]/[login]'s network
  /// call. Only meant for widget tests that need an authenticated agent.
  @visibleForTesting
  void debugSetUserData(Map<String, dynamic>? data) {
    _token = data != null ? 'debug-token' : null;
    _userData = data;
    _initialized = true;
  }
}
