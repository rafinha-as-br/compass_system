import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/app/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders without throwing, with the logo and the title via i18n', (tester) async {
    await tester.pumpWidget(const SplashScreen());

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('RouteCraft'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
