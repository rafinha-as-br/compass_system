import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/users/data/dtos/travel_summary_dto.dart';

void main() {
  final dto = TravelSummaryDTO(
    backEndId: 'travel-1',
    travelName: 'Paris Trip',
    destination: 'Paris',
    status: 'completed',
    startDate: DateTime(2026, 1, 10),
  );

  test('toDomain derives a stable domainId from backEndId', () {
    final first = dto.toDomain();
    final second = dto.toDomain();

    expect(first.domainId, dto.backEndId);
    expect(second.domainId, first.domainId);
  });

  test('round-trips through fromDomain/toDomain without losing data', () {
    final domain = dto.toDomain();
    final roundTripped = TravelSummaryDTO.fromDomain(domain).toDomain();

    expect(roundTripped.backEndId, domain.backEndId);
    expect(roundTripped.domainId, domain.domainId);
    expect(roundTripped.travelName, domain.travelName);
    expect(roundTripped.destination, domain.destination);
    expect(roundTripped.status, domain.status);
    expect(roundTripped.startDate, domain.startDate);
  });
}
