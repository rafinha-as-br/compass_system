import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/loading_widget.dart';

void main() {
  testWidgets('renders the logo and app name without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LoadingWidget()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate((w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/logo.png'), findsOneWidget);
    expect(find.text('Travel Matrix'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
