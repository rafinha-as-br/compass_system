import '../../domain/entities/user_status.dart';

class UserClientStatusViewModel {
  final ClientStatusViewModel status;
  final DateTime? lastLogin;

  const UserClientStatusViewModel({
    required this.status,
    required this.lastLogin,
  });

  factory UserClientStatusViewModel.fromDomain(UserClientStatus entity) {
    return UserClientStatusViewModel(
      status: ClientStatusViewModel.fromDomain(entity.status),
      lastLogin: entity.lastLogin,
    );
  }

  UserClientStatus toDomain() {
    return UserClientStatus(
      status: status.toDomain(),
      lastLogin: lastLogin,
    );
  }
}

abstract class ClientStatusViewModel {
  final String? reason;

  const ClientStatusViewModel({
    required this.reason,
  });

  factory ClientStatusViewModel.fromDomain(ClientStatus status) {
    return switch (status) {
      ActiveStatus() => const ActiveStatusViewModel(),
      InactiveStatus(:final reason) =>
          InactiveStatusViewModel(reason: reason),
      DisabledStatus(:final reason) =>
          DisabledStatusViewModel(reason: reason),
      _ => throw UnimplementedError(),
    };
  }

  ClientStatus toDomain() {
    return switch (this) {
      ActiveStatusViewModel() => ActiveStatus(),
      InactiveStatusViewModel(:final reason) => InactiveStatus(reason: reason),
      DisabledStatusViewModel(:final reason) => DisabledStatus(reason: reason),
      _ => throw UnimplementedError(),
    };
  }
}

final class ActiveStatusViewModel extends ClientStatusViewModel {
  const ActiveStatusViewModel() : super(reason: null);
}

final class InactiveStatusViewModel extends ClientStatusViewModel {
  const InactiveStatusViewModel({
    required super.reason,
  });
}

final class DisabledStatusViewModel extends ClientStatusViewModel {
  const DisabledStatusViewModel({
    required super.reason,
  });
}