import 'package:flutter/material.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/usecases/request_password_reset_usecase.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? errorMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ForgotPasswordController extends ChangeNotifier {
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;

  ForgotPasswordController({RequestPasswordResetUseCase? requestPasswordResetUseCase})
      : _requestPasswordResetUseCase = requestPasswordResetUseCase ??
            RequestPasswordResetUseCase(
              AuthRepositoryImpl(AuthRemoteDataSource(HttpApiClient.instance)),
            );

  ForgotPasswordState _state = const ForgotPasswordState();

  ForgotPasswordState get state => _state;

  Future<bool> requestPasswordReset(String email) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    final result = await _requestPasswordResetUseCase(email);

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
