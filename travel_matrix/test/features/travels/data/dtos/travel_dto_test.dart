import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';

void main() {
  Map<String, dynamic> json({bool? itineraryDraftPending}) => {
        'id': 't1',
        'client': 'Maria',
        'travelName': 'Lisboa',
        'travelStatus': 'itinerary_created',
        'prepared': true,
        'routePlan': <String, dynamic>{},
        if (itineraryDraftPending != null) 'itineraryDraftPending': itineraryDraftPending,
      };

  test('reads the server-owned itineraryDraftPending flag through to the domain', () {
    final dto = TravelDTO.fromJson(json(itineraryDraftPending: true));

    expect(dto.itineraryDraftPending, isTrue);
    expect(dto.toDomain().itineraryDraftPending, isTrue);
  });

  test('defaults to no pending draft and never sends the flag back', () {
    final dto = TravelDTO.fromJson(json());

    expect(dto.itineraryDraftPending, isFalse);
    expect(dto.toJson().containsKey('itineraryDraftPending'), isFalse);
  });
}
