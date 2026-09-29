import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/notifications_badge_controller.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:travel_matrix/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:travel_matrix/features/notifications/presentation/pages/notifications_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockNotificationUseCases extends Mock implements NotificationUseCases {}

Widget _wrap(NotificationsController controller) {
  final router = GoRouter(
    initialLocation: '/notifications',
    routes: [
      GoRoute(path: '/notifications', builder: (context, state) => NotificationsPage(controller: controller)),
      GoRoute(path: '/travels/:id', builder: (context, state) => const SizedBox()),
    ],
  );

  return ChangeNotifierProvider(
    create: (_) => NotificationsBadgeController(useCases: _MockNotificationUseCases()),
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

void main() {
  testWidgets('shows the empty state when there are no notifications', (tester) async {
    final controller = NotificationsController.withState(const NotificationsState(isLoading: false));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('shows an error state with a retry action on failure', (tester) async {
    final controller = NotificationsController.withState(const NotificationsState(isLoading: false, isError: true));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('renders read and unread notifications distinctly, and enables "mark all as read" only when needed', (
    tester,
  ) async {
    final unread = TravelNotification(
      id: 'n1',
      travelId: 't1',
      type: TravelNotificationType.routeCreated,
      createdAt: DateTime.now(),
      read: false,
    );
    final read = TravelNotification(
      id: 'n2',
      travelId: 't2',
      type: TravelNotificationType.routeEdited,
      createdAt: DateTime.now(),
      read: true,
    );
    final controller = NotificationsController.withState(
      NotificationsState(isLoading: false, notifications: [unread, read]),
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('A client created a route for one of your travels.'), findsOneWidget);
    expect(find.text('A client edited the route of one of your travels.'), findsOneWidget);

    final markAllButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark all as read'));
    expect(markAllButton.onPressed, isNotNull);
  });

  testWidgets('"mark all as read" is disabled once every notification is read', (tester) async {
    final controller = NotificationsController.withState(
      NotificationsState(
        isLoading: false,
        notifications: [
          TravelNotification(
            id: 'n1',
            travelId: 't1',
            type: TravelNotificationType.routeCreated,
            createdAt: DateTime.now(),
            read: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    final markAllButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark all as read'));
    expect(markAllButton.onPressed, isNull);
  });

  testWidgets('tapping a notification marks it read and navigates to its travel', (tester) async {
    // Unlike the other cases here, this one exercises `markAsRead` too (via
    // the tap), which `.withState` can't stub — it always falls through to
    // the real singleton wiring. Mocked use cases via the real constructor
    // avoid that.
    final useCases = _MockNotificationUseCases();
    when(() => useCases.getNotifications(page: 0, size: 20)).thenAnswer(
      (_) async => Result.success(([
        TravelNotification(
          id: 'n1',
          travelId: 'travel-42',
          type: TravelNotificationType.routeCreated,
          createdAt: DateTime.now(),
          read: false,
        ),
      ], false)),
    );
    when(() => useCases.markAsRead('n1')).thenAnswer((_) async => const Result.success(null));

    String? landedOn;
    final router = GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          builder: (context, state) =>
              NotificationsPage(controller: NotificationsController(notificationUseCases: useCases)),
        ),
        GoRoute(
          path: '/travels/:id',
          builder: (context, state) {
            landedOn = state.pathParameters['id'];
            return const SizedBox();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NotificationsBadgeController(useCases: _MockNotificationUseCases()),
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

    await tester.tap(find.text('A client created a route for one of your travels.'));
    await tester.pumpAndSettle();

    expect(landedOn, 'travel-42');
    verify(() => useCases.markAsRead('n1')).called(1);
  });
}
