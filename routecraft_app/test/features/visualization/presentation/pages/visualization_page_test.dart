import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/visualization/presentation/controllers/visualization_controller.dart';
import 'package:routecraft_app/features/visualization/presentation/pages/visualization_page.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

RoutePlan _routePlan() => RoutePlan(
      domainId: 'r1',
      backEndId: 'r1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Rome',
      interestsList: const [],
    );

Travel _travel(TravelStatus status) => Travel(
      domainId: 't1',
      backEndId: 't1',
      clientName: 'Maria Silva',
      travelName: 'Trip to Rome',
      travelStatus: status,
      participantsList: const [],
      routePlan: _routePlan(),
    );

void main() {
  testWidgets('itinerary-ready chip uses TravelAppColors.success', (tester) async {
    final controller = VisualizationController.withState(
      VisualizationState(isLoading: false, travels: [_travel(TravelStatus.itineraryCreated)]),
    );

    await tester.pumpWidget(MaterialApp(home: VisualizationPage(controller: controller)));

    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, TravelAppColors.success);

    final icon = tester.widget<Icon>(find.byIcon(Icons.flight_takeoff));
    expect(icon.color, TravelAppColors.success);
  });

  testWidgets('route-only chip uses TravelAppColors.warning', (tester) async {
    final controller = VisualizationController.withState(
      VisualizationState(isLoading: false, travels: [_travel(TravelStatus.routeCreated)]),
    );

    await tester.pumpWidget(MaterialApp(home: VisualizationPage(controller: controller)));

    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, TravelAppColors.warning);
  });
}
