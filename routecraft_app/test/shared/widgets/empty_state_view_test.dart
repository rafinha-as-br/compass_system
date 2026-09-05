import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders the icon, title and message without a CTA when none is given', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyStateView(
      icon: Icons.map_outlined,
      title: 'No trips yet',
      message: 'Create a route to get started.',
    )));

    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.text('No trips yet'), findsOneWidget);
    expect(find.text('Create a route to get started.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('renders and calls the CTA when a label/callback is given', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(EmptyStateView(
      icon: Icons.map_outlined,
      title: 'No trips yet',
      message: 'Create a route to get started.',
      ctaLabel: 'Create Route',
      onCtaPressed: () => tapped = true,
    )));

    expect(find.text('Create Route'), findsOneWidget);
    await tester.tap(find.text('Create Route'));
    expect(tapped, isTrue);
  });
}
