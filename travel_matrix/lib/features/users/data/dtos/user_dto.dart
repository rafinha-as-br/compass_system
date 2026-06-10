
import 'package:travel_matrix/features/users/data/dtos/travel_summary_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_stats_dto.dart';
import 'package:travel_matrix/features/users/data/dtos/user_status_dto.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:uuid/uuid.dart';

/// Data transfer object for [UserClient]
class UserDTO{
  /// Back end id, null in case of new entity
  final String? id;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final UserClientStatusDto status;
  final String email;
  final List<TravelSummaryDTO> travels;
  final UserStatsDTO stats;

  UserDTO({
    required this.id,
    required this.name,
    required this.cpf,
    required this.sex,
    required this.phoneNumber,
    required this.status,
    required this.email,
    required this.travels,
    required this.stats,
  });

  /// to domain mapper method
  UserClient toDomain(){
    return UserClient(
        backEndId: id,
        domainId: id ?? Uuid().v4(),
        name: name,
        cpf: cpf,
        sex: sex,
        phoneNumber: phoneNumber,
        status: status.toDomain(),
        email: email,
        travels: travels.map((travel) => travel.toDomain()).toList(),
        stats: stats.toDomain(),
    );
  }

  /// From domain mapper method
  factory UserDTO.fromDomain(UserClient user){
    return UserDTO(
      id: user.backEndId,
      name: user.name,
      cpf: user.cpf,
      sex: user.sex,
      phoneNumber: user.phoneNumber,
      status: UserClientStatusDto.fromDomain(user.status),
      email: user.email,
      travels: user.travels.map((travel) => TravelSummaryDTO.fromDomain(travel)).toList(),
      stats: UserStatsDTO.fromDomain(user.stats),
    );
  }

  /// To json method, only parses the user fields, not the travels
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'status': status.toJson(),
      'email': email,
    };
  }

  factory UserDTO.fromJson(Map<String, dynamic> json){
    return UserDTO(
      id: json['id'] ?? json['backEndId'],
      name: json['name'] ?? '',
      cpf: json['cpf'] ?? '',
      sex: json['sex'] ?? 'M',
      phoneNumber: json['phoneNumber'] ?? '',
      status: json['status'] != null 
          ? UserClientStatusDto.fromJson(json['status'])
          : UserClientStatusDto(
              status: ClientStatusDto(type: (json['isActive'] == true) ? 'active' : 'inactive'),
            ),
      email: json['email'] ?? '',
      travels: json['travels'] != null 
          ? (json['travels'] as List).map<TravelSummaryDTO>((travel) => TravelSummaryDTO.fromJson(travel)).toList()
          : [],
      stats: json['stats'] != null
          ? UserStatsDTO.fromJson(json['stats'])
          : UserStatsDTO(totalTravels: '0', uniqueDestinationsCount: '0'),
    );
  }


}
