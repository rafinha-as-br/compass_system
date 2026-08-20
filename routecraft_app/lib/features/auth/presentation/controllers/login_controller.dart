import 'package:flutter/material.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/usecases/login_usecase.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LoginController extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final Future<void> Function(String token) _saveToken;

  LoginController({
    LoginUseCase? loginUseCase,
    Future<void> Function(String token)? saveToken,
  })  : _loginUseCase = loginUseCase ??
            LoginUseCase(
              AuthRepositoryImpl(
                AuthRemoteDataSource(HttpApiClient.instance),
              ),
            ),
        _saveToken = saveToken ?? AuthService.instance.saveToken;

  LoginState _state = const LoginState();

  LoginState get state => _state;

  Future<bool> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    final result = await _loginUseCase(email, password);

    switch (result) {
      case Success<AuthSession>(data: final session):
        await _saveToken(session.token);
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return true;
      case Failure<AuthSession>(message: final message):
        _state = _state.copyWith(isLoading: false, errorMessage: message);
        notifyListeners();
        return false;
    }
  }
}
