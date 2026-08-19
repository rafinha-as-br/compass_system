import 'package:flutter/material.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/datasources/client_registration_remote_datasource.dart';
import 'package:routecraft_app/features/auth/data/repositories/client_registration_repository_impl.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/domain/usecases/register_client_usecase.dart';

class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class RegisterController extends ChangeNotifier {
  final RegisterClientUseCase _registerUseCase;

  RegisterController({RegisterClientUseCase? registerUseCase})
      : _registerUseCase = registerUseCase ??
            RegisterClientUseCase(
              ClientRegistrationRepositoryImpl(
                ClientRegistrationRemoteDataSource(HttpApiClient.instance),
              ),
            );

  RegisterState _state = const RegisterState();

  RegisterState get state => _state;

  Future<bool> register(ClientRegistration registration) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    final result = await _registerUseCase(registration);

    switch (result) {
      case Success<String>():
        _state = _state.copyWith(isLoading: false, isSuccess: true);
        notifyListeners();
        return true;
      case Failure<String>(message: final message):
        _state = _state.copyWith(isLoading: false, errorMessage: message);
        notifyListeners();
        return false;
    }
  }
}
