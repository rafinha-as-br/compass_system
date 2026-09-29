import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/data_sources/participants_data_source.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/repository/participants_repository.dart';

class ParticipantsRepositoryImpl implements ParticipantsRepository {
  final ParticipantsDataSource _dataSource;

  ParticipantsRepositoryImpl({ParticipantsDataSource? dataSource}) : _dataSource = dataSource ?? ParticipantsDataSource();

  @override
  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants) async {
    try {
      final updated = await _dataSource.updateParticipants(
        travelId,
        participants.map((p) => PersonDTO.fromDomain(person: p)).toList(),
      );
      return Result.success(updated.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return Result.failure('Failed to update participants: $e');
    }
  }
}
