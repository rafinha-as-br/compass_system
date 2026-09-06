import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:routecraft_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets('shows an empty state when there are no notifications', (tester) async {
    await tester.pumpWidget(_wrap(NotificationsPage(
      controller: NotificationsController.withState(const NotificationsState(isLoading: false)),
    )));

    expect(find.text('No notifications yet.'), findsOneWidget);
  });

  testWidgets('renders unread and read notifications, with "mark all read" enabled only when needed', (tester) async {
    final controller = NotificationsController.withState(NotificationsState(
      isLoading: false,
      notifications: [
        TravelNotification(
          id: 'n1',
          travelId: 't1',
          travelName: 'Litoral Norte',
          type: TravelNotificationType.itineraryPublished,
          createdAt: DateTime.now(),
        ),
        TravelNotification(
          id: 'n2',
          travelId: 't2',
          travelName: 'Serra Gaúcha',
          type: TravelNotificationType.routeReceived,
          createdAt: DateTime.now(),
          read: true,
        ),
      ],
    ));

    await tester.pumpWidget(_wrap(NotificationsPage(controller: controller)));

    expect(find.textContaining('Litoral Norte'), findsOneWidget);
    expect(find.textContaining('Serra Gaúcha'), findsOneWidget);

    final markAllRead = tester.widget<TextButton>(find.widgetWithText(TextButton, 'mark all read'));
    expect(markAllRead.onPressed, isNotNull);
  });

  testWidgets('"mark all read" is disabled once every notification is already read', (tester) async {
    final controller = NotificationsController.withState(NotificationsState(
      isLoading: false,
      notifications: [
        TravelNotification(
          id: 'n1',
          travelId: 't1',
          travelName: 'Litoral Norte',
          type: TravelNotificationType.itineraryPublished,
          createdAt: DateTime.now(),
          read: true,
        ),
      ],
    ));

    await tester.pumpWidget(_wrap(NotificationsPage(controller: controller)));

    final markAllRead = tester.widget<TextButton>(find.widgetWithText(TextButton, 'mark all read'));
    expect(markAllRead.onPressed, isNull);
  });

  testWidgets('groups same-day notifications under one "Today" header', (tester) async {
    final now = DateTime.now();
    final controller = NotificationsController.withState(NotificationsState(
      isLoading: false,
      notifications: [
        TravelNotification(
          id: 'n1',
          travelId: 't1',
          travelName: 'Litoral Norte',
          type: TravelNotificationType.itineraryPublished,
          createdAt: now,
        ),
        TravelNotification(
          id: 'n2',
          travelId: 't2',
          travelName: 'Serra Gaúcha',
          type: TravelNotificationType.routeReceived,
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
      ],
    ));

    await tester.pumpWidget(_wrap(NotificationsPage(controller: controller)));

    expect(find.text('TODAY'), findsOneWidget);
  });
}
