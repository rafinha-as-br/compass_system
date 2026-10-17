import 'package:travel_matrix/features/account/domain/account_repository.dart';

class ChangePassword {
  final AccountRepository _repository;

  const ChangePassword(this._repository);

  Future<void> call(String currentPassword, String newPassword) {
    return _repository.changePassword(currentPassword, newPassword);
  }
}
