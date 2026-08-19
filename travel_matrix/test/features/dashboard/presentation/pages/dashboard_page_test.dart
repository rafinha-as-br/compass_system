import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/domain/get_dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:travel_matrix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockGetDashboardStats extends Mock implements GetDashboardStats {}

final _stats = DashboardStats(
  totalTravels: 12,
  completedItineraries: 7,
  pendingItineraries: 5,
  activeClients: 9,
  recentTravels: [
    DashboardTravelSummary(
      id: '1',
      clientName: 'Maria Silva',
      travelName: 'Litoral Norte',
      destination: 'Ubatuba',
      startLocation: 'São Paulo',
      startDate: DateTime.fromMillisecondsSinceEpoch(0),
      status: 'travel_started',
      hasItinerary: true,
    ),
  ],
  activeClientsList: const [
    DashboardClientSummary(
      id: '1',
      name: 'Maria Silva',
      email: 'maria@compass.com',
      phoneNumber: '11999999999',
    ),
  ],
);

Widget _wrap(DashboardController controller) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthController()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DashboardPage(controller: controller),
    ),
  );
}

void main() {
  late _MockGetDashboardStats getDashboardStats;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppInjector.init();
    getDashboardStats = _MockGetDashboardStats();
  });

  testWidgets('shows the dashboard once loading succeeds, with the status label localized',
      (tester) async {
    when(() => getDashboardStats()).thenAnswer((_) async => _stats);
    final controller = DashboardController(getDashboardStats: getDashboardStats);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsWidgets);
    expect(find.text('12'), findsOneWidget);
    // status "travel_started" deve renderizar o texto humanizado via l10n,
    // não o valor bruto do backend.
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('travel_started'), findsNothing);
  });

  testWidgets('shows a friendly error message on failure, never the raw exception', (tester) async {
    when(() => getDashboardStats()).thenThrow(StateError('Not authenticated.'));
    final controller = DashboardController(getDashboardStats: getDashboardStats);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to load your dashboard right now. Please try again later.'),
      findsOneWidget,
    );
    expect(find.textContaining('Not authenticated'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
  });
}
