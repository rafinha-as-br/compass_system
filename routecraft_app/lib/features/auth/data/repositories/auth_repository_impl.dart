import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:routecraft_app/features/auth/domain/entities/auth_session.dart';
import 'package:routecraft_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    try {
      final dto = await _dataSource.login(email, password);
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (_) {
      return const Result.failure('Não foi possível completar o login.');
    }
  }
}
