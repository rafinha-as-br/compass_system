import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/auth/data/datasources/client_registration_remote_datasource.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/domain/repositories/client_registration_repository.dart';

class ClientRegistrationRepositoryImpl implements ClientRegistrationRepository {
  final ClientRegistrationRemoteDataSource _dataSource;

  const ClientRegistrationRepositoryImpl(this._dataSource);

  @override
  Future<Result<String>> register(ClientRegistration registration) async {
    try {
      final message = await _dataSource.register(registration);
      return Result.success(message);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (_) {
      return const Result.failure('Não foi possível completar o cadastro.');
    }
  }
}
