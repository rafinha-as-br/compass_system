import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/network/jwt_payload_decoder.dart';

/// Builds a fake (unsigned) JWT with the given payload claims, mirroring the
/// header.payload.signature shape without padding — matching how real JWT
/// libraries emit tokens.
String _fakeJwt(Map<String, dynamic> claims) {
  String segment(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

  final header = segment({'alg': 'HS256', 'typ': 'JWT'});
  final payload = segment(claims);
  return '$header.$payload.fake-signature';
}

void main() {
  group('JwtPayloadDecoder', () {
    test('decodes claims from a well-formed token', () {
      final token = _fakeJwt({
        'sub': 'user@example.com',
        'userType': 'CLIENTE',
        'userId': 1,
        'exp': 1999999999,
      });

      final claims = JwtPayloadDecoder.decode(token);

      expect(claims['sub'], 'user@example.com');
      expect(claims['userType'], 'CLIENTE');
      expect(claims['userId'], 1);
      expect(claims['exp'], 1999999999);
    });

    test('throws FormatException for a token without 3 segments', () {
      expect(
        () => JwtPayloadDecoder.decode('not-a-jwt'),
        throwsFormatException,
      );
    });

    test('throws FormatException when the payload is not a JSON object', () {
      final badPayload = base64Url.encode(utf8.encode('"just a string"'));
      final token = 'header.$badPayload.sig';

      expect(() => JwtPayloadDecoder.decode(token), throwsFormatException);
    });
  });

  group('JwtPayloadDecoder.isExpired', () {
    int secondsFromNow(Duration offset) =>
        DateTime.now().toUtc().add(offset).millisecondsSinceEpoch ~/ 1000;

    test('is false when exp is in the future', () {
      final claims = {'exp': secondsFromNow(const Duration(hours: 1))};

      expect(JwtPayloadDecoder.isExpired(claims), isFalse);
    });

    test('is true when exp is in the past', () {
      final claims = {'exp': secondsFromNow(const Duration(hours: -1))};

      expect(JwtPayloadDecoder.isExpired(claims), isTrue);
    });

    test('is true when exp is missing', () {
      expect(JwtPayloadDecoder.isExpired(<String, dynamic>{}), isTrue);
    });

    test('is true when exp is not an int', () {
      expect(JwtPayloadDecoder.isExpired({'exp': 'not-a-number'}), isTrue);
    });
  });
}
