import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockItineraryRepository extends Mock implements ItineraryRepository {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorageService.init();
    registerFallbackValue(
      Itinerary(domainId: 'x', backEndId: null, agentName: '', itinerarySteps: const []),
    );
  });

  Widget wrap({
    required ItineraryRepository repository,
    required AuthController auth,
  }) {
    final router = GoRouter(
      initialLocation: '/build',
      routes: [
        GoRoute(
          path: '/build',
          builder: (context, state) => ItineraryBuildPage(
            travelId: 'travel-1',
            itineraryRepository: repository,
            itineraryBuildModel: ItineraryBuildModel(
              travelName: 'Lisbon 2025',
              steps: null,
              interestsPoints: const [],
            ),
          ),
        ),
        GoRoute(path: '/travels/:id', builder: (context, state) => const SizedBox()),
      ],
    );

    return ChangeNotifierProvider<AuthController>.value(
      value: auth,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('saving an itinerary sends the agent name from AuthController, not a fresh lookup', (tester) async {
    final repository = _MockItineraryRepository();
    when(() => repository.upsertItinerary(any(), any())).thenAnswer(
      (_) async => Result.success(
        Itinerary(domainId: 'x', backEndId: '1', agentName: 'Carlos Agent', itinerarySteps: const []),
      ),
    );

    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-9', 'name': 'Carlos Agent', 'email': 'carlos@compass.com'});

    await tester.pumpWidget(wrap(repository: repository, auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(() => repository.upsertItinerary('travel-1', captureAny())).captured;
    final sentItinerary = captured.single as Itinerary;
    expect(sentItinerary.agentName, 'Carlos Agent');
  });

  testWidgets('falls back to the email when the agent has no name', (tester) async {
    final repository = _MockItineraryRepository();
    when(() => repository.upsertItinerary(any(), any())).thenAnswer(
      (_) async => Result.success(
        Itinerary(domainId: 'x', backEndId: '1', agentName: '', itinerarySteps: const []),
      ),
    );

    final auth = AuthController();
    auth.debugSetUserData({'id': 'agent-9', 'name': '', 'email': 'carlos@compass.com'});

    await tester.pumpWidget(wrap(repository: repository, auth: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(() => repository.upsertItinerary('travel-1', captureAny())).captured;
    final sentItinerary = captured.single as Itinerary;
    expect(sentItinerary.agentName, 'carlos@compass.com');
  });
}
