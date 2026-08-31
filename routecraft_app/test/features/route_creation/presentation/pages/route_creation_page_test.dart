import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

void main() {
  testWidgets('success icon uses TravelAppColors.success', (tester) async {
    final controller = RouteCreationController.withState(
      const RouteCreationState(isSuccess: true),
    );

    await tester.pumpWidget(MaterialApp(home: RouteCreationPage(controller: controller)));

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
    expect(icon.color, TravelAppColors.success);
  });

  testWidgets('error message uses TravelAppColors.error', (tester) async {
    final controller = RouteCreationController.withState(
      const RouteCreationState(currentStep: 2, errorMessage: 'Failed to create route.'),
    );

    await tester.pumpWidget(MaterialApp(home: RouteCreationPage(controller: controller)));

    final text = tester.widget<Text>(find.text('Failed to create route.'));
    expect(text.style?.color, TravelAppColors.error);
  });
}
