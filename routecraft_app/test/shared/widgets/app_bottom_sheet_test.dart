import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/app_bottom_sheet.dart';

void main() {
  testWidgets('show() displays the title and the given child content', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => AppBottomSheet.show<void>(
              context,
              title: 'Step details',
              child: const Text('Flight to Lisbon'),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Step details'), findsOneWidget);
    expect(find.text('Flight to Lisbon'), findsOneWidget);
  });
}
