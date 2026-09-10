import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/repositories/participants_repository.dart';

class ParticipantsUseCases {
  final ParticipantsRepository repository;

  const ParticipantsUseCases(this.repository);

  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants) =>
      repository.updateParticipants(travelId, participants);
}
