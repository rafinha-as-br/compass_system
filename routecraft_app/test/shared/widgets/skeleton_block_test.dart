import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/skeleton_block.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders without a spinner, at the given height/width', (tester) async {
    await tester.pumpWidget(_wrap(const SkeletonBlock(height: 24, width: 120)));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    final size = tester.getSize(find.byType(SkeletonBlock));
    expect(size.height, 24);
    expect(size.width, 120);
  });

  testWidgets('defaults to a 16-tall block with no fixed width', (tester) async {
    await tester.pumpWidget(_wrap(const SkeletonBlock()));

    final size = tester.getSize(find.byType(SkeletonBlock));
    expect(size.height, 16);
  });
}
