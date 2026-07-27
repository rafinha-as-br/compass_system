import 'package:flutter/material.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

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
  LoginState _state = LoginState();

  LoginState get state => _state;

  LoginController();

  void showLogin() {
    bool showLogin = _state.showLogin ? false : true;
    _state = _state.copyWith(showLogin: showLogin);
    notifyListeners();
  }

  Future<Result<String>> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await CompassService.instance.login(email, password);

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final userType = data['userType'] as String;
        final token = data['token'] as String;

        // Travel Matrix is only for Travel Agents
        if (userType != 'AGENTE') {
          const message = 'Access denied. Only Travel Agents can access Travel Matrix.';
          _state = _state.copyWith(isLoading: false, errorMessage: message);
          notifyListeners();
          return const Result.failure(message);
        }

        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return Result.success(token);
      } else {
        final message = response['message'] as String? ?? 'Invalid credentials. Please try again.';
        _state = _state.copyWith(isLoading: false, errorMessage: message);
        notifyListeners();
        return Result.failure(message);
      }
    } catch (e) {
      const message = 'An error occurred during login.';
      _state = _state.copyWith(isLoading: false, errorMessage: message);
      notifyListeners();
      return const Result.failure(message);
    }
  }
}
