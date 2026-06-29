import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for storing and retrieving authentication tokens from SharedPreferences.
class AuthStorageService {
  static AuthStorageService? _instance;
  late final SharedPreferences _prefs;

  AuthStorageService._();

  static Future<AuthStorageService> init() async {
    if (_instance == null) {
      _instance = AuthStorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  static AuthStorageService get instance {
    assert(_instance != null, 'AuthService instance not initialized!');
    return _instance!;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
