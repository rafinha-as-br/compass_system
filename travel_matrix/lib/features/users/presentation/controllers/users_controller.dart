import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/features/users/data/user_client_data_source.dart';
import 'package:travel_matrix/features/users/data/user_repository_impl.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';

import '../../../../core/services/auth_storage_service.dart';

class UsersState {
  final bool isLoading;
  final List<UserClientViewModel> users;
  final String? errorMessage;

  const UsersState({
    this.isLoading = true,
    this.users = const [],
    this.errorMessage,
  });

  UsersState copyWith({
    bool? isLoading,
    List<UserClientViewModel>? users,
    String? errorMessage,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

class UsersController extends ChangeNotifier {
  final UserUseCases _useCases;

  UsersState _state = const UsersState();
  UsersState get state => _state;

  UsersController({UserUseCases? useCases})
      : _useCases =
            useCases ?? UserUseCases(UserClientRepositoryImpl(UserClientDataSource())) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) {
        _state = _state.copyWith(
            isLoading: false,
            errorMessage: 'Not authenticated.');
        notifyListeners();
        return;
      }

      final result = await _useCases.getAllUsers();

      if (result.isSuccess && result.data != null) {
        final clients = result.data!
            .map((e) => UserClientViewModel.fromDomain(user: e))
            .toList();
        _state = UsersState(isLoading: false, users: clients);
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: result.error,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch users: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> deactivateUser(String userId, String reason) async {
    try {
      final result = await _useCases.deactivateUser(userId, reason);
      if (result.isSuccess) {
        await fetchUsers();
        return true;
      }
      _state = _state.copyWith(errorMessage: result.error);
      notifyListeners();
      return false;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to deactivate user: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String userId) async {
    try {
      final result = await _useCases.resetPassword(userId);
      if (!result.isSuccess) {
        _state = _state.copyWith(errorMessage: result.error);
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to reset password: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> forceLogout(String userId) async {
    try {
      final result = await _useCases.forceLogout(userId);
      if (!result.isSuccess) {
        _state = _state.copyWith(errorMessage: result.error);
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to force logout: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.createUser(token, userData);
      if (response['status'] == 'success') {
        await fetchUsers();
        return true;
      }
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: response['message'] as String?,
      );
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.updateUser(token, userData);
      if (response['status'] == 'success') {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
