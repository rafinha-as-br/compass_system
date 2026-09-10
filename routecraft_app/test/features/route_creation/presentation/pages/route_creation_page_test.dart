import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';
import 'package:routecraft_app/features/route_creation/presentation/pages/route_creation_page.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

class _FakeTravelRepository implements TravelRepository {
  Result<Travel>? nextCreateResult;

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => nextCreateResult!;

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => throw UnimplementedError();
}

Widget _wrap(RouteCreationController controller) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: RouteCreationPage(controller: controller),
  );
}

void main() {
  testWidgets('success icon uses TravelAppColors.success', (tester) async {
    final controller = RouteCreationController.withState(
      const RouteCreationState(isSuccess: true),
    );

    await tester.pumpWidget(_wrap(controller));

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
    expect(icon.color, TravelAppColors.success);
  });

  testWidgets('the name step blocks Continue until a name is entered', (tester) async {
    final controller = RouteCreationController(
      travelUseCases: TravelUseCases(_FakeTravelRepository()),
      getClientName: () async => 'Maria Silva',
    );

    await tester.pumpWidget(_wrap(controller));

    expect(find.text('STEP 1 OF 5'), findsOneWidget);
    final continueButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(continueButton.onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), 'Litoral Norte');
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('walks through all 5 steps to the review screen and back to edit', (tester) async {
    final controller = RouteCreationController(
      travelUseCases: TravelUseCases(_FakeTravelRepository()),
      getClientName: () async => 'Maria Silva',
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pump(); // let the client auto-participant load

    // Step 1 — name.
    await tester.enterText(find.byType(TextFormField), 'Litoral Norte');
    await tester.pump();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Step 2 — dates, via the "1 week" shortcut instead of the date picker.
    expect(find.text('STEP 2 OF 5'), findsOneWidget);
    await tester.tap(find.text('1 week'));
    await tester.pump();
    expect(find.textContaining('7 nights'), findsOneWidget);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Step 3 — locations.
    expect(find.text('STEP 3 OF 5'), findsOneWidget);
    final locationFields = find.byType(TextFormField);
    await tester.enterText(locationFields.at(0), 'São Paulo');
    await tester.enterText(locationFields.at(1), 'Paraty');
    await tester.pump();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Step 4 — interests (optional, skip straight through).
    expect(find.text('STEP 4 OF 5'), findsOneWidget);
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Step 5 — participants: the client is already listed (name pre-filled,
    // no remove button); fill in the missing age/sex to unlock Continue.
    expect(find.text('STEP 5 OF 5'), findsOneWidget);
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '30');
    await tester.pump();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Female').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('NEXT'));
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    // Review.
    expect(find.text('Confirm your route'), findsOneWidget);
    expect(find.text('Litoral Norte'), findsOneWidget);
    expect(find.text('São Paulo → Paraty'), findsOneWidget);
    expect(find.text('Maria Silva'), findsOneWidget);

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF 5'), findsOneWidget);
    expect(find.text('Litoral Norte'), findsOneWidget);
  });
}
