import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';
import 'package:routecraft_app/features/auth/domain/repositories/client_registration_repository.dart';

class RegisterClientUseCase {
  final ClientRegistrationRepository _repository;

  const RegisterClientUseCase(this._repository);

  Future<Result<String>> call(ClientRegistration registration) {
    return _repository.register(registration);
  }
}
