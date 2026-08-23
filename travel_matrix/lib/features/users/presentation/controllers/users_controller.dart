import 'package:flutter/material.dart';
import 'package:travel_matrix/features/users/data/user_client_data_source.dart';
import 'package:travel_matrix/features/users/data/user_repository_impl.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:uuid/uuid.dart';

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

  /// Creates a client user from the raw form data built by
  /// [CreateUserPage] (`name`, `cpf`, `email`, `phoneNumber`, `password`,
  /// `sex`, `birthDate`, `isActive`) — bypasses [UserDTO]'s json mapping on
  /// the way in only for the fields it doesn't otherwise carry.
  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final newUser = UserClient(
        backEndId: null,
        domainId: const Uuid().v4(),
        name: userData['name'] as String? ?? '',
        cpf: userData['cpf'] as String? ?? '',
        sex: userData['sex'] as String? ?? 'M',
        phoneNumber: userData['phoneNumber'] as String? ?? '',
        status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
        email: userData['email'] as String? ?? '',
        travels: const [],
        stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
        password: userData['password'] as String?,
        birthDate: userData['birthDate'] != null
            ? DateTime.parse(userData['birthDate'] as String)
            : null,
      );

      final result = await _useCases.createUser(newUser);
      if (result.isSuccess) {
        await fetchUsers();
        return true;
      }
      _state = _state.copyWith(isLoading: false, errorMessage: result.error);
      notifyListeners();
      return false;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to create user: $e');
      notifyListeners();
      return false;
    }
  }

  /// Updates a client user from the raw form data built by [EditUserPage]
  /// (`id`, `name`, `cpf`, `email`, `phoneNumber`, `sex`) — looks up the
  /// currently loaded user by `id` to carry over the fields the edit form
  /// doesn't touch (`status`, `travels`, `stats`).
  Future<bool> updateUser(Map<String, dynamic> userData) async {
    try {
      final id = userData['id'] as String?;
      final existing = _state.users.firstWhere(
        (u) => u.backEndId == id,
        orElse: () => throw StateError('User not found: $id'),
      );
      final updatedUser = existing.toDomain().copyWith(
            name: userData['name'] as String?,
            cpf: userData['cpf'] as String?,
            email: userData['email'] as String?,
            phoneNumber: userData['phoneNumber'] as String?,
            sex: userData['sex'] as String?,
          );

      final result = await _useCases.updateUser(updatedUser);
      if (result.isSuccess) {
        await fetchUsers();
        return true;
      }
      _state = _state.copyWith(errorMessage: result.error);
      notifyListeners();
      return false;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to update user: $e');
      notifyListeners();
      return false;
    }
  }
}
