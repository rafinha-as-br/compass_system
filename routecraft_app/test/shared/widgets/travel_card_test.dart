import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/travel_card.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders the travel name, route, period and status chip', (tester) async {
    await tester.pumpWidget(_wrap(const TravelCard(
      travelName: 'Lisbon 2025',
      route: 'São Paulo → Lisbon',
      period: '10–15 dez',
      status: TravelStatusChipVariant.routeCreated,
    )));

    expect(find.text('Lisbon 2025'), findsOneWidget);
    expect(find.text('São Paulo → Lisbon'), findsOneWidget);
    expect(find.text('10–15 dez'), findsOneWidget);
    expect(find.byType(TravelStatusChip), findsOneWidget);
  });

  testWidgets('route and period render as separate lines', (tester) async {
    await tester.pumpWidget(_wrap(const TravelCard(
      travelName: 'Lisbon 2025',
      route: 'São Paulo → Lisbon',
      period: '10–15 dez',
      status: TravelStatusChipVariant.routeCreated,
    )));

    final routeBottom = tester.getBottomLeft(find.text('São Paulo → Lisbon'));
    final periodTop = tester.getTopLeft(find.text('10–15 dez'));
    expect(periodTop.dy, greaterThanOrEqualTo(routeBottom.dy));
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(TravelCard(
      travelName: 'Lisbon 2025',
      route: 'São Paulo → Lisbon',
      period: '10–15 dez',
      status: TravelStatusChipVariant.routeCreated,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.byType(TravelCard));
    expect(tapped, isTrue);
  });
}
