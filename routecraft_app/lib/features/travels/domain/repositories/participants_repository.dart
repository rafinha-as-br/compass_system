import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';

abstract interface class ParticipantsRepository {
  /// Upserts the participants list of an existing travel through the
  /// isolated endpoint (`PUT /travels/{travelId}/participants`), without
  /// touching its route/itinerary.
  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants);
}
