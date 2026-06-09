
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';

/// Repository responsible for handling all user operations
abstract class UserClientRepository{

  /// Create method
  Future<Result> createUser(UserClient newUser);
  /// Get User method
  Future<Result<UserClient>> getUser(String userId);
  /// Update method
  Future<Result> updateUser(UserClient updatedUser);
  /// Delete method
  Future<Result> deleteUser(String userId);
}