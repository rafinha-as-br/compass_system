import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/route_creation_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockRouteRepository extends Mock implements RouteRepository {}

class _MockTravelRepository extends Mock implements TravelRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue('travel-1');
    registerFallbackValue(
      RoutePlan(
        domainId: 'fallback',
        backEndId: null,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 2),
        startLocation: '',
        destination: '',
        interestsList: const [],
      ),
    );
  });

  testWidgets(
    'navigates back with refresh: true after a successful route update, '
    'so the detail screen re-fetches instead of showing stale data',
    (tester) async {
      final routeRepository = _MockRouteRepository();
      final travelRepository = _MockTravelRepository();

      when(() => travelRepository.getAllTravels())
          .thenAnswer((_) async => const Result.success([]));
      when(() => routeRepository.updateRoute(any(), any())).thenAnswer(
        (invocation) async =>
            Result.success(invocation.positionalArguments[1] as RoutePlan),
      );

      final travel = TravelViewModel.fromDomain(
        Travel(
          domainId: 'travel-1',
          backEndId: 'travel-1',
          clientName: 'Maria Silva',
          travelName: 'Lisbon 2025',
          travelStatus: TravelStatus.routeCreated,
          participantsList: const [],
          routePlan: RoutePlan(
            domainId: 'route-1',
            backEndId: 'route-1',
            startDate: DateTime(2025, 8, 1),
            endDate: DateTime(2025, 8, 10),
            startLocation: 'Sao Paulo',
            destination: 'Lisbon',
            interestsList: const [],
          ),
        ),
      );

      Map<String, dynamic>? capturedExtra;

      final router = GoRouter(
        initialLocation: '/travels/travel-1/route',
        routes: [
          GoRoute(
            path: '/travels/:id',
            builder: (context, state) {
              capturedExtra = state.extra as Map<String, dynamic>?;
              return const Scaffold(body: Text('detail'));
            },
          ),
          GoRoute(
            path: '/travels/:id/route',
            builder: (context, state) => RouteCreationPage(travel: travel),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<TravelsController>(
          create: (_) => TravelsController(
            travelUseCases: CrudTravelUseCases(travelRepository),
            routeUseCases: CrudRoute(routeRepository),
          ),
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
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/travels/travel-1');
      expect(capturedExtra, {'refresh': true});
    },
  );
}
