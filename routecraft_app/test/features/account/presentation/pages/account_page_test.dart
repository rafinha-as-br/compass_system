import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/presentation/controllers/account_controller.dart';
import 'package:routecraft_app/features/account/presentation/pages/account_page.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _FakeTravelRepository implements TravelRepository {
  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async => const Result.success([]);

  @override
  Future<Result<Travel>> getTravel(String id) async => throw UnimplementedError();

  @override
  Future<Result<Travel>> createTravel(Travel travel) async => throw UnimplementedError();
}

class _FakeNotificationStorage implements NotificationStorage {
  List<TravelNotification> notifications = const [];

  @override
  Future<List<TravelNotification>> loadNotifications() async => notifications;

  @override
  Future<void> saveNotifications(List<TravelNotification> notifications) async {}

  @override
  Future<Map<String, TravelSnapshot>> loadSnapshots() async => const {};

  @override
  Future<void> saveSnapshots(Map<String, TravelSnapshot> snapshots) async {}
}

Widget _wrap(AccountController controller, {AuthController? authController}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
      ChangeNotifierProvider<AuthController>.value(
        value: authController ?? AuthController(checkAuthenticated: () async => true),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountPage(controller: controller),
    ),
  );
}

void main() {
  testWidgets('shows a loading spinner while fetching', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(const AccountState())));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the authenticated client\'s name and email, not a fixed example', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza', clientEmail: 'rafaela@email.com'),
    )));

    expect(find.text('Rafaela Souza'), findsOneWidget);
    expect(find.text('rafaela@email.com'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('John Doe'), findsNothing);
  });

  testWidgets('shows the agent block only when an agent name is available', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza', agentName: 'Marcos Cardoso'),
    )));

    expect(find.text('Marcos Cardoso'), findsOneWidget);
    expect(find.text('MC'), findsOneWidget);
  });

  testWidgets('hides the agent block when there is no agent yet', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza'),
    )));

    expect(find.text('MY AGENT'), findsNothing);
  });

  testWidgets('logging out clears the session via AuthController', (tester) async {
    var loggedOut = false;
    final authController = AuthController(
      checkAuthenticated: () async => true,
      clearToken: () async => loggedOut = true,
    );

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(
      AccountController.withState(const AccountState(isLoading: false, clientName: 'Rafaela Souza')),
      authController: authController,
    ));

    await tester.tap(find.text('LOGOUT'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
    expect(authController.isAuthenticated, isFalse);
  });

  testWidgets('tapping a menu item without a real screen yet shows a coming-soon message', (tester) async {
    await tester.pumpWidget(_wrap(AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza'),
    )));

    await tester.tap(find.text('Help'));
    await tester.pump();

    expect(find.text('Coming soon.'), findsOneWidget);
  });

  testWidgets('tapping "Personal data" navigates to the personal data screen', (tester) async {
    final controller = AccountController.withState(
      const AccountState(isLoading: false, clientName: 'Rafaela Souza'),
    );
    final router = GoRouter(
      initialLocation: AppRoutes.account,
      routes: [
        GoRoute(
          path: AppRoutes.account,
          builder: (context, state) => AccountPage(controller: controller),
          routes: [
            GoRoute(
              path: AppRoutes.personalData,
              builder: (context, state) => const Scaffold(body: Text('Personal Data Screen')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
        ChangeNotifierProvider<AuthController>.value(
          value: AuthController(checkAuthenticated: () async => true),
        ),
      ],
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
    ));

    await tester.tap(find.text('Personal data'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Data Screen'), findsOneWidget);
  });

  testWidgets('clears the unread badge after returning from notifications', (tester) async {
    final notificationStorage = _FakeNotificationStorage()
      ..notifications = [
        TravelNotification(
          id: 'n1',
          travelId: 't1',
          travelName: 'Litoral Norte',
          type: TravelNotificationType.itineraryPublished,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
    final controller = AccountController(
      travelUseCases: TravelUseCases(_FakeTravelRepository()),
      getClientName: () async => 'Rafaela Souza',
      getClientEmail: () async => 'rafaela@email.com',
      notificationStorage: notificationStorage,
    );
    final router = GoRouter(
      initialLocation: AppRoutes.account,
      routes: [
        GoRoute(
          path: AppRoutes.account,
          builder: (context, state) => AccountPage(controller: controller),
          routes: [
            GoRoute(
              path: AppRoutes.notifications,
              // Stands in for NotificationsPage: pops itself right away, as
              // if the client had just marked every notification as read.
              builder: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
        ChangeNotifierProvider<AuthController>.value(
          value: AuthController(checkAuthenticated: () async => true),
        ),
      ],
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
    ));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    notificationStorage.notifications = [
      TravelNotification(
        id: 'n1',
        travelId: 't1',
        travelName: 'Litoral Norte',
        type: TravelNotificationType.itineraryPublished,
        createdAt: DateTime(2026, 1, 1),
        read: true,
      ),
    ];
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
  });
}
