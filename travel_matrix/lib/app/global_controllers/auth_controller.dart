import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';
import 'package:travel_matrix/core/services/web_push_service.dart';

/// Controller responsible for managing authentication state.
class AuthController extends ChangeNotifier {

  final AuthStorageService _storage = AuthStorageService.instance;

  String? _token;
  Map<String, dynamic>? _userData;

  bool _initialized = false;

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
      await loadUserData();
      unawaited(WebPushService.instance.registerForPush());
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token, {bool mustChangePassword = false}) async {
    _token = token;
    _mustChangePassword = mustChangePassword;
    await _storage.saveToken(token);
    await loadUserData();
    notifyListeners();
    unawaited(WebPushService.instance.registerForPush());
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

  Future<void> loadUserData() async {
    final currentToken = _token;
    if (currentToken == null) {
      _userData = null;
      return;
    }

    try {
      final response =
          await CompassService.instance.getAuthenticatedUser(currentToken);
      if (response['status'] == 'success') {
        _userData = response['data'] as Map<String, dynamic>?;
      }
    } catch (_) {
      _userData = null;
    }
  }

  Future<void> logout() async {
    // Before clearing the token — the unregister DELETE needs a still-valid
    // Bearer token.
    await WebPushService.instance.unregisterFromPush();
    _token = null;
    _userData = null;
    _mustChangePassword = false;
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
