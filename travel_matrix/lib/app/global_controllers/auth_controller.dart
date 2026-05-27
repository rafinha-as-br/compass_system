import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';

/// Controller responsible for managing authentication state.
class AuthController extends ChangeNotifier {

  final AuthStorageService _storage = AuthStorageService.instance;

  String? _token;

  bool _initialized = false;

  bool get initialized => _initialized;

  bool get isAuthenticated => _token != null;
  
  String? get token => _token;

  Future<void> initialize() async {
    _token = await _storage.getToken();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String token) async {
    _token = token;
    await _storage.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await _storage.clearToken();
    notifyListeners();
  }
}