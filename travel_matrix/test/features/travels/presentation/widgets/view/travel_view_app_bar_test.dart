import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_participants.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_app_bar.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

class _MockCrudParticipants extends Mock implements CrudParticipants {}

Travel _buildNotReadyTravel({
  String travelName = 'Travel',
  bool hasItinerary = true,
  List<ItineraryStep> itinerarySteps = const [],
  List<Person> participants = const [],
}) {
  return Travel(
    domainId: '1',
    backEndId: '1',
    clientName: 'Client',
    travelName: travelName,
    travelStatus: TravelStatus.routeCreated,
    participantsList: participants,
    routePlan: RoutePlan(
      domainId: 'route-1',
      backEndId: 'route-1',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      startLocation: 'SP',
      destination: 'Paris',
      interestsList: const [],
    ),
    itinerary: hasItinerary
        ? Itinerary(
            domainId: 'itinerary-1',
            backEndId: 'itinerary-1',
            agentName: 'Agent',
            itinerarySteps: itinerarySteps,
          )
        : null,
  );
}

Widget _wrap(TravelsController controller, TravelViewModel travel, {Locale? locale}) {
  return ChangeNotifierProvider.value(
    value: controller,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
      ),
    ),
  );
}

void main() {
  late _MockCrudTravelUseCases travelUseCases;
  late _MockCrudRoute routeUseCases;
  late _MockCrudParticipants participantsUseCases;

  setUp(() {
    travelUseCases = _MockCrudTravelUseCases();
    routeUseCases = _MockCrudRoute();
    participantsUseCases = _MockCrudParticipants();
    when(() => travelUseCases.readAll()).thenAnswer((_) async => const Result.success([]));
  });

  testWidgets('failing to prepare a travel shows the error snackbar with the theme error color', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => travelUseCases.markAsReady(any())).thenAnswer((_) async => Result.failure('boom'));
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
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
            length: 4,
            child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.prepareTravelButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.prepareTravelButton));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppTheme.lightTheme.colorScheme.error);
  });

  testWidgets(
    'does not overflow at a narrow window width, even with a long travel title',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
      final travel = TravelViewModel.fromDomain(
        _buildNotReadyTravel(
          travelName: 'A very long travel name that would never fit next to three action buttons',
        ),
      );

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
              length: 4,
              child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    },
  );

  testWidgets(
    'status chip uses the semantic warning color at 12% alpha, not a solid *Container fallback',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
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
              length: 4,
              child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final warning = AppTheme.lightTheme.semanticColors.warning;
      final chipText = tester.widget<Text>(find.text(travel.statusString));
      expect(chipText.style?.color, warning);

      final chipContainer = tester.widget<Container>(
        find.ancestor(of: find.text(travel.statusString), matching: find.byType(Container)).first,
      );
      final decoration = chipContainer.decoration as BoxDecoration;
      expect(decoration.color, warning.withValues(alpha: 0.12));
    },
  );

  testWidgets('renders the travel dates in Portuguese, not with English month abbreviations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
    final travel = TravelViewModel.fromDomain(_buildNotReadyTravel());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DefaultTabController(
            length: 4,
            child: Scaffold(appBar: TravelViewAppBar(travel: travel)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('jan.'), findsOneWidget);
    expect(find.textContaining('Jan '), findsNothing);
  });

  testWidgets('"Editar" groups Route/Itinerary in a flyout, with a divider before "Preparar viagem"', (
    tester,
  ) async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
    final travel = TravelViewModel.fromDomain(_buildNotReadyTravel());
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(_wrap(controller, travel));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text(l10n.editMenuLabel), findsOneWidget);
    expect(find.text(l10n.editRouteTitle), findsNothing);

    await tester.tap(find.text(l10n.editMenuLabel));
    await tester.pumpAndSettle();

    expect(find.text(l10n.editRouteTitle), findsOneWidget);
    expect(find.text(l10n.editItineraryTitle), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text(l10n.prepareTravelButton), findsOneWidget);
  });

  testWidgets('"Preparar viagem" is disabled with the needs-itinerary tooltip when there is no itinerary', (
    tester,
  ) async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
    final travel = TravelViewModel.fromDomain(_buildNotReadyTravel(hasItinerary: false));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(_wrap(controller, travel));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final menuItem = tester.widget<MenuItemButton>(
      find.ancestor(of: find.text(l10n.prepareTravelButton), matching: find.byType(MenuItemButton)),
    );
    expect(menuItem.onPressed, isNull);

    final tooltip = tester.widget<Tooltip>(
      find.ancestor(of: find.byType(MenuItemButton), matching: find.byType(Tooltip)).first,
    );
    expect(tooltip.message, l10n.needsItineraryFirstTooltip);
  });

  testWidgets('the "Preparar viagem" dialog summarizes participants, dates and the first/last step', (
    tester,
  ) async {
    final controller = TravelsController(travelUseCases: travelUseCases, routeUseCases: routeUseCases, participantsUseCases: participantsUseCases);
    when(() => travelUseCases.markAsReady(any())).thenAnswer((_) async => Result.success(_buildNotReadyTravel()));
    final travel = TravelViewModel.fromDomain(
      _buildNotReadyTravel(
        participants: [Person(domainId: 'p1', backendId: 'p1', name: 'Ana', age: '30', sex: 'F')],
        itinerarySteps: [
          ItineraryStep.newStop(
            domainId: 's1',
            backEndId: 's1',
            title: 'Chegada em Paris',
            startDate: DateTime(2026, 1, 1),
            finishDate: DateTime(2026, 1, 2),
            name: 'Paris',
            description: '',
            experiences: const [],
          ),
          ItineraryStep.newStop(
            domainId: 's2',
            backEndId: 's2',
            title: 'Retorno',
            startDate: DateTime(2026, 1, 9),
            finishDate: DateTime(2026, 1, 10),
            name: 'SP',
            description: '',
            experiences: const [],
          ),
        ],
      ),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final router = GoRouter(
      initialLocation: '/travels/1',
      routes: [
        GoRoute(
          path: '/travels/1',
          builder: (context, state) =>
              DefaultTabController(length: 4, child: Scaffold(appBar: TravelViewAppBar(travel: travel))),
        ),
        GoRoute(path: '/travels', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
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

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.prepareTravelButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.prepareTravelDialogTitle), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Chegada em Paris'), findsOneWidget);
    expect(find.text('Retorno'), findsOneWidget);

    await tester.tap(find.text(l10n.prepareTravelButton).last);
    await tester.pumpAndSettle();

    verify(() => travelUseCases.markAsReady('1')).called(1);
  });
}
