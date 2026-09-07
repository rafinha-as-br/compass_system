import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/route_view_tab.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Travel _travel() => Travel(
  domainId: 't1',
  backEndId: 't1',
  clientName: 'Maria Silva',
  travelName: 'Lisbon 2025',
  travelStatus: TravelStatus.routeCreated,
  participantsList: const [],
  routePlan: RoutePlan(
    domainId: 'r1',
    backEndId: 'r1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 10),
    startLocation: 'Sao Paulo',
    destination: 'Lisbon',
    interestsList: const [],
  ),
);

void main() {
  testWidgets('does not show its own edit button — editing route lives only in the app bar', (
    tester,
  ) async {
    final travel = TravelViewModel.fromDomain(_travel());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TravelsController(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RouteViewTab(travel: travel)),
        ),
      ),
    );

    expect(find.text('Edit Route Plan'), findsNothing);
    expect(find.byIcon(Icons.edit_road), findsNothing);
    expect(find.text('Lisbon'), findsOneWidget);
  });
}
