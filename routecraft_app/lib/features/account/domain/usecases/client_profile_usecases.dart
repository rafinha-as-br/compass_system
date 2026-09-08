import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/domain/repositories/client_profile_repository.dart';

class ClientProfileUseCases {
  final ClientProfileRepository repository;

  const ClientProfileUseCases(this.repository);

  Future<Result<ClientProfile>> getCurrentUser() => repository.getCurrentUser();

  Future<Result<ClientProfile>> updateUser(ClientProfile profile) => repository.updateUser(profile);

  Future<Result<void>> resetPassword(String id) => repository.resetPassword(id);
}
