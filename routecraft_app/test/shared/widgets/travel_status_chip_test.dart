import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
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
  testWidgets('routeCreated shows the awaiting-agent label in the warning color', (tester) async {
    await tester.pumpWidget(_wrap(const TravelStatusChip(status: TravelStatusChipVariant.routeCreated)));

    expect(find.text('Awaiting agent'), findsOneWidget);
    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, TravelAppColors.warning);
  });

  testWidgets('itineraryCreated shows the published label in the info color', (tester) async {
    await tester.pumpWidget(_wrap(const TravelStatusChip(status: TravelStatusChipVariant.itineraryCreated)));

    expect(find.text('Itinerary published'), findsOneWidget);
    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, TravelAppColors.info);
  });

  testWidgets('travelStarted shows the in-progress label in the theme primary color', (tester) async {
    await tester.pumpWidget(_wrap(const TravelStatusChip(status: TravelStatusChipVariant.travelStarted)));

    expect(find.text('In progress'), findsOneWidget);
    final theme = Theme.of(tester.element(find.byType(Chip)));
    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, theme.colorScheme.primary);
  });

  testWidgets('travelFinished shows the completed label in the success color', (tester) async {
    await tester.pumpWidget(_wrap(const TravelStatusChip(status: TravelStatusChipVariant.travelFinished)));

    expect(find.text('Completed'), findsOneWidget);
    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, TravelAppColors.success);
  });
}
