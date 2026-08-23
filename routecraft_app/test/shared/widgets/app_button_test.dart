import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('default state renders the child and is tappable', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(AppButton(onPressed: () => tapped = true, child: const Text('Submit'))),
    );

    expect(find.text('Submit'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });

  testWidgets('disabled state (onPressed: null) cannot be tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(AppButton(onPressed: null, child: const Text('Submit'))),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isFalse);
  });

  testWidgets('loading state shows a progress indicator instead of the child, and disables tapping',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        AppButton(
          onPressed: () => tapped = true,
          isLoading: true,
          child: const Text('Submit'),
        ),
      ),
    );

    expect(find.text('Submit'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isFalse);
  });

  testWidgets('secondary variant is outlined and transparent', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppButton(
          onPressed: () {},
          variant: AppButtonVariant.secondary,
          child: const Text('Cancel'),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final resolvedBackground = button.style?.backgroundColor?.resolve(const {});
    expect(resolvedBackground, Colors.transparent);
  });

  testWidgets('danger variant uses the theme error color', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppButton(
          onPressed: () {},
          variant: AppButtonVariant.danger,
          child: const Text('Log Out'),
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(ElevatedButton)));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final resolvedBackground = button.style?.backgroundColor?.resolve(const {});
    expect(resolvedBackground, theme.colorScheme.error);
  });

  testWidgets('icon variant renders an ElevatedButton.icon', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppButton(
          onPressed: () {},
          icon: const Icon(Icons.logout),
          child: const Text('Log Out'),
        ),
      ),
    );

    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
