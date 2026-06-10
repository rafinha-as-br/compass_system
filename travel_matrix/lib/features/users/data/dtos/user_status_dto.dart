import '../../domain/entities/user_status.dart';

/// Data transfer object for [UserClientStatus]
class UserClientStatusDto {
  final ClientStatusDto status;
  final String? lastLogin;

  UserClientStatusDto({
    required this.status,
    this.lastLogin,
  });

  /// From json factory method
  factory UserClientStatusDto.fromJson(Map<String, dynamic> json) {
    return UserClientStatusDto(
      status: ClientStatusDto.fromJson(json['status'] as Map<String, dynamic>),
      lastLogin: json['last_login'] as String?,
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
      'last_login': lastLogin,
    };
  }

  /// From domain mapper method
  factory UserClientStatusDto.fromDomain(UserClientStatus domain) {
    return UserClientStatusDto(
      status: ClientStatusDto.fromDomain(domain.status),
      lastLogin: domain.lastLogin?.toIso8601String(),
    );
  }

  /// To domain mapper method
  UserClientStatus toDomain() {
    return UserClientStatus(
      status: status.toDomain(),
      lastLogin: lastLogin != null ? DateTime.parse(lastLogin!) : null,
    );
  }
}

/// Data transfer object for [ClientStatus]
class ClientStatusDto {
  final String type;
  final String? reason;

  ClientStatusDto({
    required this.type,
    this.reason,
  });

  /// From json factory method
  factory ClientStatusDto.fromJson(Map<String, dynamic> json) {
    return ClientStatusDto(
      type: json['type'] as String,
      reason: json['reason'] as String?,
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'reason': reason,
    };
  }

  /// From domain mapper method
  factory ClientStatusDto.fromDomain(ClientStatus domain) {
    String type;
    if (domain is ActiveStatus) {
      type = 'active';
    } else if (domain is InactiveStatus) {
      type = 'inactive';
    } else if (domain is DisabledStatus) {
      type = 'disabled';
    } else {
      throw ArgumentError('Unknown status type: ${domain.runtimeType}');
    }

    return ClientStatusDto(
      type: type,
      reason: domain.reason,
    );
  }

  /// To domain mapper method
  ClientStatus toDomain() {
    switch (type) {
      case 'active':
        return ActiveStatus();
      case 'inactive':
        return InactiveStatus(reason: reason);
      case 'disabled':
        return DisabledStatus(reason: reason);
      default:
        throw StateError('Status type not supported by domain: $type');
    }
  }
}