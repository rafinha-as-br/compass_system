import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('stop uses the place icon in the theme primary color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.stop)));

    final theme = Theme.of(tester.element(find.byType(StepIcon)));
    final icon = tester.widget<Icon>(find.byIcon(Icons.place_outlined));
    expect(icon.color, theme.colorScheme.primary);
  });

  testWidgets('hosting uses the bed icon in the info color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.hosting)));

    final icon = tester.widget<Icon>(find.byIcon(Icons.bed_outlined));
    expect(icon.color, TravelAppColors.info);
  });

  testWidgets('airplane uses the flight icon in the theme secondary color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.airplane)));

    final theme = Theme.of(tester.element(find.byType(StepIcon)));
    final icon = tester.widget<Icon>(find.byIcon(Icons.flight_outlined));
    expect(icon.color, theme.colorScheme.secondary);
  });

  testWidgets('bus uses the bus icon in the warning color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.bus)));

    final icon = tester.widget<Icon>(find.byIcon(Icons.directions_bus_outlined));
    expect(icon.color, TravelAppColors.warning);
  });

  testWidgets('rentalCar uses the car icon in the success color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.rentalCar)));

    final icon = tester.widget<Icon>(find.byIcon(Icons.directions_car_outlined));
    expect(icon.color, TravelAppColors.success);
  });

  testWidgets('boundary uses the flag icon in the theme onSurface color', (tester) async {
    await tester.pumpWidget(_wrap(const StepIcon(type: StepIconType.boundary)));

    final theme = Theme.of(tester.element(find.byType(StepIcon)));
    final icon = tester.widget<Icon>(find.byIcon(Icons.flag_outlined));
    expect(icon.color, theme.colorScheme.onSurface);
  });
}
