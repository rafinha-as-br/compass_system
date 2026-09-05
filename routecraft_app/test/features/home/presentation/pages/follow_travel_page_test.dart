import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/home/presentation/pages/follow_travel_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

void main() {
  testWidgets('following-state success icon uses TravelAppColors.success', (tester) async {
    final travel = Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Maria Silva',
      travelName: 'Trip to Rome',
      travelStatus: TravelStatus.itineraryCreated,
      participantsList: const [],
      routePlan: RoutePlan(
        domainId: 'r1',
        backEndId: 'r1',
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
