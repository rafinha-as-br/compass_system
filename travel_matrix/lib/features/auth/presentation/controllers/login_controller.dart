import 'package:flutter/material.dart';
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

  void showLogin() {
    bool showLogin = _state.showLogin ? false : true;
    _state = _state.copyWith(showLogin: showLogin);
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
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
          _state = _state.copyWith(
            isLoading: false,
            errorMessage: 'Access denied. Only Travel Agents can access Travel Matrix.',
          );
          notifyListeners();
          return null;
        }

        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return token;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: response['message'] as String? ?? 'Invalid credentials. Please try again.',
        );
        notifyListeners();
        return null;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred during login.',
      );
      notifyListeners();
      return null;
    }
  }
}
