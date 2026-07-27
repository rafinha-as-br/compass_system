import 'package:travel_matrix/features/auth/data/auth_data_source.dart';
import 'package:travel_matrix/features/auth/data/dtos/auth_session_dto.dart';
import 'package:travel_matrix/features/auth/domain/auth_repository.dart';
import 'package:travel_matrix/features/auth/domain/entities/auth_session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthSession> login(String email, String password) async {
    final response = await _dataSource.login(email, password);
    if (response['status'] != 'success') {
      throw StateError(
        response['message'] as String? ?? 'Invalid credentials. Please try again.',
      );
    }

    final data = response['data'] as Map<String, dynamic>;
    return AuthSessionDto.fromJson(data).toDomain();
  }
}
