import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/info_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders the icon, label and value', (tester) async {
    await tester.pumpWidget(_wrap(const InfoTile(
      icon: Icons.calendar_today,
      label: 'Start date',
      value: 'Aug 1, 2025',
    )));

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('Aug 1, 2025'), findsOneWidget);
  });
}
