import 'dart:convert';

/// Decodes the payload of a JWT without verifying its signature — signature
/// verification is the backend's responsibility. Only used client-side to
/// read claims (userType, exp) for UX purposes.
abstract final class JwtPayloadDecoder {
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Token JWT malformado.');
    }

    final payload = utf8.decode(base64Url.decode(_normalize(parts[1])));
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Payload do token JWT inválido.');
    }
    return decoded;
  }

  /// True when the `exp` claim (JWT NumericDate: seconds since the Unix
  /// epoch) is missing, malformed, or in the past.
  static bool isExpired(Map<String, dynamic> claims) {
    final exp = claims['exp'];
    if (exp is! int) return true;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiresAt);
  }

  static String _normalize(String input) {
    final remainder = input.length % 4;
    if (remainder == 0) return input;
    return input.padRight(input.length + (4 - remainder), '=');
  }
}
