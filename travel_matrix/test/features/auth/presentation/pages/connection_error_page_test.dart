import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/auth/presentation/pages/connection_error_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Widget _wrap(AuthController controller) {
  return ChangeNotifierProvider<AuthController>.value(
    value: controller,
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('pt'),
      home: ConnectionErrorPage(),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'stored-token'});
    await AuthStorageService.init();
    await AuthStorageService.instance.saveToken('stored-token');
  });

  testWidgets('shows the connection error with a "Tentar novamente" action', (tester) async {
    final controller = AuthController(fetchAuthenticatedUser: (_) async => throw Exception('offline'));
    await controller.initialize();

    await tester.pumpWidget(_wrap(controller));

    expect(find.text('Sem conexão com o servidor'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Tentar novamente'), findsOneWidget);
  });

  testWidgets('tapping the action retries the session and disables the button meanwhile', (tester) async {
    var calls = 0;
    final pending = Completer<Map<String, dynamic>>();
    final controller = AuthController(fetchAuthenticatedUser: (_) {
      calls++;
      if (calls == 1) throw Exception('offline');
      return pending.future;
    });
    await controller.initialize();
    await tester.pumpWidget(_wrap(controller));

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(calls, 2);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete({
      'status': 'success',
      'data': {'id': '1', 'name': 'Carlos'},
      'message': null,
    });
    await tester.pump();

    expect(controller.hasConnectionError, isFalse);
    expect(controller.userName, 'Carlos');
  });
}
