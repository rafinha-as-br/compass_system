import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/offline_banner.dart';

Widget _wrap(Widget child, {Locale? locale}) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('shows the cloud-off icon and the synced-at date', (tester) async {
    await tester.pumpWidget(_wrap(OfflineBanner(syncedAt: DateTime(2026, 10, 13))));

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text('Offline · data from 13 Oct 2026'), findsOneWidget);
  });

  testWidgets('localizes the label in Portuguese', (tester) async {
    await tester.pumpWidget(_wrap(OfflineBanner(syncedAt: DateTime(2026, 10, 13)), locale: const Locale('pt')));

    expect(find.text('Sem conexão · dados de 13 out 2026'), findsOneWidget);
  });
}
