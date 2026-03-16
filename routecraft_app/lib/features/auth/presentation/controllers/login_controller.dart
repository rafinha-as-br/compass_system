import 'package:flutter/material.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/core/services/compass_service.dart';

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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginController extends ChangeNotifier {
  LoginState _state = const LoginState();

  LoginState get state => _state;

  Future<bool> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final user = await CompassService.instance.login(email, password);
      
      if (user != null) {
        // Here we simulate getting a token from the backend
        await AuthService.instance.saveToken('dummy_token_${user.id}');
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid credentials. Please try again.',
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred during login.',
      );
      notifyListeners();
      return false;
    }
  }
}
