import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/data/repositories/client_profile_repository_impl.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/domain/usecases/client_profile_usecases.dart';

class PersonalDataState {
  final bool isLoading;
  final ClientProfile? profile;
  final String? errorMessage;
  final bool isConnectivityError;
  final bool isSaving;
  final bool isResettingPassword;

  const PersonalDataState({
    this.isLoading = true,
    this.profile,
    this.errorMessage,
    this.isConnectivityError = false,
    this.isSaving = false,
    this.isResettingPassword = false,
  });

  PersonalDataState copyWith({
    bool? isLoading,
    ClientProfile? profile,
    String? errorMessage,
    bool? isConnectivityError,
    bool? isSaving,
    bool? isResettingPassword,
  }) {
    return PersonalDataState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isConnectivityError: isConnectivityError ?? false,
      isSaving: isSaving ?? this.isSaving,
      isResettingPassword: isResettingPassword ?? this.isResettingPassword,
    );
  }
}

class PersonalDataController extends ChangeNotifier {
  PersonalDataState _state = const PersonalDataState();
  PersonalDataState get state => _state;

  final ClientProfileUseCases? _useCasesOverride;

  /// [useCases] is injectable for tests, without depending on the real
  /// network/singleton wiring.
  PersonalDataController({ClientProfileUseCases? useCases}) : _useCasesOverride = useCases {
    _fetchProfile();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  PersonalDataController.withState(this._state) : _useCasesOverride = null;

  ClientProfileUseCases get _useCases =>
      _useCasesOverride ?? ClientProfileUseCases(ClientProfileRepositoryImpl());

  Future<void> _fetchProfile() async {
    _state = const PersonalDataState(isLoading: true);
    notifyListeners();

    final result = await _useCases.getCurrentUser();
    switch (result) {
      case Success<ClientProfile>(data: final profile):
        _state = PersonalDataState(isLoading: false, profile: profile);
      case Failure<ClientProfile>(message: final message, isConnectivityError: final isConnectivityError):
        _state = PersonalDataState(isLoading: false, errorMessage: message, isConnectivityError: isConnectivityError);
    }
    notifyListeners();
  }

  /// Persists the four editable fields via `PUT /users/{id}`. Returns
  /// whether the save succeeded — the page decides how to react (SnackBar,
  /// staying on the form).
  Future<bool> save({
    required String name,
    required String phoneNumber,
    required int? age,
    required String sex,
  }) async {
    final current = _state.profile;
    if (current == null) return false;

    _state = _state.copyWith(isSaving: true, errorMessage: null);
    notifyListeners();

    final updated = current.copyWith(name: name, phoneNumber: phoneNumber, age: age, sex: sex);
    final result = await _useCases.updateUser(updated);

    switch (result) {
      case Success<ClientProfile>(data: final profile):
        _state = PersonalDataState(isLoading: false, profile: profile);
        notifyListeners();
        return true;
      case Failure<ClientProfile>(message: final message, isConnectivityError: final isConnectivityError):
        _state = _state.copyWith(isSaving: false, errorMessage: message, isConnectivityError: isConnectivityError);
        notifyListeners();
        return false;
    }
  }

  /// Resets the client's own password to the backend default via
  /// `POST /users/{id}/reset-password`. Returns whether it succeeded.
  Future<bool> resetPassword() async {
    final id = _state.profile?.id;
    if (id == null) return false;

    _state = _state.copyWith(isResettingPassword: true, errorMessage: null);
    notifyListeners();

    final result = await _useCases.resetPassword(id);

    switch (result) {
      case Success<void>():
        _state = _state.copyWith(isResettingPassword: false);
        notifyListeners();
        return true;
      case Failure<void>(message: final message, isConnectivityError: final isConnectivityError):
        _state = _state.copyWith(
          isResettingPassword: false,
          errorMessage: message,
          isConnectivityError: isConnectivityError,
        );
        notifyListeners();
        return false;
    }
  }
}
