import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/data/dtos/user_dto.dart';
import 'package:travel_matrix/features/users/data/user_client_data_source.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/user_client_repository.dart';

class UserClientRepositoryImpl implements UserClientRepository {
  final UserClientDataSource _dataSource;

  UserClientRepositoryImpl(this._dataSource);

  @override
  Future<Result> createUser(UserClient newUser) async {
    try {
      final dto = UserDTO.fromDomain(newUser);
      await _dataSource.createUser(dto.toJson());
      return const Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<UserClient>> getUser(String userId) async {
    try {
      final response = await _dataSource.getUser(userId);
      final data = response['data'] as Map<String, dynamic>;
      final dto = UserDTO.fromJson(data);
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<UserClient>>> getAllUsers() async {
    try {
      final response = await _dataSource.getAllUsers();
      final data = response['data'] as List<dynamic>;
      final users = data.map((e) => UserDTO.fromJson(e as Map<String, dynamic>).toDomain()).toList();
      return Result.success(users);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result> updateUser(UserClient updatedUser) async {
    try {
      final dto = UserDTO.fromDomain(updatedUser);
      await _dataSource.updateUser(dto.toJson());
      return const Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result> deactivateUser(String userId, String reason) async {
    try {
      await _dataSource.deactivateUser(userId, reason);
      return const Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result> resetPassword(String userId) async {
    try {
      await _dataSource.resetPassword(userId);
      return const Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result> forceLogout(String userId) async {
    try {
      await _dataSource.forceLogout(userId);
      return const Result.success();
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
