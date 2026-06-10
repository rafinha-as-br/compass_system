import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

/// Controller responsible for managing authentication state.
class AuthController extends ChangeNotifier {

  final AuthStorageService _storage = AuthStorageService.instance;

  String? _token;
  Map<String, dynamic>? _userData;

  bool _initialized = false;

  bool get initialized => _initialized;

  bool get isAuthenticated => _token != null;
  
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get userName => _userData?['name'] as String?;
  String? get userEmail => _userData?['email'] as String?;

  Future<void> initialize() async {
    _token = await _storage.getToken();
    if (_token != null) {
      await loadUserData();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token) async {
    _token = token;
    await _storage.saveToken(token);
    await loadUserData();
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
    _token = null;
    _userData = null;
    await _storage.clearToken();
    notifyListeners();
  }
}
