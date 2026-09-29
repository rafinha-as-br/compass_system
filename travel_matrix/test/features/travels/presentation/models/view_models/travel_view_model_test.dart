import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';

Travel _buildTravel({
  required TravelStatus status,
  required bool prepared,
  bool hasItinerary = true,
}) {
  return Travel(
    domainId: '1',
    backEndId: '1',
    clientName: 'Client',
    travelName: 'Travel',
    travelStatus: status,
    prepared: prepared,
    participantsList: const <Person>[],
    routePlan: RoutePlan(
      domainId: 'route-1',
      backEndId: 'route-1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Paris',
      interestsList: const [],
    ),
    itinerary: hasItinerary
        ? Itinerary(
            domainId: 'itinerary-1',
            backEndId: 'itinerary-1',
            agentName: 'Agent',
            itinerarySteps: const [],
          )
        : null,
  );
}

void main() {
  group('TravelViewModel prepared round-trip (CPS-166)', () {
    test(
      'itineraryCreated + prepared=false maps to notReady, and toDomain reconstructs itineraryCreated',
      () {
        final viewModel = TravelViewModel.fromDomain(
          _buildTravel(status: TravelStatus.itineraryCreated, prepared: false),
        );

        expect(viewModel.status, TravelStatusViewModel.notReady);
        expect(viewModel.prepared, isFalse);

        final roundTripped = viewModel.toDomain();
        expect(roundTripped.travelStatus, TravelStatus.itineraryCreated);
        expect(roundTripped.prepared, isFalse);
      },
    );

    test(
      'itineraryCreated + prepared=true maps to ready, and toDomain reconstructs itineraryCreated',
      () {
        final viewModel = TravelViewModel.fromDomain(
          _buildTravel(status: TravelStatus.itineraryCreated, prepared: true),
        );

        expect(viewModel.status, TravelStatusViewModel.ready);
        expect(viewModel.prepared, isTrue);

        final roundTripped = viewModel.toDomain();
        expect(roundTripped.travelStatus, TravelStatus.itineraryCreated);
        expect(roundTripped.prepared, isTrue);
      },
    );

    test('routeCreated without itinerary round-trips to routeCreated regardless of prepared', () {
      final viewModel = TravelViewModel.fromDomain(
        _buildTravel(status: TravelStatus.routeCreated, prepared: false, hasItinerary: false),
      );

      expect(viewModel.status, TravelStatusViewModel.notReady);

      final roundTripped = viewModel.toDomain();
      expect(roundTripped.travelStatus, TravelStatus.routeCreated);
      expect(roundTripped.prepared, isFalse);
    });
  });
}
