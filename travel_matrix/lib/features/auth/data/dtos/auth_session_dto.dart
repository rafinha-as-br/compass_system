import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';

class AuthSessionDto {
  final String token;
  final String userType;
  final bool mustChangePassword;

  const AuthSessionDto({
    required this.token,
    required this.userType,
    this.mustChangePassword = false,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      token: json['token'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  AuthSession toDomain() {
    return AuthSession(
      token: token,
      userType: userType,
      mustChangePassword: mustChangePassword,
    );
  }
}
