import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login(String email, String password);
  Future<Result<void>> requestPasswordReset(String email);
  Future<Result<void>> resetPassword(String token, String newPassword);
}
