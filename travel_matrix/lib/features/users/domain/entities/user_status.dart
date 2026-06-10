
class UserClientStatus{
  final ClientStatus status;
  final DateTime? lastLogin;

  UserClientStatus({required this.status, required this.lastLogin});
}

abstract class ClientStatus{
  /// Reason of the status
  final String? reason;

  ClientStatus({required this.reason});
}

class ActiveStatus implements ClientStatus{
  @override
  final String? reason = null;
}

class InactiveStatus implements ClientStatus{
  @override
  final String? reason;

  InactiveStatus({required this.reason});
}

class DisabledStatus implements ClientStatus{
  @override
  final String? reason;

  DisabledStatus({required this.reason});
}
