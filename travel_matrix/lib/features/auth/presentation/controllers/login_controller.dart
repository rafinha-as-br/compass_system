import 'package:flutter/material.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/auth/data/auth_data_source.dart';
import 'package:travel_matrix/features/auth/data/auth_repository_impl.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/login.dart';
import 'package:travel_matrix/features/auth/domain/request_password_reset.dart';
import 'package:travel_matrix/features/auth/domain/reset_password.dart';

/// Right-side panel currently shown on the auth landing page.
enum AuthPanel { welcome, login, forgotPassword, resetPassword }

class LoginState {
  final bool isLoading;
  final AuthPanel panel;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.panel = AuthPanel.login,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    AuthPanel? panel,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      panel: panel ?? this.panel,
      errorMessage: errorMessage,
    );
  }
}

class LoginController extends ChangeNotifier {
  final Login _login;
  final RequestPasswordReset _requestPasswordReset;
  final ResetPassword _resetPassword;

  LoginState _state = const LoginState();

  LoginState get state => _state;

  /// [repository] é injetável para permitir testes unitários com um
  /// [AuthRepository] fake, sem depender de rede/singletons concretos. Como
  /// os três casos de uso compartilham o mesmo repositório, injetar um fake
  /// aqui cobre login, esqueci-senha e redefinir-senha de uma vez. Em
  /// produção, o call site (`LoginController()`) continua igual — a wiring
  /// padrão é usada como valor default.
  LoginController({AuthRepository? repository})
    : _login = Login(repository ?? AuthRepositoryImpl(AuthDataSource())),
      _requestPasswordReset = RequestPasswordReset(
        repository ?? AuthRepositoryImpl(AuthDataSource()),
      ),
      _resetPassword = ResetPassword(repository ?? AuthRepositoryImpl(AuthDataSource()));

  /// Toggles between the welcome and login panels.
  void showLogin() {
    final panel = _state.panel == AuthPanel.welcome ? AuthPanel.login : AuthPanel.welcome;
    _state = _state.copyWith(panel: panel, errorMessage: null);
    notifyListeners();
  }

  void showForgotPassword() {
    _state = _state.copyWith(panel: AuthPanel.forgotPassword, errorMessage: null);
    notifyListeners();
  }

  void showResetPassword() {
    _state = _state.copyWith(panel: AuthPanel.resetPassword, errorMessage: null);
    notifyListeners();
  }

  void showLoginPanel() {
    _state = _state.copyWith(panel: AuthPanel.login, errorMessage: null);
    notifyListeners();
  }

  Future<Result<String>> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final session = await _login(email, password);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return Result.success(session.token);
    } catch (e) {
      final message = e is StateError ? e.message : 'An error occurred during login.';
      _state = _state.copyWith(isLoading: false, errorMessage: message);
      notifyListeners();
      return Result.failure(message);
    }
  }

  Future<Result<String>> requestPasswordReset(String email) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _requestPasswordReset(email);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return const Result.success('');
    } catch (e) {
      final message = e is StateError ? e.message : 'An error occurred. Please try again.';
      _state = _state.copyWith(isLoading: false, errorMessage: message);
      notifyListeners();
      return Result.failure(message);
    }
  }

  Future<Result<String>> resetPassword(String token, String newPassword) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _resetPassword(token, newPassword);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return const Result.success('');
    } catch (e) {
      final message = e is StateError ? e.message : 'An error occurred. Please try again.';
      _state = _state.copyWith(isLoading: false, errorMessage: message);
      notifyListeners();
      return Result.failure(message);
    }
  }
}
