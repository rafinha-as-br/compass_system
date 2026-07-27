import 'package:flutter/material.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/auth/data/auth_data_source.dart';
import 'package:travel_matrix/features/auth/data/auth_repository_impl.dart';
import 'package:travel_matrix/features/auth/domain/login.dart';

class LoginState {
  final bool isLoading;
  final bool showLogin;
  final String? errorMessage;
  GlobalKey formKey;

  LoginState({
    this.isLoading = false,
    this.showLogin = false,
    this.errorMessage,
    GlobalKey<FormState>? formKey,
  }) : formKey = formKey ?? GlobalKey<FormState>();

  LoginState copyWith({
    bool? isLoading,
    bool? showLogin,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      showLogin: showLogin ?? this.showLogin,
      errorMessage: errorMessage,
    );
  }
}

class LoginController extends ChangeNotifier {
  late final Login _login;

  LoginState _state = LoginState();

  LoginState get state => _state;

  LoginController() {
    _login = Login(AuthRepositoryImpl(AuthDataSource()));
  }

  void showLogin() {
    bool showLogin = _state.showLogin ? false : true;
    _state = _state.copyWith(showLogin: showLogin);
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
}
