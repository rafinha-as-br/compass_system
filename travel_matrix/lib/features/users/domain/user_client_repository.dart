
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/user.dart';

/// Repository responsible for handling all user operations
abstract class UserClientRepository{

  /// Create method
  Future<Result> createUser(UserClient newUser);
  /// Get User method
  Future<Result<UserClient>> getUser(String userId);
  /// Get all users method
  Future<Result<List<UserClient>>> getAllUsers();
  /// Update method
  Future<Result> updateUser(UserClient updatedUser);
  /// Delete method
  Future<Result> deleteUser(String userId);
}