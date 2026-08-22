import 'package:travel_matrix/features/auth/domain/auth_repository.dart';

class RequestPasswordReset {
  final AuthRepository _repository;

  const RequestPasswordReset(this._repository);

  Future<void> call(String email) => _repository.requestPasswordReset(email);
}
