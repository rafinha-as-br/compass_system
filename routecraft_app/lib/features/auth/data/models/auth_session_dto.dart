import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';

class AuthSessionDto {
  final String token;
  final String email;
  final String name;

  const AuthSessionDto({required this.token, required this.email, required this.name});

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      token: json['token'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  AuthSession toDomain() {
    return AuthSession(token: token, email: email, name: name);
  }
}
