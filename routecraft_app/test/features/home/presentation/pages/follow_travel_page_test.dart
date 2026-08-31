import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';
import 'package:routecraft_app/features/home/presentation/pages/follow_travel_page.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

void main() {
  testWidgets('following-state success icon uses TravelAppColors.success', (tester) async {
    final travel = Travel(
      id: 't1',
      clientId: 'client_1',
      agentId: 'agent_1',
      travelName: 'Trip to Rome',
      travelStatus: TravelStatus.itineraryReady,
      participantsList: const [],
      routePlan: RoutePlan(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 10),
        startLocation: 'SP',
        destination: 'Rome',
        interestsList: const [],
      ),
    );

    await tester.pumpWidget(MaterialApp(home: FollowTravelPage(travel: travel)));

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
    expect(icon.color, TravelAppColors.success);

    final subtitle = tester.widget<Text>(find.text('SP ➔ Rome'));
    expect(subtitle.style?.color, TravelAppColors.textSecondary);
  });
}
