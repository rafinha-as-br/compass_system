import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<Result<void>> call(String token, String newPassword) {
    return _repository.resetPassword(token, newPassword);
  }
}
