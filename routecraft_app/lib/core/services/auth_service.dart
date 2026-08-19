import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:routecraft_app/core/network/jwt_payload_decoder.dart';

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

  /// True when there is a stored token that is well-formed and not expired.
  /// An expired or malformed token is treated as no session and is cleared.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final claims = _decodeClaims(token);
    if (claims == null || JwtPayloadDecoder.isExpired(claims)) {
      await clearToken();
      return false;
    }

    return true;
  }

  /// Reads the `userType` claim (AGENTE/CLIENTE) from the stored JWT.
  /// Returns null when there is no session or the token is malformed.
  Future<String?> getUserType() async {
    final token = await getToken();
    if (token == null) return null;

    final claims = _decodeClaims(token);
    return claims?['userType'] as String?;
  }

  Map<String, dynamic>? _decodeClaims(String token) {
    try {
      return JwtPayloadDecoder.decode(token);
    } on FormatException {
      return null;
    }
  }
}
