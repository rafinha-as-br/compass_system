import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';

/// Stub compartilhado por testes de widget/golden que precisam de um
/// [AuthRepository] sem rede real — devolve sempre o [result] configurado no
/// login e registra o e-mail recebido.
class StubAuthRepository implements AuthRepository {
  StubAuthRepository(this.result);

  final Result<AuthSession> result;
  String? capturedEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    capturedEmail = email;
    return result;
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    throw UnimplementedError();
  }
}
