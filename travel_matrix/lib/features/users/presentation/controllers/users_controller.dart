import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:mock_repository/mock_repository.dart';

import '../../../../core/services/auth_storage_service.dart';

class UsersState {
  final bool isLoading;
  final List<Client> users;
  final String? errorMessage;

  const UsersState({
    this.isLoading = true,
    this.users = const [],
    this.errorMessage,
  });
}

class UsersController extends ChangeNotifier {
  UsersState _state = const UsersState();
  UsersState get state => _state;

  UsersController() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _state = const UsersState(isLoading: true);
    notifyListeners();

    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) {
        _state = const UsersState(
            isLoading: false,
            errorMessage: 'Not authenticated.');
        notifyListeners();
        return;
      }

      final response = await CompassService.instance.getAllUsers(token);

      if (response['status'] == 'success') {
        final data = response['data'] as List<dynamic>;
        final clients = data
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList();
        _state = UsersState(isLoading: false, users: clients);
      } else {
        _state = UsersState(
          isLoading: false,
          errorMessage: response['message'] as String?,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = UsersState(
        isLoading: false,
        errorMessage: 'Failed to fetch users: $e',
      );
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final token = await AuthStorageService.instance.getToken();
      if (token == null) return false;

      final response =
          await CompassService.instance.deleteUser(token, userId);
      if (response['status'] == 'success') {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (_) {
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
      _state = UsersState(
        isLoading: false,
        users: _state.users,
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
