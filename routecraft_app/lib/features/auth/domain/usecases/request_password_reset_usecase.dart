import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  const RequestPasswordResetUseCase(this._repository);

  Future<Result<void>> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}
