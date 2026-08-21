
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/user_client_repository.dart';

/// Contains all the use cases for [UserClient], having all crud methods
class UserUseCases{
  final UserClientRepository _repository;

  UserUseCases(this._repository);

  /// Create user method
  Future<Result> createUser(UserClient newUser) async{
    return await _repository.createUser(newUser);
  }

  /// Get user method
  Future<Result<UserClient>> getUser(String userId) async{
    return await _repository.getUser(userId);
  }

  /// Get the currently authenticated user
  Future<Result<UserClient>> getAuthenticatedUser() async{
    return await _repository.getAuthenticatedUser();
  }

  /// Get all users method
  Future<Result<List<UserClient>>> getAllUsers() async{
    return await _repository.getAllUsers();
  }

  /// Update user method
  Future<Result> updateUser(UserClient updatedUser) async{
    return await _repository.updateUser(updatedUser);
  }

  /// Deactivate user method
  Future<Result> deactivateUser(String userId, String reason) async{
    return await _repository.deactivateUser(userId, reason);
  }

  /// Reset password method
  Future<Result> resetPassword(String userId) async{
    return await _repository.resetPassword(userId);
  }

  /// Force logout method
  Future<Result> forceLogout(String userId) async{
    return await _repository.forceLogout(userId);
  }

}