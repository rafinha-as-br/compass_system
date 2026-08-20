import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static AuthService? _instance;
  final FlutterSecureStorage _storage;

  AuthService._() : _storage = const FlutterSecureStorage();

  static Future<AuthService> init() async {
    _instance ??= AuthService._();
    return _instance!;
  }

  static AuthService get instance {
    assert(_instance != null, 'AuthService instance not initialized!');
    return _instance!;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
