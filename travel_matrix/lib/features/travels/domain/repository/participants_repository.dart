import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';

abstract class ParticipantsRepository {
  /// Upserts the participants list of an existing travel through the
  /// isolated endpoint (`PUT /travels/{travelId}/participants`), without
  /// touching its route/itinerary.
  Future<Result<List<Person>>> updateParticipants(String travelId, List<Person> participants);
}
