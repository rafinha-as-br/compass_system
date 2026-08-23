import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/app/gates/gate_splash.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

void main() {
  testWidgets('renderiza sem lançar exceção com o logo e o título via i18n', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: GateSplash(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('RouteCraft'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Desmonta a árvore antes do fim do teste para cancelar o Timer de navegação
    // de 2s no dispose() — sem isso, flutter_test acusa timer pendente.
    await tester.pumpWidget(const SizedBox());
  });
}
