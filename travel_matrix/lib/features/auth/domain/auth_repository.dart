import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String token, String newPassword);
}
