
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';

/// Repository responsible for handling all user operations
abstract class UserClientRepository{

  /// Create method
  Future<Result> createUser(UserClient newUser);
  /// Get User method
  Future<Result<UserClient>> getUser(String userId);
  /// Get the currently authenticated user
  Future<Result<UserClient>> getAuthenticatedUser();
  /// Get all users method
  Future<Result<List<UserClient>>> getAllUsers();
  /// Update method
  Future<Result> updateUser(UserClient updatedUser);
  /// Deactivate method
  Future<Result> deactivateUser(String userId, String reason);
  /// Reset password method
  Future<Result> resetPassword(String userId);
  /// Force logout method
  Future<Result> forceLogout(String userId);
}