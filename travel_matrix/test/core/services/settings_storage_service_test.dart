import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';

void main() {
  setUp(() {
    SettingsStorageService.resetForTesting();
  });

  group('SettingsStorageService', () {
    test('returns null for theme mode and locale when nothing was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SettingsStorageService.init();

      expect(await storage.getThemeMode(), isNull);
      expect(await storage.getLocale(), isNull);
    });

    test('round-trips a saved theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SettingsStorageService.init();

      await storage.saveThemeMode('dark');

      expect(await storage.getThemeMode(), 'dark');
    });

    test('round-trips a saved locale', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SettingsStorageService.init();

      await storage.saveLocale('pt');

      expect(await storage.getLocale(), 'pt');
    });
  });
}
