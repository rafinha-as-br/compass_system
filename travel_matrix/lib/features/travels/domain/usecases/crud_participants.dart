import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/repository/participants_repository.dart';

class CrudParticipants {
  final ParticipantsRepository repository;

  CrudParticipants(this.repository);

  Future<Result<List<Person>>> updateParticipants(
    String travelId,
    List<Person> participants,
  ) async {
    return await repository.updateParticipants(travelId, participants);
  }
}
