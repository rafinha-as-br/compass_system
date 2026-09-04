import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_app_bar.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

Travel _buildNotReadyTravel() {
  return Travel(
    domainId: '1',
    backEndId: '1',
    clientName: 'Client',
    travelName: 'Travel',
    travelStatus: TravelStatus.routeCreated,
    participantsList: const [],
    routePlan: RoutePlan(
      domainId: 'route-1',
      backEndId: 'route-1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Paris',
      interestsList: const [],
    ),
    itinerary: Itinerary(
      domainId: 'itinerary-1',
      backEndId: 'itinerary-1',
      agentName: 'Agent',
      itinerarySteps: const [],
    ),
  );
}

void main() {
  late _MockCrudTravelUseCases travelUseCases;
  late _MockCrudRoute routeUseCases;

  setUp(() {
    travelUseCases = _MockCrudTravelUseCases();
    routeUseCases = _MockCrudRoute();
    when(() => travelUseCases.readAll()).thenAnswer((_) async => const Result.success([]));
  });

  testWidgets('failing to mark a travel as ready shows the error snackbar with the theme error color', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => travelUseCases.markAsReady(any())).thenAnswer((_) async => Result.failure('boom'));
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases);
    final travel = TravelViewModel.fromDomain(_buildNotReadyTravel());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DefaultTabController(
            length: 2,
            child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.confirmButton));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppTheme.lightTheme.colorScheme.error);
  });
}
