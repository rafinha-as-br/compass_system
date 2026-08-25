import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/app/app.dart';

void main() {
  testWidgets('RouteCraftApp boots without throwing and shows the splash gate', (tester) async {
    await tester.pumpWidget(const RouteCraftApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('RouteCraft'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Desmonta a árvore antes do fim do teste para cancelar o Timer de navegação
    // de 2s no dispose() do GateSplash — sem isso, flutter_test acusa timer pendente.
    await tester.pumpWidget(const SizedBox());
  });
}
