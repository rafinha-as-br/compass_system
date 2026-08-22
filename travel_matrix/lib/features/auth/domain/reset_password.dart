import 'package:travel_matrix/features/auth/domain/auth_repository.dart';

class ResetPassword {
  final AuthRepository _repository;

  const ResetPassword(this._repository);

  Future<void> call(String token, String newPassword) =>
      _repository.resetPassword(token, newPassword);
}
