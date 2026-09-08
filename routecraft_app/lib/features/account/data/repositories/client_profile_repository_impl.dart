import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/account/data/datasources/client_profile_data_source.dart';
import 'package:routecraft_app/features/account/data/dtos/client_profile_dto.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/domain/repositories/client_profile_repository.dart';

class ClientProfileRepositoryImpl implements ClientProfileRepository {
  final ClientProfileDataSource _dataSource;

  ClientProfileRepositoryImpl({ClientProfileDataSource? dataSource})
      : _dataSource = dataSource ?? ClientProfileDataSource();

  @override
  Future<Result<ClientProfile>> getCurrentUser() async {
    try {
      final dto = await _dataSource.getCurrentUser();
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar seus dados.', isConnectivityError: true);
    }
  }

  @override
  Future<Result<ClientProfile>> updateUser(ClientProfile profile) async {
    try {
      final updated = await _dataSource.updateUser(ClientProfileDTO.fromDomain(profile));
      return Result.success(updated.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível salvar seus dados.', isConnectivityError: true);
    }
  }

  @override
  Future<Result<void>> resetPassword(String id) async {
    try {
      await _dataSource.resetPassword(id);
      return const Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível resetar a senha.', isConnectivityError: true);
    }
  }
}
