import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';
import 'package:travel_matrix/features/account/presentation/widgets/preferences_card.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

Widget _wrap(SettingsController controller) {
  return ChangeNotifierProvider.value(
    value: controller,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: PreferencesCard(l10n: AppLocalizations.of(context)!),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SettingsStorageService.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await SettingsStorageService.init();
  });

  testWidgets(
    'toggling dark mode reflects immediately in the switch, without waiting for I/O',
    (tester) async {
      final controller = SettingsController();

      await tester.pumpWidget(_wrap(controller));

      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(controller.themeMode, ThemeMode.dark);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
    },
  );

  testWidgets('toggling the language updates the displayed language code', (tester) async {
    final controller = SettingsController();

    await tester.pumpWidget(_wrap(controller));

    expect(find.textContaining('(EN)'), findsOneWidget);

    await tester.tap(find.textContaining('(EN)'));
    await tester.pump();

    expect(find.textContaining('(PT)'), findsOneWidget);
  });
}
