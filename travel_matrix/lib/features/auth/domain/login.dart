import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';

class Login {
  final AuthRepository _repository;

  const Login(this._repository);

  Future<AuthSession> call(String email, String password) async {
    final session = await _repository.login(email, password);

    // Travel Matrix is only for Travel Agents
    if (session.userType != 'AGENTE') {
      throw StateError('Access denied. Only Travel Agents can access Travel Matrix.');
    }

    return session;
  }
}
