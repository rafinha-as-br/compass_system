import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

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
  LoginState _state = const LoginState();

  LoginState get state => _state;

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
        if (userType != 'travel_agent') {
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
