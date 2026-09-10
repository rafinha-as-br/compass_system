import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';

abstract interface class ClientProfileRepository {
  Future<Result<ClientProfile>> getCurrentUser();
  Future<Result<ClientProfile>> updateUser(ClientProfile profile);
  Future<Result<void>> resetPassword(String id);
}
