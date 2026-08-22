import 'package:flutter/material.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/usecases/reset_password_usecase.dart';

class ResetPasswordState {
  final bool isLoading;
  final String? errorMessage;

  const ResetPasswordState({
    this.isLoading = false,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ResetPasswordController extends ChangeNotifier {
  final ResetPasswordUseCase _resetPasswordUseCase;

  ResetPasswordController({ResetPasswordUseCase? resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase ??
            ResetPasswordUseCase(
              AuthRepositoryImpl(AuthRemoteDataSource(HttpApiClient.instance)),
            );

  ResetPasswordState _state = const ResetPasswordState();

  ResetPasswordState get state => _state;

  Future<bool> resetPassword(String token, String newPassword) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    final result = await _resetPasswordUseCase(token, newPassword);

    switch (result) {
      case Success<void>():
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return true;
      case Failure<void>(message: final message):
        _state = _state.copyWith(isLoading: false, errorMessage: message);
        notifyListeners();
        return false;
    }
  }
}
