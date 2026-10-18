import 'package:flutter/foundation.dart';
import 'package:travel_matrix/features/account/data/account_data_source.dart';
import 'package:travel_matrix/features/account/data/account_repository_impl.dart';
import 'package:travel_matrix/features/account/domain/change_password.dart';

class ChangePasswordController extends ChangeNotifier {
  final ChangePassword _changePassword;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  ChangePasswordController({ChangePassword? changePassword})
      : _changePassword = changePassword ??
            ChangePassword(AccountRepositoryImpl(AccountDataSource()));

  /// Returns true on success; otherwise [errorMessage] holds the reason
  /// (e.g. wrong current password).
  Future<bool> submit(String currentPassword, String newPassword) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _changePassword(currentPassword, newPassword);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is StateError ? e.message : 'Failed to change password.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
